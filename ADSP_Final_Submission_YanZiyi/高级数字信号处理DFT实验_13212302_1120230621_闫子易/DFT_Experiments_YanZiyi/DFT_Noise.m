

%% Two figures combined

% 通用DFT绘制程序（极坐标版 + 合并显示修正版）
clear; clc;
close all;

% ========== 定义是实数信号还是复数信号 ==========
COMPLEX_SIGNAL = 1;     
REAL_SIGNAL = 0;

% ========== 参数设置 ==========
N   = 8;              % DFT 点数
Fre = 1.2;              % 信号率
phai = 0;          % 初相位
highlight = [2,3,4];  % 要标红的点索引（MATLAB下标从1开始）
Noise_Amplitude = 4;
Signal_Amplitude = 1;

% ========== 构造信号 ==========
Signal_Type = REAL_SIGNAL;  % REAL_SIGNAL -> cos, COMPLEX_SIGNAL -> exp
n = 0:N-1;
if Signal_Type == COMPLEX_SIGNAL 
    x = Signal_Amplitude*exp(1j*2*pi*Fre*n/N + phai);      % 复数信号
else
    x =Signal_Amplitude* cos(2*pi*Fre*n/N + phai);   % 实信号
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rng('shuffle');  %使用当前时间作为种子值，产生不可预测的随机数序列；不调用rng也产生不同不可预测的随机数序列
rng(2);      %指定种子，产生固定的随机数
noise = rand(1, N);

x = x + Noise_Amplitude * noise;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ========== DFT 循环实现 ==========
X_loop = zeros(1,N);
for k = 0:N-1
    for nn = 0:N-1
        X_loop(k+1) = X_loop(k+1) + x(nn+1) * exp(-1j*2*pi/N*k*nn);
    end
end

% ========== 矩阵实现 ==========
W = exp(-1j*2*pi/N*(0:N-1)'*(0:N-1));  % DFT矩阵
X_matrix = (W * x.').';                % DFT结果

% ========== IDFT 验证 ==========
W_inv = exp(1j*2*pi*(0:N-1)'*(0:N-1)/N)/N;
I_check = W * W_inv;     % 应该接近单位阵
I_check = round(I_check, 2);  % 保留两位小数
disp('验证 W * W_inv 是否为单位矩阵 (保留两位小数):');
disp(I_check);

% ========== 打印 DFT 循环和矩阵结果 ==========
disp('对比 DFT 循环 vs 矩阵结果:');
for k = 1:N
    if ismember( k , highlight )
        fprintf('--X[%d] 循环= %.2f%+.2fj , 矩阵= %.2f%+.2fj\n', ...
            k-1, real(X_loop(k)), imag(X_loop(k)), real(X_matrix(k)), imag(X_matrix(k)));
    else
        fprintf('X[%d] 循环= %.2f%+.2fj , 矩阵= %.2f%+.2fj\n', ...
            k-1, real(X_loop(k)), imag(X_loop(k)), real(X_matrix(k)), imag(X_matrix(k)));
    end
end


% ========== 修正：两张图合并为同一窗口（左右布局） ==========
figure('Position', [100, 100, 1000, 500]);  % 总窗口大小（x,y,宽,高）

% ---------------- 左图：极坐标复平面图 ----------------
% 直接创建极坐标 axes，不使用subplot
pax = polaraxes;
pax.Position = [0.05, 0.1, 0.4, 0.8];  % [左, 下, 宽, 高] 占比
hold(pax, 'on');

% 圆半径取最大幅值的1.1倍
R = max(abs([X_loop, X_matrix])) * 1.1;

% 绘制所有DFT点
offset_angle = pi/30;  % 文字交替偏移，防止重叠
for k = 1:N
    r = abs(X_loop(k));          % 模值（极径）
    theta = angle(X_loop(k));    % 相位（极角）
    
    % 区分普通点和重点点
    if ismember(k, highlight)
        polarscatter(pax, theta, r, 80, 'r', 'filled');  % 红色大圆点
    else
        polarscatter(pax, theta, r, 60, 'b', 'filled');  % 蓝色小圆点
    end
    
    % 点的标注
    if ismember(k, highlight) && ~(abs(real(X_loop(k))) < 1e-10 && abs(imag(X_loop(k))) < 1e-10)
        txt = sprintf('X[%d]: %.2f%+.2fj', k-1, real(X_loop(k)), imag(X_loop(k)));
    else
        txt = sprintf('X[%d]', k-1);
    end
    
    % 添加标注文字
    text(theta + offset_angle, r, txt, 'FontSize', 9, ...
         'HorizontalAlignment', 'left', 'Parent', pax);
    offset_angle = -offset_angle;  % 交替正负偏移
end

title(pax, 'DFT复平面（极坐标）', 'FontSize', 12);


% ---------------- 右图：DFT模值离散图 ----------------
% 创建普通坐标 axes
ax = axes;
ax.Position = [0.55, 0.1, 0.4, 0.8];  % [左, 下, 宽, 高] 占比
hold(ax, 'on');

X_mag = abs(X_loop);  % 计算DFT模值

% 绘制离散信号图
stem(ax, 0:N-1, X_mag, 'filled', 'MarkerSize', 6, 'Color', [0.2, 0.6, 0.8]);
grid on;
xlabel(ax, 'k（频率点索引）', 'FontSize', 11);
ylabel(ax, '|X[k]|（DFT模值）', 'FontSize', 11);
title(ax, 'DFT模值随k的变化', 'FontSize', 12);
xlim(ax, [-0.5, N-0.5]);
ylim(ax, [0, max(X_mag)*1.2]);

% ---------------- 总标题 ----------------
sgtitle(sprintf('DFT结果可视化（N=%d, 频率Fre=%d, 初相phi=%.2f rad）', N, Fre, phai), ...
        'FontSize', 14, 'FontWeight', 'bold');
