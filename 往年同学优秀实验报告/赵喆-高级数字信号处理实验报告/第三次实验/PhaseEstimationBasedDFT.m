clear;clc;close all;
N = 512;
F = 1;
n = 0:N-1;
A = 1;
psi_deg = 27.5;
psi = deg2rad(psi_deg);
[I,times] = rat(F);
MN = 512;
phase_estimate1 = zeros(1,MN);
phase_estimate2 = zeros(1,MN);
phase_estimate3 = zeros(1,MN);
phase_est = zeros(1,MN);
sigmax2 = 1;

% CRLB = 2*sigmax2/(N*A^2)*(180/pi)^2;

F1 = F + 0.0;

x0 = A * cos(2*pi*F*n/N + psi);
% X = fft(x, N*times);
% phi = angle(X(I+1));
% phi_deg = rad2deg(phi);

sin_s = sin(2*pi*F1*n/N);    %sin(2*pi*f0*n)
cos_s = cos(2*pi*F1*n/N);    %cos(2*pi*f0*n)

lookup_table = generate_lookup_table(N, F1); %由N和F唯一确定的查找表

% 下面的蒙特卡洛仿真综合了三种方法，进行对比
% 1、DFT法
% 2、最小二乘法
% 3、加hamming窗

for m = 1:MN
    w = normrnd(0, sqrt(sigmax2), 1, N);        %噪声信号
    x = x0 + w;
    X = fft(x,N*times);
    phi = angle(X(I+1));
    phi_deg = rad2deg(phi);
    
    phase_est(m) = rad2deg(- atan2(dot(x, sin_s) , dot(x, cos_s)));
    % phase_estimate(m) = find_psi(phi_deg,N,F);
%     phase_est = phi_deg;
    phase_estimate1(m) = PhaseLMS(x, F1/N, 0);
    phase_estimate2(m) = find_psi_from_table(lookup_table, phase_est(m));% 把dft计算出的相位放进去查表，从而消除影响。
    
    window = hamming(N).';
    x_windowed = x .* window;
    Xw = fft(x_windowed,N*times);
    phi3 = angle(Xw(I+1));
    phase_estimate3(m) = rad2deg(phi3);
end

% figure;
% plot(x);

% figure;

meanvalue1 = mean(phase_estimate1);
variance1 = var(phase_estimate1);
std1 = sqrt(variance1);
% subplot(311);
% plot(phase_estimate1);
% title('最小二乘法');

meanvalue2 = mean(phase_estimate2);
variance2 = var(phase_estimate2);
std2 = sqrt(variance2);
% subplot(312);
% plot(phase_estimate2);
% title('改进后的最大似然法');


meanvalue3 = mean(phase_estimate3);
variance3 = var(phase_estimate3);
std3 = sqrt(variance3);
% subplot(313);
% plot(phase_estimate3);
% title('加窗法');

meanvalue = mean(phase_est);
variance = var(phase_est);
std = sqrt(phase_est);

m_ = [meanvalue;meanvalue1;meanvalue2;meanvalue3];
v_ = [variance;variance1;variance2;variance3];


