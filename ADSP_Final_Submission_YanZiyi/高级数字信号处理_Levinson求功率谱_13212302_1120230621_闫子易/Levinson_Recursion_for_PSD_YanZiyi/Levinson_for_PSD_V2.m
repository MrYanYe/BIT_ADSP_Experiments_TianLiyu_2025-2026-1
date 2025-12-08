clc;
clear;
close all;
rng('default');
rng(2920);

fs = 1000;                  % 采样率
f1 = 100;                   % 信号分量1频率
f2 = 140;                   % 信号分量2频率
f3 = 405;                   % 信号分量3频率
signal_len = 32;           % 序列长度（原N）
nfft_len = 32;             % FFT点数（原Nfft）
SNR = -1;                   % 信噪比
freq_idx = 0:nfft_len-1;    % FFT频率索引（原f）
time_seq = 0:1/fs:(signal_len-1)/fs;  % 时间序列（原n）
A1 = 1;                     % 分量1振幅
A2 = 1;                     % 分量2振幅
A3 = 1;                     % 分量3振幅
p = 16;  % 模型阶数（原p）

max_dots_number = 3;

% 生成多频合成信号
signal = A1*cos(2*pi*f1*time_seq) + A2*cos(2*pi*f2*time_seq) + A3*cos(2*pi*f3*time_seq);
signal_noisy = awgn(signal, SNR);  % 添加噪声（原x）

% DFT求解功率谱
fft_result = fft(signal_noisy, nfft_len);  % 原X
power_spectrum_dft = fft_result .* conj(fft_result);  % 功率谱计算
power_spectrum_dft = power_spectrum_dft(1:length(power_spectrum_dft)/2);  % 取正频率部分
power_spectrum_dft = abs(power_spectrum_dft);  % 幅值

% 绘制DFT频谱图
subplot(121);
norm_freq_dft = (1:length(power_spectrum_dft))/length(power_spectrum_dft)/2;  % DFT归一化频率
dft_db = 10*log10(power_spectrum_dft/max(power_spectrum_dft));
plot(norm_freq_dft, dft_db, 'b-','LineWidth',1);
xlabel('归一化频率(\omega/2\pi)','FontWeight','bold','FontSize',16);
ylabel('归一化幅值(dB)');
title('DFT求频谱','FontSize',16);
grid on;
hold on;

% 找出DFT谱中最高的四个峰并标注
[pks, locs] = findpeaks(dft_db, norm_freq_dft);  % locs 返回对应的 x 值
if isempty(pks)
    % 若没有检测到峰，改为直接取最大值的四个索引
    [~, idx_sorted] = sort(dft_db, 'descend');
    topN = min(max_dots_number, length(idx_sorted));
    top_idx = idx_sorted(1:topN);
    top_x = norm_freq_dft(top_idx);
    top_y = dft_db(top_idx);
else
    % 按幅值排序并取前max_dots_number个
    [pks_sorted, sort_idx] = sort(pks, 'descend');
    topN = min(max_dots_number, length(pks_sorted));
    top_x = locs(sort_idx(1:topN));
    top_y = pks_sorted(1:topN);
end

% 绘制红点并标注坐标（避免重叠：对每个标签做小偏移）
marker_offsets = [0.000, 0.5, -0.5, 1.0];  % dB 偏移（可调整）
for k = 1:length(top_x)
    plot(top_x(k), top_y(k), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
    % 选择左右对齐以减少重叠
    if mod(k,2)==1
        halign = 'left';
        xoff = 0.002;
    else
        halign = 'right';
        xoff = -0.002;
    end
    yoff = marker_offsets(min(k,length(marker_offsets)));
    txt = sprintf('(%0.4f, %0.1f dB)', top_x(k), top_y(k));
    text(top_x(k)+xoff, top_y(k)+yoff, txt, 'FontSize', 10, 'Color', 'r', ...
         'HorizontalAlignment', halign, 'VerticalAlignment', 'bottom', 'Interpreter', 'none');
end
hold off;

% AR模型参数

% 利用列文森递推求解AR模型系数和最小预测误差功率
[ar_coeff, min_pred_error_power] = Levinson(signal_noisy, p);
% 根据AR系数计算功率谱
[freq_response, freq_vec] = freqz(sqrt(min_pred_error_power), [1, ar_coeff], signal_len);  % 原[H,w]
power_spectrum_ar = abs(freq_response).^2;  % 原Px
norm_freq_ar = freq_vec/(2*pi);  % AR谱归一化频率（原fb）
power_spectrum_ar = power_spectrum_ar/max(power_spectrum_ar);
power_spectrum_ar_db = 10*log10(power_spectrum_ar);

% 绘制AR频谱图
subplot(122);
plot(norm_freq_ar, power_spectrum_ar_db, 'b-','LineWidth',1);
xlabel('归一化频率(\omega/2\pi)','FontWeight','bold','FontSize',16);
ylabel('归一化幅值(dB)');
title_str = sprintf('Levinson求解AR频谱( p = %d, SNR = %ddB )', p,SNR);
title(title_str,'FontSize',16);

grid on;
hold on;

% 找出AR谱中最高的四个峰并标注
[pks_ar, locs_ar] = findpeaks(power_spectrum_ar_db, norm_freq_ar);
if isempty(pks_ar)
    [~, idx_sorted_ar] = sort(power_spectrum_ar_db, 'descend');
    topN_ar = min(max_dots_number, length(idx_sorted_ar));
    top_idx_ar = idx_sorted_ar(1:topN_ar);
    top_x_ar = norm_freq_ar(top_idx_ar);
    top_y_ar = power_spectrum_ar_db(top_idx_ar);
else
    [pks_ar_sorted, sort_idx_ar] = sort(pks_ar, 'descend');
    topN_ar = min(max_dots_number, length(pks_ar_sorted));
    top_x_ar = locs_ar(sort_idx_ar(1:topN_ar));
    top_y_ar = pks_ar_sorted(1:topN_ar);
end

% 绘制红点并标注坐标（避免重叠）
marker_offsets_ar = [0.0, 0.8, -0.8, 1.2];
for k = 1:length(top_x_ar)
    plot(top_x_ar(k), top_y_ar(k), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
    if mod(k,2)==1
        halign = 'left';
        xoff = 0.002;
    else
        halign = 'right';
        xoff = -0.002;
    end
    yoff = marker_offsets_ar(min(k,length(marker_offsets_ar)));
    txt = sprintf('(%0.4f, %0.1f dB)', top_x_ar(k), top_y_ar(k));
    text(top_x_ar(k)+xoff, top_y_ar(k)+yoff, txt, 'FontSize', 10, 'Color', 'r', ...
         'HorizontalAlignment', halign, 'VerticalAlignment', 'bottom', 'Interpreter', 'none');
end
hold off;







% ------------------ 绘制 delta^2 与 p 的关系曲线 ------------------
max_p_plot = p;                % 要扫描的最大阶数（可调整）
delta2 = zeros(1, max_p_plot);   % 存储每个阶数的最小预测误差功率

% 逐阶调用 Levinson 计算最小预测误差功率
for pp = 1:max_p_plot
    [~, min_err] = Levinson(signal_noisy, pp);
    delta2(pp) = min_err;
end

% 绘图：线性刻度
figure;
plot(1:max_p_plot, delta2, 'b-','LineWidth',1.2);
xlabel('阶数 P','FontWeight','bold','FontSize',14);
ylabel('\delta^2 (最小预测误差功率)','FontSize',14);
grid on;
title_str = sprintf('N=%d 时 \\delta^2 与阶数 P 的关系 (Levinson)  SNR=%d dB', signal_len, SNR);
title(title_str,'FontSize',14);
















% ---------------- 定义要绘制的 SNR 列表（长度自适应） ----------------
SNR_list = [-5,0, 5, 10, 15, 20];   % 你可以任意修改为行向量，长度会自动适配

% ------------- 为每个 SNR 计算并绘制 AR 频谱（替换原 subplot(122) 部分） -------------
figure;   % 新建图窗用于 AR 频谱比较
colors = lines(length(SNR_list));   % 自动生成足够的颜色
hold on;
legend_entries = cell(1, length(SNR_list));

for iS = 1:length(SNR_list)
    curSNR = SNR_list(iS);
    % 重新生成带噪信号（保持原始无噪信号 signal 不变）
    signal_noisy_cur = awgn(signal, curSNR);

    % Levinson 求解 AR 系数与最小预测误差功率
    [ar_coeff_cur, min_pred_error_power_cur] = Levinson(signal_noisy_cur, p);

    % 计算频率响应与功率谱（使用与原来相同的点数 signal_len）
    [freq_response_cur, freq_vec_cur] = freqz(sqrt(min_pred_error_power_cur), [1, ar_coeff_cur], signal_len);
    power_spectrum_ar_cur = abs(freq_response_cur).^2;
    power_spectrum_ar_cur = power_spectrum_ar_cur / max(power_spectrum_ar_cur);   % 归一化
    power_spectrum_ar_db_cur = 10*log10(power_spectrum_ar_cur);

    % 归一化频率轴
    norm_freq_ar_cur = freq_vec_cur/(2*pi);

    % 绘制曲线
    plot(norm_freq_ar_cur, power_spectrum_ar_db_cur, 'Color', colors(iS,:), 'LineWidth', 1.2);
    legend_entries{iS} = sprintf('SNR=%d dB', curSNR);
end

% 图形美化
xlabel('归一化频率(\omega/2\pi)','FontWeight','bold','FontSize',16);
ylabel('归一化幅值(dB)','FontSize',14);
title_str = sprintf('Levinson 求解 AR 频谱（不同 SNR 比较）( p = %d )', p);
title(title_str,'FontSize',16);

grid on;
legend(legend_entries, 'Location', 'best');
hold off;

















% ---------------- 多 SNR 下 delta^2 与 p 的关系 ----------------
% SNR_list = [0, 5, 10, 15, 20];   % 自适应长度的 SNR 列表，按需修改

max_p_plot = p;                  % 要扫描的最大阶数（保持原 p）
numSNR = length(SNR_list);
delta2_all = zeros(numSNR, max_p_plot);  % 每行对应一个 SNR 的 delta^2 曲线

% 逐个 SNR 计算 delta^2
for iS = 1:numSNR
    curSNR = SNR_list(iS);
    % 重新生成带噪信号（保持原始无噪信号 signal 不变）
    signal_noisy_cur = awgn(signal, curSNR);

    % 逐阶调用 Levinson 计算最小预测误差功率
    for pp = 1:max_p_plot
        [~, min_err] = Levinson(signal_noisy_cur, pp);
        delta2_all(iS, pp) = min_err;
    end
end

% 绘图：在同一张图上绘制不同 SNR 的曲线
figure;
colors = lines(numSNR);   % 自动生成颜色
hold on;
legend_entries = cell(1, numSNR);

for iS = 1:numSNR
    plot(1:max_p_plot, delta2_all(iS, :), 'Color', colors(iS,:), 'LineWidth', 1.5);
    legend_entries{iS} = sprintf('SNR=%d dB', SNR_list(iS));
end

xlabel('阶数 P','FontWeight','bold','FontSize',14);
ylabel('\delta^2 (最小预测误差功率)','FontSize',14);
grid on;
title_str = sprintf('N=%d 时 \\delta^2 与阶数 P 的关系 (不同 SNR)', signal_len);
title(title_str,'FontSize',14);
legend(legend_entries, 'Location', 'best');
set(gca, 'YScale', 'linear');   % 若数值跨越大，可改为 'log' 或 semilogy 绘制
hold off;




% % 在图上标注拐点或最后值（可选）
% hold on;
% plot(max_p_plot, delta2(max_p_plot), 'ro', 'MarkerFaceColor','r');
% text(max_p_plot, delta2(max_p_plot), sprintf('  P=%d, \\delta^2=%0.3e', max_p_plot, delta2(max_p_plot)), ...
%      'FontSize',8, 'Color','r', 'HorizontalAlignment','center', 'VerticalAlignment','bottom');
% hold off;

% % 可选：用对数刻度（若数值跨越很大，建议使用）
% figure;
% semilogy(1:max_p_plot, delta2, 'b-','LineWidth',1.2);
% xlabel('阶数 P','FontWeight','bold','FontSize',14);
% ylabel('\delta^2 (对数刻度)','FontSize',14);
% grid on;
% title([title_str '  (对数刻度)'],'FontSize',14);






% Levinson 函数
function [ar_coeff, min_pred_error_power] = Levinson(input_signal, p)
    autocorr = xcorr(input_signal, 'biased');
    autocorr_vals = zeros(1, p + 1);
    signal_len = length(input_signal);
    for idx = 1:p + 1
        autocorr_vals(idx) = autocorr(signal_len + idx - 1);
    end

    ar_coeff_matrix = zeros(p, p);
    pred_error_power = zeros(1, p);
    reflection_coeff = zeros(1, p);

    ar_coeff_matrix(1,1) = -autocorr_vals(2) / autocorr_vals(1);
    pred_error_power(1) = autocorr_vals(1) * (1 - (ar_coeff_matrix(1,1))^2);
    reflection_coeff(1) = ar_coeff_matrix(1,1);

    for curr_order = 2:p
        ar_coeff_matrix(curr_order, curr_order) = -autocorr_vals(curr_order + 1) / pred_error_power(curr_order - 1);
        for idx = 1:curr_order - 1
            ar_coeff_matrix(curr_order, curr_order) = ar_coeff_matrix(curr_order, curr_order) ...
                - (ar_coeff_matrix(curr_order - 1, idx) * autocorr_vals(curr_order + 1 - idx)) / pred_error_power(curr_order - 1);
        end
        reflection_coeff(curr_order) = ar_coeff_matrix(curr_order, curr_order);
        if (abs(reflection_coeff(curr_order)) >= 1)
            break;
        end
        for idx = 1:curr_order - 1
            ar_coeff_matrix(curr_order, idx) = ar_coeff_matrix(curr_order - 1, idx) ...
                + reflection_coeff(curr_order) * ar_coeff_matrix(curr_order - 1, curr_order - idx);
        end
        pred_error_power(curr_order) = pred_error_power(curr_order - 1) * (1 - (reflection_coeff(curr_order))^2);
    end

    ar_coeff = zeros(1, p);
    for idx = 1:p
        ar_coeff(idx) = ar_coeff_matrix(p, idx);
    end
    min_pred_error_power = pred_error_power(p);
end
