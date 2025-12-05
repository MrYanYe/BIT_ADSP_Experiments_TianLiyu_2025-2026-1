% this program is to estimate the time delay using correlation technique
clear all
N=500;  % N is data number
M=20;  % M is a width of transmitted pulse signal
N0=248; % N0 is true delay time
a=2;    % a is signal amplitude of pulse
sigma=1;
echo_signal=zeros(N,1);
transmit_signal=a*ones(M,1);
echo_signal(N0:(N0+M-1))=a;
% receive_signal=echo_signal+sigma.*randn(N,1);
SNR = -0;
receive_signal = awgn(echo_signal,SNR);
correl=zeros(N,1);
for k=1:(N-M)
   correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1)));%k means n0'
end
[cmax,ctime]=max(correl);
delay=ctime   % ctime is estimation of delay time
subplot(3,1,1)
plot(echo_signal)
title('echo signal')
axis([0 N 0 3])
subplot(3,1,2)
plot(receive_signal)
title('receive signal')
subplot(3,1,3)
plot(correl)
axis([0 N -100 150])
title('output of correlator')
