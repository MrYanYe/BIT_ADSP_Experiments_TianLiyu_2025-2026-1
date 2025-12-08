clc; clear; close all;

% 复位并固定现代随机数生成器种子
rng('default');    % 将随机数生成器重置为默认配置（避免旧生成器冲突）
rng(1,'twister');  % 固定种子以便结果可复现

N = 500;           % 时间轴长度
M = 20;            % 脉冲宽度（匹配滤波器长度）
N0 = 248;          % 实际目标延时（回波起始索引）
Signal_Amplitude = 1;   % 脉冲幅度
Noise_Amplitude  = 0.5; % 噪声标准差
SNR = Signal_Amplitude / Noise_Amplitude

% 生成回波（echo）和发送脉冲（template）
echo_signal = zeros(N,1);
transmit_signal = Signal_Amplitude * ones(M,1); % 理想脉冲模板
echo_signal(N0:(N0+M-1)) = Signal_Amplitude;    % 将脉冲放入回波

% 接收信号 = 回波 + 高斯噪声
receive_signal = echo_signal + Noise_Amplitude .* randn(N,1);

% 逐点相关（匹配滤波器）计算
correl = zeros(N,1);
for k = 1:(N - M + 1)
    correl(k) = sum(transmit_signal .* receive_signal(k:(k+M-1)));
end
% 注意: correl 有效索引为 1:(N-M+1)，其余元素保持为 0

% 找到相关输出的最大值及索引（匹配滤波器检测结果）
[cmax, cidx] = max(correl);   % cidx 为相关窗口起点索引（估计延时）

% 找到接收信号的最大值及索引（用于在第二子图上标注）
[rvmax, rvidx] = max(receive_signal);

% 绘图
figure('Color','w');

subplot(3,1,1);
plot(1:N, echo_signal, 'b', 'LineWidth', 1.2);
hold on;
% 标注方波（回波）起始点 N0（与其它子图格式一致）
plot(N0, echo_signal(N0), 'gs', 'MarkerSize',6, 'LineWidth',1.2);
text(N0, echo_signal(N0), sprintf(' true start=(%d, %.3f)', N0, echo_signal(N0)), ...
    'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color','g', 'FontSize',9);
title(['Signal Amplitude = ' num2str(Signal_Amplitude) ', Noise Amplitude = ' num2str(Noise_Amplitude) ' 的回波信号']);
xlabel('样点索引');
ylabel('幅度');
xlim([1 N]);
ylim([min(echo_signal)-0.5 max(echo_signal)+0.5]);
grid on;
hold off;

subplot(3,1,2);
plot(1:N, receive_signal, 'k', 'LineWidth', 1);
hold on;
% 标注接收信号的最大值
plot(rvidx, rvmax, 'ro', 'MarkerSize', 6, 'LineWidth', 1.2);
text(rvidx, rvmax, sprintf(' recv max=(%d, %.3f)', rvidx, rvmax), ...
    'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color','r', 'FontSize',9);
% 可选：也标注真实回波起点 N0
plot(N0, receive_signal(N0), 'gs', 'MarkerSize',6, 'LineWidth',1.2);
text(N0, receive_signal(N0), sprintf(' true start=(%d, %.3f)', N0, receive_signal(N0)), ...
    'VerticalAlignment','top', 'HorizontalAlignment','left', 'Color','g', 'FontSize',9);
title(['Signal Amplitude = ' num2str(Signal_Amplitude) ', Noise Amplitude = ' num2str(Noise_Amplitude) ' 的接收信号']);
xlabel('样点索引');
ylabel('幅度');
xlim([1 N]);
grid on;
hold off;

subplot(3,1,3);
plot(1:N, correl, 'b', 'LineWidth', 1);
hold on;
% 标注相关输出的最大值（匹配滤波器检测）
plot(cidx, cmax, 'ro', 'MarkerSize', 6, 'LineWidth', 1.2);
text(cidx, cmax, sprintf(' corr max=(%d, %.4f)', cidx, cmax), ...
    'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color','r', 'FontSize',9);
% 在第三图上也画出真实回波对应的相关起点（N0）
plot(N0, correl(N0), 'gs', 'MarkerSize',6, 'LineWidth',1.2);
text(N0, correl(N0), sprintf(' true start=(%d, %.4f)', N0, correl(N0)), ...
    'VerticalAlignment','top', 'HorizontalAlignment','left', 'Color','g', 'FontSize',9);
xlabel('样点索引');
ylabel('相关幅度');
xlim([1 N]);
ylim([min(correl)-abs(min(correl))*0.05, max(correl)*1.1]);
title('相关滤波器的输出');
grid on;
hold off;
