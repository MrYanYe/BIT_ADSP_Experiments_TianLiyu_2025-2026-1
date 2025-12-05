clear all;
close all;
rng(2); 
noieseAmp = 1;
N=1e6;
n=0
result1=zeros(1,100);
result2=zeros(1,100);
for i=1:100
noise = noieseAmp * randn(1, N) + 1i*noieseAmp * randn(1, N); %复高斯白噪声
noise_abs=abs(noise)
[n,index]=max(noise_abs);
result1(1,i)=length(noise_abs(noise_abs>5.728038))
result2(1,i)=n;
end
plot(result2);