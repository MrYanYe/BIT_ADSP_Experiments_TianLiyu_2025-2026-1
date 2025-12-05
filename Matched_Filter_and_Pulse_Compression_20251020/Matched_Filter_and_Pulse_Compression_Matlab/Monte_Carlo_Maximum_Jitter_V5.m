clear; close all; clc;
% 本程序使用相关技术估计时延，并画出每次蒙特卡洛试验中相关器输出最大值对应的 n 的分布直方图

randn('state',1);
N = 500;      % 数据点数
M = 20;       % 发射脉冲信号宽度
MN = 1000;    % 蒙特卡洛仿真次数
N0 = 248;     % 真实时延（样本索引）
a = 1;      % 脉冲信号幅度
sigma = 0.5;

echo_signal = zeros(N,1);
transmit_signal = a * ones(M,1);
echo_signal(N0:(N0+M-1)) = a;

Delayestimate_error = zeros(MN,1); % 保存每次试验的误差
ctime_all = zeros(MN,1);           % 保存每次试验相关器最大值对应的 n (位置)
cmax_all = zeros(MN,1);           % 保存每次试验相关器的最大值 (可选，用于分析抖动幅度)

for j = 1:MN
    receive_signal = echo_signal + sigma .* randn(N,1);
    correl = zeros(N,1);
    for k = 1:(N - M)
        correl(k) = sum(transmit_signal .* receive_signal(k:(k+M-1)));
    end
    [cmax, ctime] = max(correl);
    ctime_all(j) = ctime;              % 记录最大值对应的索引 n
    cmax_all(j) = cmax;                % 记录最大值大小
    Delayestimate_error(j) = ctime - N0;
end

% 增加图窗高度，为标题和统计量腾出空间
figure('Position',[100 100 1200 900]);

% 回波信号
subplot(3,3,1)
plot(echo_signal,'LineWidth',1.2)
title('回波信号')
xlabel('样本索引 n')
ylabel('振幅')
axis([0 N 0 2*a])

% 在方波起始位置用小红点标注横纵坐标
hold on
x_dot1 = N0;               % 方波起始索引
y_dot1 = echo_signal(N0);  % 对应幅值（应为 a）
plot(x_dot1, y_dot1, 'ro', 'MarkerSize',4, 'MarkerFaceColor','r')
text(x_dot1+4, y_dot1, sprintf('(%d, %.2f)', x_dot1, y_dot1), 'Color','r', 'FontSize',10)
hold off

% 接收信号（最后一次蒙特卡洛试验的接收信号）
subplot(3,3,2)
plot(receive_signal,'LineWidth',1)
title('接收信号（最后一次试验）')
xlabel('样本索引 n')
ylabel('振幅')

% 相关器输出（对应最后一次试验）
subplot(3,3,3)
plot(correl,'LineWidth',1)
title('相关器输出（最后一次试验）')
xlabel('样本索引 n')
ylabel('相关值')
axis([0 N min(correl)-0.1*abs(min(correl)) max(correl)+0.1*abs(max(correl))])

% 时延估计误差（随试验次数变化）
subplot(3,3,4)
plot(1:MN,Delayestimate_error,'-o','MarkerSize',3)
title('时延估计误差（每次试验）')
xlabel('蒙特卡洛试验次数')
ylabel('误差（样本点）')
xlim([1 MN])

% 时延估计误差直方图
subplot(3,3,7)
histogram(Delayestimate_error,'Normalization','probability')
title(sprintf('时延估计误差直方图 (\\sigma = %.2f)', sigma));
xlabel('误差（样本点）')
ylabel('概率')
grid on

% 相关器输出最大值位置 n 的直方图（关键新增子图）
subplot(3,3,[5 6 8 9])
n_min = 1;
n_max = N - M;
edges = (n_min-0.5):(1):(n_max+0.5);
h = histogram(ctime_all,'BinEdges',edges,'Normalization','count');
title('每次试验相关器最大值对应的 n 的分布')
xlabel('n（最大值出现的样本索引）')
ylabel('出现次数')
grid on

% 找到直方图最高点并用小红点标注横纵坐标
[counts, binEdges] = histcounts(ctime_all, edges);
[peakCount, peakIdx] = max(counts);
binCenter = (binEdges(peakIdx) + binEdges(peakIdx+1))/2; % 最高柱的中心
hold on
plot(binCenter, peakCount, 'ro', 'MarkerSize',4, 'MarkerFaceColor','r')
text(binCenter+1, peakCount, sprintf('(%g, %d)', binCenter, peakCount), 'Color','r', 'FontSize',10)
hold off

% 找到最后一个非零值
last_nonzero = max(ctime_all);
% 横坐标范围往外扩展 2 个点（可调）
xlim([min(ctime_all)-2, last_nonzero+2])

% 相关器最大位置随试验次数变化（用散点显示抖动趋势）
% subplot(3,3,7)
% plot(1:MN, ctime_all, '.','MarkerSize',4)
% hold on
% yline(N0,'r--','真实时延 N0','LineWidth',1)
% title('相关器最大位置随试验次数变化')
% xlabel('蒙特卡洛试验次数')
% ylabel('最大位置 n')
% ylim([n_min-1 n_max+1])
% grid on
% hold off

% 留空用于整体信息或者其它分析
% subplot(3,3,8)
% axis off

% 计算统计量（用于显示）
mean_err = mean(Delayestimate_error);
var_err = var(Delayestimate_error);
mean_ctime = mean(ctime_all);
std_ctime = std(ctime_all);

% 总体标题（顶端）
sgtitle('相关法时延估计与最大值位置分布（蒙特卡洛仿真）','FontSize',16,'FontWeight','bold')

% 在总体标题下一行显示统计量
annotation('textbox',[0.10 0.955 0.8 0.03],...
    'String',sprintf('样本数 MN = %d    均值误差 = %.4f 样本点    方差误差 = %.4f (样本点^2)    最大位置均值 = %.3f    最大位置标准差 = %.3f',MN,mean_err,var_err,mean_ctime,std_ctime),...
    'EdgeColor','none','HorizontalAlignment','center','FontSize',11,'FontWeight','normal');

% 将方差结果保存到变量 var1 以兼容原代码
var1 = var_err;
