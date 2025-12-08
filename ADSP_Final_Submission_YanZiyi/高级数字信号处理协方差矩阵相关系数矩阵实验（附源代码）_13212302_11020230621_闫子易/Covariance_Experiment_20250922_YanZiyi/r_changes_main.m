clear; close all; clc;

sigma = 1;
N = 100;

% 想要计算的相关系数，可以随意扩展
% r_values = [0.5, -0.5, 0.95, -0.95, 0.75, 0.8,-1]; 
r_values = [-1:0.05:1];

num_r = length(r_values);
num_rows = ceil(sqrt(num_r));
num_cols = ceil(num_r/num_rows);

for k = 1:num_r
    r = r_values(k);
    subplot(num_rows, num_cols, k);
    GenerateDataAndPlot(N, sigma, r);
end

PlotCorrelationAndCovariance(N, sigma, r_values);

%%

clear; close all; clc;
sigma = 1;
N = 100; 
num_vars = 5;   % 这里可以设置随机变量个数，比如 2, 5, 10, 20

% 想要计算的相关系数，可以随意扩展
r_values = [-1:0.5:1];
num_r = length(r_values);
num_rows = ceil(sqrt(num_r));
num_cols = ceil(num_r/num_rows);

for k = 1:num_r
    r = r_values(k);
    subplot(num_rows, num_cols, k);
    GenerateDataAndPlot(N, sigma, r, num_vars);
end