clear all; close all;
sigma=1;
N=500;
r=0.5;
for i=1:N
u1=randn(1);
u2=randn(1);
X(i)=u1;
Y(i)=sigma*r*u1+sigma*sqrt(1-r^2)*u2;
end
subplot(221);
scatter(X,Y);
axis([-4 4 -4 4]);
cov(X, Y)	%互相关矩阵？协方差矩阵
r=-0.5;
for i=1:N
u1=randn(1);
u2=randn(1);
X(i)=u1;
Y(i)=sigma*r*u1+sigma*sqrt(1-r^2)*u2;
end
subplot(222);
scatter(X,Y);
axis([-4 4 -4 4])
cov(X, Y)	%互相关矩阵？

r=0.95;
for i=1:N
u1=randn(1);
u2=randn(1);
X(i)=u1;
Y(i)=sigma*r*u1+sigma*sqrt(1-r^2)*u2;
end
subplot(223);
scatter(X,Y);
axis([-4 4 -4 4]);
cov(X, Y)	%互相关矩阵？
r=-0.95;
for i=1:N
u1=randn(1);
u2=randn(1);
X(i)=u1;
Y(i)=sigma*r*u1+sigma*sqrt(1-r^2)*u2;
end
subplot(224);
scatter(X,Y);
axis([-4 4 -4 4])
cov(X, Y)	%互相关矩阵？
