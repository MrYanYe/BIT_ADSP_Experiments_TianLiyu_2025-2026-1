clear; clc; rng(0);

N = 100;
sigma = 1;
r = 0.9;

% 关键点：只生成一次 u1, u2，并共享
u1 = randn(N,1);
u2 = randn(N,1);

X = 1 + 2*u1;
Y = sigma*r*u1 + sigma*sqrt(1 - r^2)*u2;

C = cov([X, Y]);        % N×2，列是变量
R = corrcoef([X, Y]);   % N×2，列是变量

disp('协方差矩阵（应接近 [4, 2r; 2r, 1]）：');
disp(C);
disp('相关系数矩阵（应接近 [1, r; r, 1]）：');
disp(R);
