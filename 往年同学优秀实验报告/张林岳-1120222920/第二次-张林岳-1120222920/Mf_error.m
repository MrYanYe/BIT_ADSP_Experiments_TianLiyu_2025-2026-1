clc;
clear;
randn('state',1);
N=500;      %信号长度
M=20;       %脉冲宽度
MN=5000;    %蒙特卡洛仿真的次数
N0=248;     %脉冲的位置
a=1.5;      %信号振幅
sigma=input('sigma=');  %输入噪声的振幅

echo_signal=zeros(N,1);
transmit_signal=a*ones(M,1);
echo_signal(N0:(N0+M-1))=a;

for j=1:MN
    receive_signal=echo_signal+sigma.*randn(N,1);   %接收信号
    correl=zeros(N,1);
    for k=1:(N-M)
        correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1)));
    end
    [cmax,ctime]=max(correl);
    delayestimate_error(j)=ctime-N0;    %将估计延时与实际延时的误差存入 d_e 矩阵中
end
subplot(231);
plot(echo_signal);
title(['a=' num2str(a),',simga=' num2str(sigma),'的回波信号(最后一次仿真)']);
axis([0 N 0 2*a]);

subplot(234);
plot(receive_signal);
title(['a=' num2str(a),',simga=' num2str(sigma),'的接收信号(最后一次仿真)']);

subplot(232);
plot(correl);
axis([0 N -100 150]);
title('相关滤波器的输出');

subplot(235);
plot(delayestimate_error);
title('延时估计的误差');
                    
subplot(133);
histogram(delayestimate_error);     %用 hist 函数统计各误差值出现的次数
title(['simga=' num2str(sigma),'时各误差值出现的次数']);
%%
%探究均值、方差和sigma的关系
clc;
clear;
randn('state',1);
N=1000;     
M=20; 
MN=5000;    
N0=496;
a=1.5;  

echo_signal=zeros(N,1);
transmit_signal=a*ones(M,1);
echo_signal(N0:(N0+M-1))=a;

for s=0:150
    sigma=s;
    for j=1:MN
      receive_signal=echo_signal+sigma.*randn(N,1);
      correl=zeros(N,1);    
      for k=1:(N-M)
         correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1)));
      end
      [cmax,ctime]=max(correl);
      delayestimate_error(j)=ctime-N0;  %将估计延时与实际延时的误差存入d_e矩阵中
    end
    E(s+1)=mean(delayestimate_error);   %计算均值
    D(s+1)=var(delayestimate_error);    %计算方差
end

% subplot(121);
% plot((0:s),E);
% xlabel('sigma','FontSize',16);
% title('均值','FontSize',16);
% subplot(122);
plot((0:s),D);
xlabel('sigma','FontSize',16);
title('方差','FontSize',16);