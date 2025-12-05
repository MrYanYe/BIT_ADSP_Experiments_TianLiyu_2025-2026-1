% Author: Tian Liyu, BIT
% Date: 2024/10/18
% 罗鹏飞《随机信号分析与处理（第3版）》p224，例7.7 用mle估计正弦信号相位的仿真
% matlab ver: R2016b

clear all;
close all;
%rng(2);
M=250;     %蒙特卡洛仿真次数
%M=2;     %蒙特卡洛仿真次数

phase_est = zeros(1, M);        %各次估计的角度
phase_dft = zeros(1, M);

N=512;              %例子中信号长度, N增大时，标准差减小【渐进有效估计】：256-5；512-3.7；1024-2.5；4096-1.25；16384-0.65；65536-0.32
phase_degree = 30;  %正弦信号初相，单位度
phase = pi * phase_degree / 180;
k=1.2;            %样本数据包含几个完整的正弦波周期, 非整周期采样时，k=1.X，性能下降，均值在5度内起伏；
f0=k/N;         %正弦波信号的数字频率
A = 1;          %信号幅度
sigmax2 = 1;    %WGN信号方差，修改这个参数就可以修改信噪比
ph_arr = [0 : 2*pi*f0 : (N-1)*2*pi*f0];
s0 = cos(ph_arr + phase);
sin_s = sin(ph_arr);    %sin(2*pi*f0*n)
cos_s = cos(ph_arr);    %cos(2*pi*f0*n)
[I,times] = rat(k);

for m = 1:M
    w = normrnd(0, sqrt(sigmax2), 1, N);        %噪声信号
    zn = s0 + w;
    phase_est(m) = - atan2(dot(zn, sin_s) , dot(zn, cos_s));  
    
    signal_after_dft = fft(zn,N*times);
    phase_dft(m) = angle(signal_after_dft(I+1))*180/pi;
end
% figure(1)
% plot(zn)
% title('input signal')
phase_est_degree = phase_est * 180 / pi;

est_mean = mean(phase_est_degree)
est_var = var(phase_est_degree)
est_std = sqrt(est_var)
[f, xi] = ksdensity(phase_est_degree);   %PDF
figure(2)
subplot(2,1,1)
plot(phase_est_degree)
title('est phase(degree)')
subplot(2,1,2)
plot(phase_dft)
dft_est_mean = mean(phase_dft)

% plot(xi, f)
% title('PDF')




return;




