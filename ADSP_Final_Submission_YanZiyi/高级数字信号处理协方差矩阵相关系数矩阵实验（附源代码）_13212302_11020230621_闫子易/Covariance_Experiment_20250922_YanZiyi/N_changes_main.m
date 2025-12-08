clear; close all; clc;

sigma = 1;
N_values = [100:100:1000];

% 想要计算的相关系数，可以随意扩展
% r_values = [0.5, -0.5, 0.95, -0.95, 0.75, 0.8,-1]; 
r_values = 0.5;

num_r = length(N_values);
num_rows = ceil(sqrt(num_r));
num_cols = ceil(num_r/num_rows);

for k = 1:num_r
    N = N_values(k);
    subplot(num_rows, num_cols, k);
    GenerateDataAndPlot(N, sigma, r_values);
end

PlotCorrelationAndCovariance(N_values, sigma, r_values);

