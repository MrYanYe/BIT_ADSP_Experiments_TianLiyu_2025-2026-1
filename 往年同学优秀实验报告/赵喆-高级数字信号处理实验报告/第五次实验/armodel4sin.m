clear;
N = 100;
F1 = 0.15;  % 第一个正弦波频率
F2 = 0.16; % 第二个正弦波频率
n = 0:N-1;

theta1 = 2*pi*rand();
theta2 = 2*pi*rand();

x = sin(2*pi*F1*n+theta1) + 1*sin(2*pi*F2*n+theta2); % 两个正弦波叠加
noisestd = 0.5;  % 高斯白噪声标准差
x = x + noisestd * randn(1, N); % 添加高斯白噪声

% x = ar_generate(N,3,[0.3,-0.14,0.11],0.02);

p = 35;

% 接下来计算p阶自相关
% 先划定训练集
train_ratio = 0.5;
train_data_size = floor(N*train_ratio);
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
figure;
error = y_pred - x;
plot(error);
hold on;
plot(train_data_size,error(train_data_size),'r*');

sigma2 = acf(train_data_size) - sum(ar_coeff .* acf(train_data_size+1:train_data_size+p)); % 预测误差方差

% 计算 AR 模型的功率谱密度
freqs = linspace(0, 1, 1000);  % 归一化频率范围 [0, 0.5]
psd_ar = zeros(size(freqs));
for i = 1:length(freqs)
    f = freqs(i);
    H = 1 ./ (1 - sum(ar_coeff .* exp(-1j * 2 * pi * f * (1:p)))); % 传递函数
    psd_ar(i) = sigma2 * abs(H)^2;  % PSD 公式
end

% 绘制功率谱
figure;
% subplot(311);
plot(freqs, (psd_ar), 'b', 'LineWidth', 1.5);
% subplot(312);
figure;
win = hamming(length(train_data));
plot((abs(fft(train_data .* win', 10*train_data_size)).^2+0.01)/train_data_size, 'b', 'LineWidth', 1.5);
% subplot(313);

% plot(abs(fft(acf, 10*train_data_size)), 'b', 'LineWidth', 1.5);

figure;
% 绘制零极点
ar_poly = [1, -ar_coeff];
zplane(1, ar_poly);

figure;
x2 = ar_generate(1*N,p,ar_coeff,0.0);
plot(x2);
