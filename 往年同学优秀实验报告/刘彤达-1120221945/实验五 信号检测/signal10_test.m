clear all;
close all;
rng(2); 
noieseAmp = 1;
N=1e6;
n=0
result1=zeros(1,10);
result2=zeros(1,10);
for i=1:10
noise = noieseAmp * randn(1, N) + 1i*noieseAmp * randn(1, N); %复高斯白噪声
noise_abs=abs(noise)
[n,index]=max(noise_abs);
result1(1,i)=length(noise_abs(noise_abs>5.13894));
result2(1,i)=n;
end
% result1(1,i)=n;
% result2(1,i)=index;
% result1_trans=transpose(result1);
% plot(result1);
% plot(noise_abs);
% plot(n);index=399290
% temp=zeros(1,21);
% for i=1:21
% temp(1,i)=noise_abs(1,399280+i-1);
% end
% a=(sum(temp)-5.1846)/20;
% b=5.1846/a;
% subplot(2,1,1);
% plot(noise_abs);
% subplot(2,1,2);
% plot(temp);