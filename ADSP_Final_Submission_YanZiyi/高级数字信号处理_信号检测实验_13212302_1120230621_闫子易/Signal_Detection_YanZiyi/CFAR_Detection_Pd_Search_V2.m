% CFAR_200pt_Detection_Pd_Search_withExampleFromTrials.m
% 分组长度 200，总样本 N=1e6 => 5000 组
% 每组在中心 CUT 放入复目标 A*exp(1j*theta) + 复高斯噪声
% CA-CFAR：左右各 10 个训练单元（共 20 个），使用功率域检测
% 可选择直接指定 A 或自动搜索满足 Pd >= 0.85 的 A
% 本脚本保证绘制的示例组来自实际用于 Pd 统计的某一次分组（随机挑选一组并保存）

clear; clc;
close all;
rng(2);

%% ========== 可修改的参数（在此处统一设置） ==========
N = 1e6;                 % 总样本数
groupLen = 200;          % 每组长度
numGroups = N / groupLen; % 应为 5000
if mod(numGroups,1) ~= 0
    error('N must be divisible by groupLength.');
end

% CFAR 训练单元设置
numTrainLeft = 10;       % 左侧训练单元数
numTrainRight = 10;      % 右侧训练单元数
numTrain = numTrainLeft + numTrainRight; % 总训练单元数 (应为20)

% CFAR 虚警率（每个 CUT 的目标误警概率）
Pfa_desired = 1e-6;      % 可调整（默认 1e-6)

% 目标幅度设置
% 如果 autoFindA = false，则使用 A_fixed 作为目标幅度；
% 如果 autoFindA = true，则通过二分搜索找到使 Pd >= Pd_target 的 A。
autoFindA = true;
A_fixed = 6;           % 如果不自动搜索，直接使用此 A
Pd_target = 0.85;        % 搜索目标检测概率
max_search_iter = 30;    % 二分搜索最大迭代次数
tolA = 1e-3;             % A 搜索精度

% 运行相关设置
verbose = true;          % 是否打印中间信息
showProgress = true;     % 是否显示简单进度

%% ========== 预计算 CFAR 常数 ==========
% 对于单个训练单元的功率服从指数分布（均值 = noise power）
% CA-CFAR 阈值常数 alpha 可按以下公式计算（参见 CA-CFAR 理论）：
% alpha = numTrain * (Pfa^(-1/numTrain) - 1)
alpha = numTrain * (Pfa_desired^(-1/numTrain) - 1);

if verbose
    fprintf('总组数 = %d, 每组长度 = %d, 训练单元 = %d (左右 %d/%d)\n', ...
        numGroups, groupLen, numTrain, numTrainLeft, numTrainRight);
    fprintf('目标虚警率 Pfa = %.3e, CFAR 常数 alpha = %.6f\n', Pfa_desired, alpha);
end

%% ========== 检测函数（对一个给定 A 运行 numGroups 次试验并返回 Pd）
% 现在增加了可选参数 saveExample，当为 true 时将在 numGroups 内随机挑选
% 一个组并保存该组的样本 w、trainingIdx、threshold、CUT_power 等信息（作为示例返回）
function [Pd, example] = run_cfar_once(A, numGroups, groupLen, numTrainLeft, numTrainRight, alpha, showProgress, saveExample)
    if nargin < 8
        saveExample = false;
    end
    detections = 0;
    centerIdx = ceil(groupLen/2); % 将 CUT 放在每组中心（例如第100位）
    example = []; % 默认空
    % 如果需要保存示例，先随机选一个组号
    if saveExample
        exGroup = randi(numGroups);
        saved = false;
    else
        exGroup = -1;
        saved = true; % 标记为已保存以跳过保存逻辑
    end

    for g = 1:numGroups
        % 生成 groupLen 个复高斯噪声样本 (每个分量均为 N(0,0.5) 使复噪声功率均值=1)
        w = (randn(1, groupLen) + 1i*randn(1, groupLen)) / sqrt(2);
        % 在 CUT 加入目标
        theta = 2*pi*rand(); % 随机相位
        w(centerIdx) = w(centerIdx) + A*exp(1i*theta);
        % 训练单元索引（左右各 10 个）
        idxLeft = (centerIdx - numTrainLeft):(centerIdx-1);
        idxRight = (centerIdx+1):(centerIdx + numTrainRight);
        % 边界检查
        idxLeft = idxLeft(idxLeft >= 1 & idxLeft <= groupLen);
        idxRight = idxRight(idxRight >= 1 & idxRight <= groupLen);
        trainingIdx = [idxLeft, idxRight];
        % 计算训练单元平均功率
        P_avg = mean(abs(w(trainingIdx)).^2);
        threshold = alpha * P_avg;
        % 计算 CUT 功率并做判决
        CUT_power = abs(w(centerIdx))^2;
        if CUT_power > threshold
            detections = detections + 1;
        end

        % 如果要保存示例并且当前组为选定组，则保存必要信息
        if ~saved && g == exGroup
            example.groupIndex = g;
            example.w = w; % 复样本向量
            example.centerIdx = centerIdx;
            example.trainingIdx = trainingIdx;
            example.P_avg = P_avg;
            example.threshold = threshold;
            example.CUT_power = CUT_power;
            example.A = A;
            saved = true;
        end

        if showProgress && mod(g,500) == 0
            fprintf(' processed %d/%d groups\r', g, numGroups);
        end
    end
    if showProgress
        fprintf('\n');
    end
    Pd = detections / numGroups;
    % 如果请求保存示例但运行中未能保存（理论上不可能），将 example 置空
    if saveExample && isempty(example)
        example = [];
    end
end

%% ========== 如果 autoFindA 为 true，通过二分搜索找到使 Pd >= Pd_target 的 A ==========
% 我们在最终用于报告 Pd 的那一次完整 monte-carlo 中请求 saveExample=true，
% 以确保保存到的示例组确实来自用于计算 Pd 的那 numGroups 次试验之一。
if autoFindA
    % 初始搜索区间 [Amin, Amax]
    Amin = 0.0;
    Amax = 10.0; % 初始上界，可按需增大
    % 保证上界足够大（如果上界 Pd < Pd_target，则扩大上界直到超过或达到最大次数）
    max_expand = 10;
    expand_count = 0;
    % 初次评估使用 saveExample = false（节省内存与不混淆示例）
    Pd_at_Amax = run_cfar_once(Amax, numGroups, groupLen, numTrainLeft, numTrainRight, alpha, showProgress, false);
    if verbose
        fprintf('初始 Amax = %.3f, Pd = %.4f\n', Amax, Pd_at_Amax);
    end
    while Pd_at_Amax < Pd_target && expand_count < max_expand
        Amax = Amax * 2;
        Pd_at_Amax = run_cfar_once(Amax, numGroups, groupLen, numTrainLeft, numTrainRight, alpha, showProgress, false);
        expand_count = expand_count + 1;
        if verbose
            fprintf('扩大 Amax -> %.3f, Pd = %.4f\n', Amax, Pd_at_Amax);
        end
    end
    if Pd_at_Amax < Pd_target
        warning('未能在设置的最大上界内达到目标 Pd。最终 Amax = %.3f, Pd = %.4f', Amax, Pd_at_Amax);
    end

    % 二分搜索（每次评估不保存示例）
    iter = 0;
    while (Amax - Amin) > tolA && iter < max_search_iter
        A_mid = (Amin + Amax) / 2;
        Pd_mid = run_cfar_once(A_mid, numGroups, groupLen, numTrainLeft, numTrainRight, alpha, showProgress, false);
        if verbose
            fprintf('iter %d: A_mid = %.6f, Pd = %.4f\n', iter, A_mid, Pd_mid);
        end
        if Pd_mid >= Pd_target
            Amax = A_mid; % 可接受，尝试更小的 A
        else
            Amin = A_mid; % 不足，增大 A
        end
        iter = iter + 1;
    end
    A_found = Amax;
    % 最后一次用于报告 Pd 并保存示例（saveExample = true）
    [Pd_found, example] = run_cfar_once(A_found, numGroups, groupLen, numTrainLeft, numTrainRight, alpha, showProgress, true);
    fprintf('\n搜索完成：找到近似最小 A = %.6f 使 Pd >= %.2f，实际 Pd = %.4f\n', A_found, Pd_target, Pd_found);
else
    A_found = A_fixed;
    [Pd_found, example] = run_cfar_once(A_found, numGroups, groupLen, numTrainLeft, numTrainRight, alpha, showProgress, true);
    fprintf('使用固定 A = %.6f，测得 Pd = %.4f\n', A_found, Pd_found);
end

%% ========== 可选：绘制所保存的示例组（来自实际 monte-carlo 的某一次） ==========
showExample = true;
if showExample
    if isempty(example)
        warning('没有可用的示例组数据（example 为空）。无法绘图。');
    else
        % 为绘图固定一次种子以便重现仅影响绘图样式，不影响已保存的数据，仅用于绘图
        rng(100);
        centerIdx = example.centerIdx;
        w = example.w;
        trainingIdx = example.trainingIdx;
        P_avg = example.P_avg;
        threshold = example.threshold;
        A_plot = example.A;
        groupIndex = example.groupIndex;

        figure;
        subplot(2,1,1);
        stem(1:groupLen, abs(w), 'filled');
        hold on;
        stem(centerIdx, abs(w(centerIdx)), 'r', 'filled');
        yline(sqrt(threshold), 'k--', 'LineWidth', 1.2); % 绘制幅值阈值（功率 -> 幅值）
        legend('样本幅值','CUT','阈值（幅值）','Location','best');
        title(sprintf('示意：第 %d 组样本（A = %.3f）, Cell Under Test index = %d', groupIndex, A_plot, centerIdx));
        xlabel('样本索引'); ylabel('幅值');

        subplot(2,1,2);
        plot(1:groupLen, abs(w).^2, '-o');
        hold on;
        plot(trainingIdx, abs(w(trainingIdx)).^2, 'gs', 'MarkerFaceColor','g');
        yline(threshold, 'r--', 'LineWidth', 1.2);
        legend('样本功率','训练单元','阈值（功率）','Location','best');
        xlabel('样本索引'); ylabel('功率');
    end
end
