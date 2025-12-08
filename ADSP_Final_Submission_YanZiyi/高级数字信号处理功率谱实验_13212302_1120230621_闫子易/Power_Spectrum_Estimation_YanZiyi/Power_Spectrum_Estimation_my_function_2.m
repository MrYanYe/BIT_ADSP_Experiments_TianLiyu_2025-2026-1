% 自写周期图与自相关法功率谱估计（含峰值标注优化）
clear; clc; close all;

f1 = 300; f2 = 305; 
fs = 1000; % 采样率
dt = 1/fs;
Td = 3.0; % 信号时间长度
t = 0:dt:Td;
x = cos(2*pi*t*f1) + cos(2*pi*t*f2) + randn(size(t));
% x = cos(2*pi*t*f1) + randn(size(t));
nfft = 2^11;
fprintf('f1 = %d, f2 = %d, fs = %d \n', f1,f2,fs );
fprintf('Td = %f, nfft = %d \n', Td, nfft );

% ---------- 周期图功率谱估计（计时） ----------
tic;
[Pwd1, ff1] = myPeriodogram(x, nfft, fs);
time_periodogram = toc;
fprintf('Periodogram computation time: %.6f seconds\n', time_periodogram);

% ---------- 自相关功率谱估计（计时） ----------
tic;
[Pwd3, ff3] = myAutocorrPSD(x, nfft, fs);
time_autocorr_fft = toc;
fprintf('Autocorrelation+FFT computation time: %.6f seconds\n', time_autocorr_fft);

% ---------- 绘图 ----------
fUB = fs/2; fLB = 0;
upperB = 0; lowerB = -50;

figure;
sgtitle({ '功率谱估计比较图', sprintf('f1 = %d, f2 = %d, fs = %d, Td = %.6f, nfft = %d', f1, f2, fs, Td, nfft) }, 'FontSize', 12);

%% -------- (1) 周期图功率谱 --------
subplot(2,1,1);
plot(ff1, 10*log10(Pwd1), 'b'); hold on;
title('周期图功率谱估计 (自写函数)');
xlabel('频率 (Hz)');
ylabel('功率谱密度 (dB/Hz)');
xlim([fLB fUB]); ylim([lowerB upperB]); grid on;

% 寻找最大两个峰值
[pks1, locs1] = findpeaks(10*log10(Pwd1), ff1, 'SortStr', 'descend');
num_peaks = min(2, length(pks1));
pks1 = pks1(1:num_peaks);
locs1 = locs1(1:num_peaks);

% 定义颜色（第一个红，第二个绿）
colors = {'r','g'};

% 标注峰值
for i = 1:num_peaks
    plot(locs1(i), pks1(i), 'o', 'MarkerFaceColor', colors{i}, ...
        'MarkerEdgeColor', colors{i}, 'MarkerSize', 4);

    if num_peaks > 1 && abs(locs1(i) - mean(locs1)) < 10
        text(locs1(i)+5, pks1(i)+(-1)^(i)*3, ...
            sprintf('(%.1f Hz, %.1f dB)', locs1(i), pks1(i)), ...
            'Color', colors{i}, 'FontSize',9,'HorizontalAlignment','center');
    else
        text(locs1(i)+5, pks1(i), ...
            sprintf('(%.1f Hz, %.1f dB)', locs1(i), pks1(i)), ...
            'Color', colors{i}, 'FontSize',9,'HorizontalAlignment','center');
    end
end


%% -------- (2) 自相关功率谱 --------
subplot(2,1,2);
plot(ff3, 10*log10(Pwd3), 'b'); hold on;
title('自相关功率谱估计 (自写函数)');
xlabel('频率 (Hz)');
ylabel('功率谱密度 (dB/Hz)');
xlim([fLB fUB]); ylim([lowerB upperB]); grid on;

% 寻找最大两个峰值
[pks3, locs3] = findpeaks(10*log10(Pwd3), ff3, 'SortStr', 'descend');
num_peaks = min(2, length(pks3));
pks3 = pks3(1:num_peaks);
locs3 = locs3(1:num_peaks);

% 定义颜色（第一个红，第二个绿）
colors = {'r','g'};

% 标注峰值
for i = 1:num_peaks
    plot(locs3(i), pks3(i), 'o', 'MarkerFaceColor', colors{i}, ...
        'MarkerEdgeColor', colors{i}, 'MarkerSize', 4);

    if num_peaks > 1 && abs(locs3(i) - mean(locs3)) < 10
        text(locs3(i)+5, pks3(i)+(-1)^(i)*3, ...
            sprintf('(%.1f Hz, %.1f dB)', locs3(i), pks3(i)), ...
            'Color', colors{i}, 'FontSize',9,'HorizontalAlignment','center');
    else
        text(locs3(i)+5, pks3(i), ...
            sprintf('(%.1f Hz, %.1f dB)', locs3(i), pks3(i)), ...
            'Color', colors{i}, 'FontSize',9,'HorizontalAlignment','center');
    end
end



%% ================= 子函数 =================

% -------- 周期图法 --------
function [Pxx, f] = myPeriodogram(x, nfft, fs)
    N = length(x);
    X = fft(x, nfft);              % FFT
    Pxx = (1/(N*fs)) * abs(X).^2;  % 功率谱密度
    Pxx = Pxx(1:nfft/2+1);         % 单边谱
    Pxx(2:end-1) = 2*Pxx(2:end-1); % 单边能量补偿
    f = (0:nfft/2) * fs/nfft;      % 频率轴
end

% -------- 自相关法 --------
function [Pxx, f] = myAutocorrPSD(x, nfft, fs)
    N = length(x);
    % 手动计算有偏自相关
    R = zeros(1, 2*N-1);
    for k = -(N-1):(N-1)
        idx = k + N; % shift index
        if k >= 0
            R(idx) = sum(x(1:N-k) .* x(1+k:N)) / N;
        else
            R(idx) = sum(x(1-k:N) .* x(1:N+k)) / N;
        end
    end
    % FFT 得到功率谱
    S = fft(R, nfft);
    Pxx = abs(S)/fs;
    Pxx = Pxx(1:nfft/2+1);         % 单边谱
    Pxx(2:end-1) = 2*Pxx(2:end-1); % 单边能量补偿
    f = (0:nfft/2) * fs/nfft;      % 频率轴
end
