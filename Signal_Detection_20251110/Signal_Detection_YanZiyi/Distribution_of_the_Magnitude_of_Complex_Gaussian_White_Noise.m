% Distribution_of_the_Magnitude_of_Complex_Gaussian_White_Noise

clc; clear; close all;

% 固定随机数种子
rng(2);

% 生成 10^6 个复高斯白噪声
N = 1e6;
x = randn(N,1) + 1i*randn(N,1);

% 取模
r = abs(x);

% 绘制分布图（直方图）
figure;
h = histogram(r, 'Normalization', 'pdf', 'BinWidth', 0.05);
xlabel('幅度');
ylabel('概率密度');
title('复高斯白噪声取模后的分布');
hold on;

% 理论分布对比：Rayleigh 分布
sigma = 1; % randn 默认方差=1
r_vals = linspace(0,6,200);
pdf_rayleigh = (r_vals./sigma.^2).*exp(-r_vals.^2/(2*sigma.^2));
plot(r_vals, pdf_rayleigh, 'r', 'LineWidth', 2);
legend('模拟结果','Rayleigh理论分布');

% 计算直方图各 bin 的中心和最大值位置
edges = h.BinEdges;
centers = (edges(1:end-1) + edges(2:end)) / 2;
[peakVal, idxPeak] = max(h.Values);
peakX = centers(idxPeak);
peakY = peakVal;

% 在图中标注最高点坐标
plot(peakX, peakY, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
labelStr = sprintf('(%0.3f, %0.3f)', peakX, peakY);
% 将文字放在点的右上方，避免与曲线重叠
textOffsetX = 0.15; % 横向偏移
textOffsetY = 0.05 * max(h.Values); % 纵向偏移
text(peakX + textOffsetX, peakY + textOffsetY, labelStr, 'FontSize', 10, 'FontWeight', 'bold');

hold off;
