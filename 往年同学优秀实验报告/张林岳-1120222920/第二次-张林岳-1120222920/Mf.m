clc;
clear;
randn('state',1);   %固定生成的随机信号
N=500;      %时间轴长度
M=20;       %脉冲宽度
N0=248;     %实际目标延时

a=input('a=');          %信号幅度
sigma=input('sigma=');  %噪声幅度

echo_signal=zeros(N,1);
transmit_signal=a*ones(M,1);    %脉冲信号
echo_signal(N0:(N0+M))=a;       %生成回波信号
receive_signal=echo_signal+sigma.*randn(N,1);   %将回波与噪声相加得到接收信号
correl=zeros(N,1);

for k=1:(N-M)
    correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1)));
end     %计算接收信号与脉冲信号的相关性，存放在 correl 中

[cmax,ctime]=max(correl);   %取出 correl 中最大值的索引
delay=ctime     % ctime 是估计的延时

subplot(311);
plot(echo_signal);
title(['a=' num2str(a),',simga=' num2str(sigma),'的回波信号']);
axis([0 N 0 3]);

subplot(312);
plot(receive_signal);
title(['a=' num2str(a),',simga=' num2str(sigma),'的接收信号']);

subplot(313);
plot(correl);
text(delay,correl(delay),['(',num2str(delay),',',num2str(correl(delay)),')']);  %在滤波输出图中标注出最大值及其时间
axis([0 N min(correl) max(correl)*1.1]);
title('相关滤波器的输出');