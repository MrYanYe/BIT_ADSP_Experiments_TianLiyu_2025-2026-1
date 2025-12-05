% this program is to estimate the time delay using correlation technique
randn('state',1);
clear all;close all;
N=500;  % N is data number
M=20;  % M is the width of transmitted pulse signal
MN=100;% MN is the number of Monte_carlo simulation
N0=248; % N0 is true delay time
a=1.5;    % a is signal amplitude of pulse
sigma=1;
echo_signal=zeros(N,1);
transmit_signal=a*ones(M,1);
echo_signal(N0:(N0+M-1))=a;
Delayestimate_error=zeros(N,1);
for j=1:MN
  receive_signal=echo_signal+sigma.*randn(N,1);
  correl=zeros(N,1);
  for k=1:(N-M)
     correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1)));%k means n0'
  end
  [cmax,ctime]=max(correl);
  delayestimate_error(j)=ctime-N0;   % ctime is estimation of delay time
end
subplot(221)
plot(echo_signal)
title('echo signal')
axis([0 N 0 2*a])
subplot(222)
plot(receive_signal)
title('echo signal')
subplot(223)
plot(correl)
axis([0 N -100 150])
title('the output of correlator')
subplot(224)
plot(delayestimate_error)
title('error of delay estimation')
edges=[-100:0.5:100]
histogram(delayestimate_error,'Normalization','probability')
title('error of delay estmation');
var1=var(delayestimate_error);

