clc;clear;close all;
N = 128;
Amplitude_Ratio = 1;
delta_f = 0.02;
f1 = 0.15;  % 第一个正弦波频率
A1 = 1;
f2 = f1 + delta_f; % 第二个正弦波频率
A2 =  A1 * Amplitude_Ratio;

% 设置目标 SNR (dB)
SNR_dB = 25;   % 例如 10 dB

p = 10;

n = 0:N-1;

theta1 = 2*pi*rand();
theta2 = 2*pi*rand();

% 原始信号（无噪声）
x_clean = A1 * sin(2*pi*f1*n+theta1) + A2 * sin(2*pi*f2*n+theta2);



% 计算信号功率
signal_power = mean(x_clean.^2);

% 根据目标 SNR 计算噪声功率和标准差
noise_power = signal_power / (10^(SNR_dB/10));
noisestd = sqrt(noise_power);

% 生成噪声并叠加
noise = noisestd * randn(1, N);
x = x_clean + noise;



% x = ar_generate(N,3,[0.3,-0.14,0.11],0.02);



% 接下来计算p阶自相关
% 先划定训练集
train_ratio = 1/2;
train_data_size = floor(N*train_ratio);
train_data_size = 64;
train_data = x(1:train_data_size);

% 然后在训练集上计算p阶自相关
acf = xcorr(train_data,'biased');
corr_porder = acf(train_data_size-p:train_data_size+p);
% 构造p阶自相关矩阵
T = toeplitz(acf(train_data_size:train_data_size+p));
corr_mat = T(1:p,1:p);
% for k = 0:p-1
%     corr_mat_k = circshift(corr_porder,-k);
%     corr_mat(k+1,:) = fliplr(corr_mat_k(2:p+1));
% end
% 构造yule方程，求解ar系数
R = T(2:end,1);
ar_coeff = (corr_mat\R)';

y_pred = zeros(1,N);
y_pred(1:train_data_size) = train_data;

for k = train_data_size + 1: N
    y_pred(k) = ar_coeff * flip((y_pred(k-p:k-1)))';
end

figure;
plot(y_pred,'g','linewidth',2);
hold on;
plot(x,'r');
plot(train_data_size,y_pred(train_data_size),'r*','linewidth',4);
title(sprintf('原始信号与AR预测信号对比 (train data size = %d, N = %d, p = %d, SNR(dB) = %d)',train_data_size,N, p, SNR_dB));

xlabel('样本点 n');
ylabel('幅值');
legend('AR预测信号','原始信号','训练集边界');

figure;
error = y_pred - x;
plot(error);
hold on;
plot(train_data_size,error(train_data_size),'r*');

title(sprintf('预测误差序列 (train data size = %d, N = %d, p = %d, SNR(dB) = %d)',train_data_size,N, p, SNR_dB));
xlabel('样本点 n');
ylabel('误差幅值');
legend('预测误差','训练集边界');

sigma2 = acf(train_data_size) - sum(ar_coeff .* acf(train_data_size+1:train_data_size+p)); % 预测误差方差

% 计算 AR 模型的功率谱密度
freqs = linspace(0, 1, 1000);  % 归一化频率范围 [0, 1]
psd_ar = zeros(size(freqs));
for i = 1:length(freqs)
    f = freqs(i);
    H = 1 ./ (1 - sum(ar_coeff .* exp(-1j * 2 * pi * f * (1:p)))); % 传递函数
    psd_ar(i) = sigma2 * abs(H)^2;  % PSD 公式
end

% 绘制功率谱
figure;
plot(freqs, psd_ar, 'b', 'LineWidth', 1.5);
title(sprintf('AR模型功率谱密度 (SNR=%ddB, p=%d, N=%d)', SNR_dB, p, N));
xlabel('归一化频率 (×π rad/sample)');
ylabel('功率谱密度');

% --- 在 AR PSD 图上标注最高的四个点（红点 + 坐标） ---
hold on;
% 找局部峰值作为候选（提高稳健性）
[pk_vals, pk_locs] = findpeaks(psd_ar, freqs);
% 如果 findpeaks 找不到足够多的峰，退回到全局排序
if length(pk_vals) < 4
    [sorted_vals, ind] = sort(psd_ar, 'descend');
    top_idx = ind(1:min(4,length(sorted_vals)));
    top_freqs = freqs(top_idx);
    top_vals = psd_ar(top_idx);
else
    [sorted_pk_vals, sidx] = sort(pk_vals, 'descend');
    take = min(4, length(sorted_pk_vals));
    top_freqs = pk_locs(sidx(1:take));
    top_vals = sorted_pk_vals(1:take);
end
% 绘制红点并标注坐标（字体较小）
plot(top_freqs, top_vals, 'ro', 'MarkerSize',6, 'LineWidth',1.2);
for k = 1:length(top_freqs)
    txt = sprintf('(%0.4f, %0.3g)', top_freqs(k), top_vals(k));
    text(top_freqs(k), top_vals(k), ['  ' txt], 'FontSize',8, 'Color','r', 'Interpreter','none');
end
hold off;

% 设置 FFT 长度为训练数据长度的 10 倍
% fft_len = 10 * train_data_size;
fft_len = length(y_pred);

% 应用 Hamming 窗函数
win = hamming(length(y_pred))';
windowed_data = y_pred .* win;
% windowed_data = y_pred ;
% 计算功率谱
X_fft = fft(windowed_data, fft_len);              % 计算 FFT
psd_fft = abs(X_fft).^2 / fft_len + 0.01; % 平方取模并归一化，加小常数避免零值

% 构造归一化频率轴（单位：×π rad/sample）
freq_axis = linspace(0, 1, fft_len);

% 绘图
figure;
plot(freq_axis, psd_fft, 'Color', [0 0.5 0], 'LineWidth', 1.5);
title(sprintf('外推后数据的FFT功率谱 (SNR=%ddB, p=%d, N=%d)', SNR_dB, p, N));
xlabel('归一化频率 (×π rad/sample)');
ylabel('功率谱幅值');

% --- 在 FFT PSD 图上标注最高的四个点（红点 + 坐标） ---
hold on;
% 因为 psd_fft 可能有镜像和很多点，先平滑或直接取全局前四个峰值
% 尝试使用 findpeaks 找局部峰
[pk_vals_f, pk_locs_f] = findpeaks(psd_fft, freq_axis);
if length(pk_vals_f) < 4
    [sorted_vals_f, indf] = sort(psd_fft, 'descend');
    top_idx_f = indf(1:min(4,length(sorted_vals_f)));
    top_freqs_f = freq_axis(top_idx_f);
    top_vals_f = psd_fft(top_idx_f);
else
    [sorted_pk_vals_f, sidxf] = sort(pk_vals_f, 'descend');
    takef = min(4, length(sorted_pk_vals_f));
    top_freqs_f = pk_locs_f(sidxf(1:takef));
    top_vals_f = sorted_pk_vals_f(1:takef);
end
% 绘制红点并标注坐标（字体较小）
plot(top_freqs_f, top_vals_f, 'ro', 'MarkerSize',6, 'LineWidth',1.2);
for k = 1:length(top_freqs_f)
    txtf = sprintf('(%0.4f, %0.3g)', top_freqs_f(k), top_vals_f(k));
    text(top_freqs_f(k), top_vals_f(k), ['  ' txtf], 'FontSize',8, 'Color','r', 'Interpreter','none');
end
hold off;

figure;
ar_poly = [1, -ar_coeff];
zplane(1, ar_poly);
title('AR模型零极点分布');
xlabel('实部');
ylabel('虚部');
% 单曲线，无需图例

figure;
x2 = ar_generate(1*N,p,ar_coeff,0.0);
plot(x2);
title('AR模型生成的信号');
xlabel('样本点 n');
ylabel('幅值');
% 单曲线，无需图例
