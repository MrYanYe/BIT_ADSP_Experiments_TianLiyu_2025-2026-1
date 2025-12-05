% PhaseEstimation_V5_VarianceChange_N_T_NoiseVariance.m
clc; clear; close all;
rng('default');

% -------------------------
% 参数区：把所有可能被设置为“数组以作为自变量”的变量放到这里
% 只允许一个变量为数组
% -------------------------
paramGrid.N = [2048];                    % 样本数 N （可设为标量或向量）
% paramGrid.N = 256 .* 2.^(0:8);
% paramGrid.T = 1;          % 周期 T （可设为标量或向量）
paramGrid.T = 1 : 0.1 : 2.1;

paramGrid.A = 1;
paramGrid.Noise_Variance = 1;
% paramGrid.Noise_Variance = 1 .* 2.^(0:5);

paramGrid.phi_true_deg = 30;

paramGrid.PhaseStepDeg = 0.5;
paramGrid.numMonteCarlo = 1000;
% -------------------------
% 是否使用DFT优化
useDFTOptim = 1;


% -------------------------
% 自动检测哪个参数是“自变量”（即元素数 > 1）
% -------------------------
paramNames = fieldnames(paramGrid);
multiIdx = find(cellfun(@(f) numel(paramGrid.(f))>1, paramNames));

if isempty(multiIdx)
    % error('No swept variable found: set exactly one field in paramGrid to be an array.');
    phase_estimation_fixed_coefficients(paramGrid.N, ...
                                    paramGrid.phi_true_deg, ...
                                    paramGrid.T, ...
                                    paramGrid.A, ...
                                    paramGrid.Noise_Variance, ...
                                    useDFTOptim);
    return;
elseif numel(multiIdx) > 1
    error('Multiple swept variables detected: set exactly one field in paramGrid to be an array.');
end

sweepVarName = paramNames{multiIdx};
sweepValues = paramGrid.(sweepVarName);
numSweep = numel(sweepValues);

% 将其它参数读取为标量（若它们本身是数组且不是自变量，会取第一个值）
A = paramGrid.A;
Noise_Variance = paramGrid.Noise_Variance;
phi_true_deg = paramGrid.phi_true_deg;
phase_true = deg2rad(phi_true_deg);
PhaseStepDeg = paramGrid.PhaseStepDeg;
numMonteCarlo = paramGrid.numMonteCarlo;


% 

% 根据是否存在优化函数，设置用于显示/写入的 DFT 方法名字（不会用冗长的多处判断代码）
if useDFTOptim
    dftDisplayName = 'DFT+Optimization';
else
    dftDisplayName = 'DFT';
end

% 预分配结果（3 种方法：ML, DFT(或DFT+mapping), LS）
std_ml  = zeros(1, numSweep);
std_dft = zeros(1, numSweep);
std_ls  = zeros(1, numSweep);

mean_ml  = zeros(1, numSweep);
mean_dft = zeros(1, numSweep);
mean_ls = zeros(1, numSweep);

var_ml  = zeros(1, numSweep);
var_dft = zeros(1, numSweep);
var_ls  = zeros(1, numSweep);

% 用于在报告/Excel中显示的标签（把自变量名和单位/描述联系起来）
switch sweepVarName
    case 'N'
        sweepLabel = 'N (samples)';
    case 'T'
        sweepLabel = 'T (period)';
    case 'A'
        sweepLabel = 'A (amplitude)';
    case 'Noise_Variance'
        sweepLabel = 'Noise variance';
    case 'PhaseStepDeg'
        sweepLabel = 'Phase step (deg)';
    otherwise
        sweepLabel = sweepVarName;
end

% 准备要在子图标题中显示的三个参数（始终显示 N, T, Noise_Variance）
N_display = paramGrid.N;
if numel(N_display) > 1
    N_display = N_display(1);
end
T_display = paramGrid.T;
if numel(T_display) > 1
    T_display = T_display(1);
end
Noise_display = paramGrid.Noise_Variance;
if numel(Noise_display) > 1
    Noise_display = Noise_display(1);
end

% 主循环：对自变量的每个取值运行 Monte Carlo
for idx = 1:numSweep
    currentParams = paramGrid;
    currentParams.(sweepVarName) = sweepValues(idx);
    
    % 读取当前循环所需的变量（常用）
    N = currentParams.N;
    T = currentParams.T;
    A = currentParams.A;
    Noise_Variance = currentParams.Noise_Variance;
    
    % 检查 N 是否为整数 >= 1
    if ~(isscalar(N) && N>=1 && N==floor(N))
        error('N must be a positive integer scalar in each sweep step.');
    end
    
    % 构造相位数组与原始信号（对实信号）
    f0 = T / N;
    ph_arr = 0 : 2*pi*f0 : (N-1)*2*pi*f0;
    s0 = A * cos(ph_arr + phase_true);    % 原始信号（实）
    
    % 最大似然需要的基函数
    sin_s = sin(ph_arr);
    cos_s = cos(ph_arr);
    
    % DFT 相关，按原代码使用 rat(T)
    [I, D] = rat(T);
    

    
    % 最小二乘矩阵预计算
    X0 = [A * cos_s; -A * sin_s].';
    X = pinv(X0.' * X0) * X0.';   % 2xN 矩阵，后续乘以 Y 列向量
    
    % 存放本次取值的三种方法估计值
    est_ml = zeros(1, numMonteCarlo);
    est_dft = zeros(1, numMonteCarlo);
    est_ls = zeros(1, numMonteCarlo);
    
    % Monte Carlo 仿真
    for m = 1:numMonteCarlo
        w = normrnd(0, sqrt(Noise_Variance), 1, N);
        Signal_with_Noise = s0 + w;
        
        % 最大似然估计（实信号形式）
        est_ml(m) = rad2deg(-atan2(dot(Signal_with_Noise, sin_s), dot(Signal_with_Noise, cos_s)));
        
        % DFT 或 DFT+映射表（统一调用：若提供优化函数则调用它，否则使用内联的简单实现）
        if useDFTOptim
            % 调用外部的优化函数（如果存在），只需把必需项传进去
            % est_dft(m) = dft_mapping_opt(Signal_with_Noise, N, T, PhaseStepDeg);
            est_dft(m) = dft_improved_phase_est(Signal_with_Noise,  N, T, PhaseStepDeg, A, Noise_Variance);
        else
            % 优化前（与旧代码行为一致）
            % z = [Signal_with_Noise, zeros(1, (D-1)*N)];
            % Z = fft(z);
            % phi_deg = rad2deg(angle(Z(I+1)));
            % est_dft(m) = list_find(list, phi_deg);
            Z = fft(Signal_with_Noise);
            [~,index] = max(abs(Z));
            est_dft(m) = rad2deg(angle(Z(index)));
        end
        
        % 最小二乘估计
        Y = Signal_with_Noise.';          % N x 1
        theta = X * Y;                    % 2 x 1
        est_ls(m) = rad2deg(atan2(theta(2), theta(1)));
    end
    
    % 计算并保存统计量（以度为单位）
    std_ml(idx) = std(est_ml);
    std_dft(idx) = std(est_dft);
    std_ls(idx) = std(est_ls);
    
    mean_ml(idx) = mean(est_ml);
    mean_dft(idx) = mean(est_dft);
    mean_ls(idx) = mean(est_ls);
    
    var_ml(idx) = var(est_ml);
    var_dft(idx) = var(est_dft);
    var_ls(idx) = var(est_ls);
    
    % 打印进度信息（显示自变量名和值）
    fprintf('Finished %s = %g  (index %d of %d)\n', sweepVarName, sweepValues(idx), idx, numSweep);
end

% 绘图：横轴为自变量；若自变量是 N（样本数量），使用对数尺度以保持原行为
screenSize = get(0,'ScreenSize');
figWidth = min(1400, screenSize(3)*0.9);
figHeight = 360;
figure('Name',sprintf('Phase Estimation STD vs %s', sweepVarName),'NumberTitle','off','Position',[50 150 figWidth figHeight]);

x = sweepValues;

% 子图标题中只显示 N, T, NoiseVar 三个参数（按示例格式）
titleFixedStr = sprintf('N=%g  T=%g  NoiseVar=%g', N_display, T_display, Noise_display);

subplot(1,3,1);
plot(x, std_ml, '-o', 'LineWidth',1.6, 'MarkerSize',6);
if strcmp(sweepVarName,'N')
    set(gca, 'XScale', 'log', 'XTick', x);
else
    set(gca, 'XScale', 'linear');
end
grid on;
xlabel(sweepLabel);
ylabel('Std of phase estimate (deg)');
title(sprintf('Maximum Likelihood  %s changing  %s', sweepVarName, titleFixedStr), 'FontSize', 11);

subplot(1,3,2);
plot(x, std_dft, '-s', 'LineWidth',1.6, 'MarkerSize',6);
if strcmp(sweepVarName,'N')
    set(gca, 'XScale', 'log', 'XTick', x);
else
    set(gca, 'XScale', 'linear');
end
grid on;
xlabel(sweepLabel);
ylabel('Std of phase estimate (deg)');
% 使用上面基于函数存在性的显示名（DFT 或 DFT+Mapping Table）
title(sprintf('%s  %s changing  %s', dftDisplayName, sweepVarName, titleFixedStr), 'FontSize', 11);

subplot(1,3,3);
plot(x, std_ls, '-^', 'LineWidth',1.6, 'MarkerSize',6);
if strcmp(sweepVarName,'N')
    set(gca, 'XScale', 'log', 'XTick', x);
else
    set(gca, 'XScale', 'linear');
end
grid on;
xlabel(sweepLabel);
ylabel('Std of phase estimate (deg)');
title(sprintf('Least Squares  %s changing  %s', sweepVarName, titleFixedStr), 'FontSize', 11);

% 统一 y 轴范围以便比较
all_std = [std_ml, std_dft, std_ls];
ymin = min(all_std) * 0.9;
ymax = max(all_std) * 1.1;
if ymin < ymax
    for k = 1:3
        subplot(1,3,k);
        ylim([ymin, ymax]);
    end
end

% 总标题：指出哪个量在扫、其取值范围，以及 phi_true 和 MonteCarlo 次数
if numel(sweepValues) > 1
    sweepRangeStr = sprintf('%g to %g (steps=%d)', sweepValues(1), sweepValues(end), numel(sweepValues));
else
    sweepRangeStr = sprintf('%g', sweepValues(1));
end
sgtitle(sprintf('Phase estimation STD vs %s (true phase = %g deg, T = %g, noise var = %g, MonteCarlo = %d)', ...
    sweepVarName, phi_true_deg, T_display, Noise_display, numMonteCarlo), 'FontSize', 12);

% =========================
% 保存结果到 Excel（在当前路径下名为 PhaseEstimation_Results 的子文件夹）
% =========================
save_phase_results(paramGrid, paramNames, sweepVarName, sweepValues, ...
    mean_ml, std_ml, mean_dft, std_dft, mean_ls, std_ls, dftDisplayName, sweepLabel);
% ts = datestr(now, 'yyyymmdd_HHMMSS');
% 
% resultsFolder = fullfile(pwd, 'PhaseEstimation_Results');
% if ~exist(resultsFolder, 'dir')
%     mkdir(resultsFolder);
% end
% excelFileName = fullfile(resultsFolder, ['phase_est_results_' ts '.xlsx']);
% 
% % 参数说明（用于写入文件，便于记录）
% paramPairs = cellfun(@(f) sprintf('%s=%s', f, mat2str(paramGrid.(f))), paramNames, 'UniformOutput', false);
% paramLine = strjoin(paramPairs, '; ');
% 
% % Helper to build a block as cell array with consistent column count (numSweep+1)
% build_block = @(methodName, paramLine, sweepVals, meanVals, varVals) ...
%     [ repmat({''},1, numSweep+1); ...
%       [{['Method: ' methodName]}, repmat({''},1,numSweep)]; ...
%       [{ ['Parameters: ' paramLine] }, repmat({''},1,numSweep)]; ...
%       repmat({''},1,numSweep+1); ...
%       [{ sweepLabel }, num2cell(sweepVals)]; ...
%       [{ 'Mean (deg)' }, num2cell(meanVals)]; ...
%       [{ 'Var (deg^2)' }, num2cell(varVals)]; ...
%       repmat({''},1, numSweep+1) ];
% 
% % 构造3个块（其中第二个块名字依据是否有优化函数而定，不用其它冗余判断）
% block_ml  = build_block('Maximum Likelihood', paramLine, sweepValues, mean_ml, var_ml);
% block_dft = build_block(dftDisplayName, paramLine, sweepValues, mean_dft, var_dft);
% block_ls  = build_block('Least Squares', paramLine, sweepValues, mean_ls, var_ls);
% 
% % 合并为大单元格
% big_cell = [block_ml; block_dft; block_ls];
% 
% % 写入 Excel 文件
% writecell(big_cell, excelFileName);
% 
% % 提示完成
% fprintf('Results saved to folder: %s\n', resultsFolder);
% fprintf('Excel file: %s\n', excelFileName);
