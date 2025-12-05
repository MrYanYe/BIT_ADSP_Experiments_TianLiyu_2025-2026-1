clc;
clear;
clf;
randn('state',1);

MN = 1000;     %蒙特卡洛仿真次数
%创建空矩阵 
phase_est1 = zeros(1, MN);       
phase_est2 = zeros(1, MN); 
phase_est3 = zeros(1, MN); 

N = 256;                %信号长度
phi_true = 30;          %信号初相，单位度
phase = deg2rad(phi_true);      %将角度转换为弧度，方便计算
T = input('T=');                %样本数据包含的周期
f0 = T/N;         %信号的数字频率
A = 1;            %信号幅度
sigmax2 = 1;      %噪声方差
ph_arr = 0 : 2*pi*f0 : (N-1)*2*pi*f0;
s0 = A*cos(ph_arr + phase);
% s0=A*exp(j*(ph_arr + phase));

%最大似然相关变量
sin_s = sin(ph_arr);   
cos_s = cos(ph_arr);  

%DFT相关变量(优化后)
    [I,D] = rat(T);%将k化成分数，其中I为分子，D为分母

%思路1：加窗抑制频谱泄露
    hm = 0.54 - 0.46*cos(2*pi*(0:N-1)/(N-1));   %汉明窗

%思路2：从实际测量值和理论正确值的关系入手，计算出泄露的影响并反推
    st = 0.5;   %映射关系的步长
    list = create_list(N, T, st);   %创建映射表

    %绘制理论计算值和参考值的映射关系图像
    figure(1);
    plot((0:st:180),list(1,:));     %绘制理论计算值
    hold on;
    plot((0:st:180),list(2,:));     %绘制参考值

%最小二乘相关变量
X0 = [A*cos_s;-A*sin_s].';%矩阵拼接再转置
X = pinv(X0.'*X0)*X0.';%矩阵求逆之后再相乘

for m = 1:MN 
    w = normrnd(0, sqrt(sigmax2), 1, N);        %噪声
    zn = s0 + w;

    %最大似然估计算法
    phase_est1(m) = rad2deg(-atan2(dot(zn, sin_s),dot(zn, cos_s)));%将弧度转换为角度，方便观察
 
    %DFT算法

    %优化前
%     Z = fft(zn);
%     [~,index] = max(abs(Z));
%     phase_est2(m) = rad2deg(angle(Z(index)));

%     %优化思路1
%     z = [zn.*hm,zeros(1,(D-1)*N)];
%     Z = fft(z);
%     phase_est2(m) = rad2deg(angle(Z(I+1)));   

    %优化思路2
    z = [zn,zeros(1,(D-1)*N)];
    Z = fft(z);
    phi_deg = rad2deg(angle(Z(I+1)));
    phase_est2(m) = list_find(list, phi_deg);

   %最小二乘算法
   Y = zn.';
   theta = X*Y;
   phase_est3(m) = rad2deg(atan2(theta(2),theta(1)));
  
end

%输出各算法估计结果，进行比对
fprintf('最大似然估计：\n  est_mean = %.4f\n  est_std = %.4f\n\n',mean(phase_est1),sqrt(var(phase_est1)));
fprintf('DFT估计：\n  est_mean = %.4f\n  est_std = %.4f\n\n',mean(phase_est2),sqrt(var(phase_est2)));
fprintf('最小二乘估计：\n  est_mean = %.4f\n  est_std = %.4f\n',mean(phase_est3),sqrt(var(phase_est3)));
%绘制三种方式的估计结果
figure(2);
subplot(311);
plot(phase_est1);
title('最大似然估计','FontSize',16);
subplot(312);
plot(phase_est2);
title('DFT估计','FontSize',16);
subplot(313);
plot(phase_est3);
title('最小二乘估计','FontSize',16);





%%
clc;clear;
N=256;              %例子中信号长度, N增大时，标准差减小【渐进有效估计】：256-5；512-3.7；1024-2.5；4096-1.25；16384-0.65；65536-0.32
phi_true = 30;  %正弦信号初相，单位度
phase = pi * phi_true / 180;
T=1.7;            %样本数据包含几个完整的正弦波周期, 非整周期采样时，k=1.X，性能下降，均值在5度内起伏；
f0=T/N;         %正弦波信号的数字频率
A = 1;          %信号幅度
sigmax2 = 1;    %WGN信号方差，修改这个参数就可以修改信噪比
ph_arr = 0 : 2*pi*f0 : (N-1)*2*pi*f0;
s0 = cos(ph_arr + phase);
w=0.54-0.46*cos(2*pi*(0:N-1)/(N-1));
[I,D]=numden(sym(T));
D=eval(D);
z=[s0.*w,zeros(1,(D-1)*N)];
X0=fft(z);
% for i=1:length(S)
%     if abs(S(i))<1
%         S(i)=0;
%     end
% end
subplot(311);
stem(s0);
subplot(312);
stem(w);
subplot(313);
stem((X0)*180/pi);
%%
clear;
N = 128;
n = 0 : N-1;
f = 10;
% [I,times] = rat(f);
% times = 128;
g = ones(1,N);
f=1/N;
s0=cos(2*pi*f*(0:N-1)).*g;
% g = hamming(N).';
plot(g);
G = fft(s0,1000*N);
G = round(G,5);
% G = circshift(G,3000);
figure;
subplot(311);
plot(abs(G));
phase = angle(G);
subplot(312);
plot(phase);
subplot(313);
phase_unwraped = unwrap(2*angle(G))/2;
plot(phase_unwraped);
%%
clc;
N=256;              %例子中信号长度, N增大时，标准差减小【渐进有效估计】：256-5；512-3.7；1024-2.5；4096-1.25；16384-0.65；65536-0.32
phi_true = 30;  %正弦信号初相，单位度
phase = pi * phi_true / 180;
T=1;            %样本数据包含几个完整的正弦波周期, 非整周期采样时，k=1.X，性能下降，均值在5度内起伏；
f0=T/N;         %正弦波信号的数字频率
A = 1;          %信号幅度
sigmax2 = 1;    %WGN信号方差，修改这个参数就可以修改信噪比
ph_arr = 0 : 2*pi*f0 : (N-1)*2*pi*f0;
s0 = A*cos(ph_arr + phase);
x=[s0,zeros(1,63*N)];
% w=-pi:0.00001*pi:pi;
% ph_arr=-(N/2):(N/2-1);
% X=s0*exp(-j*(0:N-1)'*w);

X0=fft(x);
X0=round(X0,5);
plot((1:length(X0))/length(X0)*2,angle(X0)*180/pi);
axis tight;
xlabel('\omega/\pi','FontSize',16,'FontWeight','bold');
title('phase','FontSize',16);
% X=fft(s0);
% X=round(X,5);
% plot((1:length(X)),angle(X));
% plot(angle(X));
% axis([0,N,-4,4]);
%%
clear;
close all;
% 参数设置
A = 1; % 信号幅度
f = 10.3; % 信号频率 (Hz)
phi = pi/6; % 信号的初相 (真实值)
Fs = 1000; % 采样频率 (Hz)
T = 1; % 信号持续时间 (秒)
t = 0:1/Fs:T-1/Fs; % 时间向量
% 生成带有高斯白噪声的信号
noise_level = 0.5; % 噪声标准差
n = noise_level * randn(size(t)); % 高斯白噪声
signal = A * cos(2 * pi * f * t + phi) + n;
% % 绘制信号
% figure;
% plot(t, signal);
% title('带噪声的正弦信号');
% xlabel('时间 (s)');
% ylabel('振幅');
% 矩估计法来估计初相
N = length(signal);
% 计算信号的二阶矩
M2 = mean(signal.^2);
% 估计幅度（幅度估计在信号功率中起到作用）
A_est = sqrt(2 * M2);
% 计算信号的一阶矩和二阶矩的偏移，来进行初相估计
cos_component = mean(signal .* cos(2 * pi * f * t));
sin_component = mean(signal .* sin(2 * pi * f * t));
% 初相估计
phi_est = atan2(-sin_component, cos_component);
% 打印结果
fprintf('真实初相: %.4f \n', rad2deg(phi));
fprintf('估计初相: %.4f \n', rad2deg(phi_est));
% 绘制估计信号与真实信号
estimated_signal = A_est * cos(2 * pi * f * t + phi_est);
figure;
plot(t, signal, 'b', t, estimated_signal, 'r');
legend('带噪声的信号', '估计信号');
title('信号与估计信号对比');
xlabel('时间 (s)');
ylabel('振幅');