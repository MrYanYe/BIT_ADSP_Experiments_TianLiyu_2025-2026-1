clear all
close all

%==========
f=[ 0.5 0.52 0.54 ];%%%更改谐波数量 可以增加多个谐波频率 观察是否可以分辨出来。
figure(9)
var=0.1;
dat=gen(f,var,24);
m=8;
p=3;%%%记得更改这里 代表谐波的个数
rh=pmusic(dat,p,m,2^10);
subplot(2,1,1);
plot(rh);
msg=['MUSIC算法 m=' num2str(m) ' 噪声方差=' num2str(var)];
title(msg)
m=16;
rh=pmusic(dat,p,m,2^10);
subplot(2,1,2);
plot(rh);
msg=['MUSIC算法 m=' num2str(m) ' 噪声方差=' num2str(var)];
title(msg)
