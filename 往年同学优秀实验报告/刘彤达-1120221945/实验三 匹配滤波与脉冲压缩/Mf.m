% this program is to estimate the time delay using correlation technique
clear all
N=500;  % N is data number
M=20;  % M is a width of transmitted pulse signal
N0=248; % N0 is true delay time
a=10;    % a is signal amplitude of pulse%信号的幅度
sigma=5;%噪声的幅度
echo_signal=zeros(N,1);
transmit_signal=a*ones(M,1);
echo_signal(N0:(N0+M))=a;
receive_signal=echo_signal+sigma.*randn(N,1);
correl=zeros(N,1);
for k=1:(N-M)
   correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1)));%k means n0'
end
[cmax,ctime]=max(correl);
delay=ctime   % ctime is estimation of delay time
subplot(3,1,1)
plot(echo_signal)
title('echo signal')
axis([0 N 0 5])
subplot(3,1,2)
plot(receive_signal)
title('receive signal')
subplot(3,1,3)
plot(correl)
axis([0 N -1000 2000])
title('output of correlator')

