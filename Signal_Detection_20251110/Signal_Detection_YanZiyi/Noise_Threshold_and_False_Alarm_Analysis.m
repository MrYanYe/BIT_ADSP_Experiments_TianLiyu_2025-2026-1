
% 次或多次（numTrials）生成 N 个样本，记录每次的最大值/次大值/门限/虚警率
clear;clc;
close all;
rng('default');
rng(2);

%% 可修改的参数
N = 1e6;           % 每次试验的样本点数
numTrials = 100;    % 设置为 1、10、100 或其他正整数（控制实验次数）

%% 预分配
maxVals = zeros(1, numTrials);
secondMaxVals = zeros(1, numTrials);
thresholds = zeros(1, numTrials);
falseAlarms = zeros(1, numTrials);
falseAlarmRates = zeros(1, numTrials);

%% 循环进行 numTrials 次试验
for t = 1:numTrials
    % 生成复高斯噪声并取幅值
    w = randn(1, N) + 1i*randn(1, N);
    w = abs(w);
    
    % 找到最大值及索引
    [max0, idxMax] = max(w);
    
    % 找到次大值（通过把最大值置 -Inf 再取 max）
    temp = w;
    temp(idxMax) = -Inf;
    secondMax = max(temp);
    
    % 设置门限为最大值与次大值的中点
    line = (max0 + secondMax) / 2;
    
    % 统计虚警数（超过门限的点数）
    error = sum(w > line);
    
    % 计算虚警率
    falseAlarmRate = error / N;
    
    % 存储结果
    maxVals(t) = max0;
    secondMaxVals(t) = secondMax;
    thresholds(t) = line;
    falseAlarms(t) = error;
    falseAlarmRates(t) = falseAlarmRate;
    
    % 打印每次试验的摘要（可选）
    fprintf('Trial %d/%d: 最大值 = %.6f (索引 %d), 次大值 = %.6f, 门限 = %.6f, 虚警数 = %d, 虚警率 = %e\n', ...
        t, numTrials, max0, idxMax, secondMax, line, error, falseAlarmRate);
end

%% 总结输出
fprintf('\n==== 汇总（%d 次试验, 每次 N = %d）====\n', numTrials, N);
fprintf('最大值均值 = %.6f, 标准差 = %.6f\n', mean(maxVals), std(maxVals));
fprintf('次大值均值 = %.6f, 标准差 = %.6f\n', mean(secondMaxVals), std(secondMaxVals));
fprintf('门限均值 = %.6f, 标准差 = %.6f\n', mean(thresholds), std(thresholds));
fprintf('虚警率均值 = %.6e, 标准差 = %.6e\n', mean(falseAlarmRates), std(falseAlarmRates));

%% 绘图观察规律（删除了最大值分布与直方图）
figure('Name','各试验最大值与门限','NumberTitle','off');
subplot(2,1,1);
plot(1:numTrials, maxVals, '-o', 'LineWidth', 1.2);
hold on;
plot(1:numTrials, secondMaxVals, '-s', 'LineWidth', 1.2);
plot(1:numTrials, thresholds, '-d', 'LineWidth', 1.2);
legend('最大值','次大值','门限','Location','best');
xlabel('试验序号');
ylabel('幅值');
title('每次试验的 最大值 / 次大值 / 门限');

subplot(2,1,2);
plot(1:numTrials, falseAlarmRates, '-o', 'LineWidth', 1.2);
xlabel('试验序号');
ylabel('虚警率');
title('每次试验的 虚警率');

% 将纵坐标格距设置为 1e-6（10^-6）级别
ymax = max(falseAlarmRates);
ytickstep = 1e-6;
% 保证上界至少为一个刻度并向上取整到 yticks 步长
ymax_adj = max(ytickstep, ceil(ymax/ytickstep) * ytickstep);
ylim([0, ymax_adj*2]);
yticks(0:ytickstep:ymax_adj);
grid on;

%% 如果 numTrials==1，绘制该次试验最大值附近的样本（便于直观检查）
if numTrials == 1
    % 重新生成一次样本以便绘制（或可在上面保存最后一次 w）
    w = randn(1, N) + 1i*randn(1, N);
    w = abs(w);
    [max0, idxMax] = max(w);
    startIdx = max(1, idxMax-10);
    endIdx = min(N, idxMax+10);
    figure('Name','单次试验：最大值及其前后点','NumberTitle','off');
    plot(startIdx:endIdx, w(startIdx:endIdx), '-o');
    title('最大值及其前后20点', 'FontSize', 16);
    xlabel('样本索引');
    ylabel('幅值');
end
