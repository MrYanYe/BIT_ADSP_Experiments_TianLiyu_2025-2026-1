% M变化
clc; clear; close all;

% 复位并固定现代随机数生成器种子
rng('default');
rng(1,'twister');

% 基本参数
N = 500;                       % 时间轴长度
M_values = [10,20,40,50,60];   % 用户指定的脉冲宽度数组（长度可变）
N0 = 248;                      % 实际目标延时（回波起始索引）
Signal_Amplitude = 1;          % 脉冲幅度
Noise_Amplitude  = 0.5;        % 噪声标准差

numM = numel(M_values);
SNR = Signal_Amplitude / Noise_Amplitude;

% 创建画布：每个 M 一行，3 列
figure('Color','w','Units','normalized');
t = tiledlayout(numM,3,'TileSpacing','compact','Padding','compact');

for im = 1:numM
    M = M_values(im);

    % 基本信号生成（每次 M 不同）
    echo_signal = zeros(N,1);
    transmit_signal = Signal_Amplitude * ones(M,1); % 理想脉冲模板

    % 如果脉冲超出 N 范围，则截断或警告（这里选择截断）
    if N0+M-1 > N
        warning('M (%d) 超出长度 N (%d)，脉冲将在末端被截断。', M, N);
        valid_len = max(0, N - N0 + 1);
        transmit_signal = Signal_Amplitude * ones(valid_len,1);
        echo_signal(N0:N) = Signal_Amplitude;
    else
        echo_signal(N0:(N0+M-1)) = Signal_Amplitude;
    end

    % 接收信号 = 回波 + 高斯噪声
    receive_signal = echo_signal + Noise_Amplitude .* randn(N,1);

    % 逐点相关（匹配滤波器）计算
    correl = zeros(N,1);
    L = numel(transmit_signal);
    for k = 1:(N - L + 1)
        correl(k) = sum(transmit_signal .* receive_signal(k:(k+L-1)));
    end

    % 找到相关输出的最大值及索引（匹配滤波器检测结果）
    [cmax, cidx] = max(correl);

    % 找到接收信号的最大值及索引（用于在第二列上标注）
    [rvmax, rvidx] = max(receive_signal);

    %% 第一列：回波（echo）
    nexttile((im-1)*3 + 1);
    plot(1:N, echo_signal, 'b', 'LineWidth', 1.2);
    hold on;
    plot(N0, echo_signal(N0), 'gs', 'MarkerSize',6, 'LineWidth',1.2);
    text(N0, echo_signal(N0), sprintf(' true start=(%d, %.3f)', N0, echo_signal(N0)), ...
        'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color','g', 'FontSize',9);
    title(sprintf('M = %d  回波', M));
    xlabel('样点索引');
    ylabel('幅度');
    xlim([1 N]);
    ylim([min(echo_signal)-0.5 max(echo_signal)+0.5]);
    grid on;
    hold off;

    %% 第二列：接收信号（receive）
    nexttile((im-1)*3 + 2);
    plot(1:N, receive_signal, 'k', 'LineWidth', 1);
    hold on;
    plot(rvidx, rvmax, 'ro', 'MarkerSize', 6, 'LineWidth', 1.2);
    text(rvidx, rvmax, sprintf(' recv max=(%d, %.3f)', rvidx, rvmax), ...
        'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color','r', 'FontSize',9);
    plot(N0, receive_signal(N0), 'gs', 'MarkerSize',6, 'LineWidth',1.2);
    text(N0, receive_signal(N0), sprintf(' true start=(%d, %.3f)', N0, receive_signal(N0)), ...
        'VerticalAlignment','top', 'HorizontalAlignment','left', 'Color','g', 'FontSize',9);
    title(sprintf('M = %d  接收信号', M));
    xlabel('样点索引');
    ylabel('幅度');
    xlim([1 N]);
    grid on;
    hold off;

    %% 第三列：相关输出（correl）
    nexttile((im-1)*3 + 3);
    plot(1:N, correl, 'b', 'LineWidth', 1);
    hold on;
    % 标注相关输出的最大值
    plot(cidx, cmax, 'ro', 'MarkerSize', 6, 'LineWidth', 1.2);
    text(cidx, cmax, sprintf(' corr max=(%d, %.4f)', cidx, cmax), ...
        'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color','r', 'FontSize',9);
    % 标注真实回波对应的相关起点（如果在有效索引范围内）
    if N0 <= numel(correl)
        plot(N0, correl(N0), 'gs', 'MarkerSize',6, 'LineWidth',1.2);
        text(N0, correl(N0), sprintf(' true start=(%d, %.4f)', N0, correl(N0)), ...
            'VerticalAlignment','top', 'HorizontalAlignment','left', 'Color','g', 'FontSize',9);
    end
    title(sprintf('M = %d  相关输出', M));
    xlabel('样点索引');
    ylabel('相关幅度');
    xlim([1 N]);
    % 自适应 ylim，避免为零或 NaN
    if any(correl)
        ylim([min(correl)-abs(min(correl))*0.05, max(correl)*1.1]);
    end
    grid on;
    hold off;
end

% 总标题
sgtitle(sprintf('逐个 M 值的匹配滤波结果（SignalAmp=%.2f，NoiseStd=%.2f，N=%d）', ...
    Signal_Amplitude, Noise_Amplitude, N));
