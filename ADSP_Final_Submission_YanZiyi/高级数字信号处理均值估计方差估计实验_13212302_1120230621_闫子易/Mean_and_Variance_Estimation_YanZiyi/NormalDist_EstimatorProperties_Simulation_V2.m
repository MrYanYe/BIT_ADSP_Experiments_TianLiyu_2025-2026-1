clear; clc; close all;

% 真实参数
mu_true = 3;
sigma_true = 1.9;
sigma2_true = sigma_true^2;

% 更细的 n 值（对数尺度，从 2 到 1000）
n_min = 2;
n_max = 1000;
n_count = 30;

n_vals = round(logspace(log10(n_min), log10(n_max), n_count)); % 30个点
n_vals = unique(n_vals); % 去重（因为 round 可能重复）

% 固定一个较大的 m（平衡精度和速度）
m = 1e3;  % 可改为 1e6，但会慢很多

% 预分配数组
mean_of_means = zeros(size(n_vals));
var_of_means = zeros(size(n_vals));
mean_of_vars = zeros(size(n_vals));
var_of_vars = zeros(size(n_vals));

% 理论曲线
theory_var_mean = sigma2_true ./ n_vals;
theory_var_var = 2 * sigma2_true^2 ./ (n_vals - 1);

fprintf('Running simulations for m = %.0e...\n', m);
for i = 1:length(n_vals)
    n = n_vals(i);
    
    % 生成 n x m 的随机矩阵
    X = mu_true + sigma_true * randn(n, m);
    
    % 样本均值和无偏方差（按列）
    sample_means = mean(X, 1);          % 1 x m
    sample_vars = var(X, 0, 1);         % 1 x m (无偏)
    
    % 估计量的均值和方差（用总体方差，除以 m）
    mean_of_means(i) = mean(sample_means);
    var_of_means(i) = var(sample_means, 1);  % 除以 m
    
    mean_of_vars(i) = mean(sample_vars);
    var_of_vars(i) = var(sample_vars, 1);
    
    if mod(i, 5) == 0 || i == length(n_vals)
        fprintf('  n = %4d done.\n', n);
    end
end

%% 绘图
figure();

% 1. 样本均值的平均值
subplot(2, 2, 1);
plot(n_vals, mean_of_means, 'bo-', 'MarkerSize', 4, 'DisplayName', 'Simulated');
yline(mu_true, 'r--', 'LineWidth', 1.5, 'DisplayName', 'True \mu = 3');
xlabel('Sample size n');
ylabel('$Mean\ of\ \hat{\mu}$','Interpreter', 'latex');
title('Mean of Sample Mean Estimator');
legend('Location', 'best');
grid on;
set(gca, 'XScale', 'log');

% 2. 样本均值的方差
subplot(2, 2, 2);
plot(n_vals, var_of_means, 'bo-', 'MarkerSize', 4, 'DisplayName', 'Simulated');
hold on;
plot(n_vals, theory_var_mean, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Theory: \sigma^2/n');
xlabel('Sample size n');
ylabel('$Var(\hat{\mu})$','Interpreter', 'latex');
title('Variance of Sample Mean Estimator');
legend('Location', 'best');
grid on;
set(gca, 'XScale', 'log');

% 3. 样本方差的平均值
subplot(2, 2, 3);
plot(n_vals, mean_of_vars, 'go-', 'MarkerSize', 4, 'DisplayName', 'Simulated');
yline(sigma2_true, 'r--', 'LineWidth', 1.5, 'DisplayName', 'True \sigma^2 = 3.61');
xlabel('Sample size n');
ylabel('$Mean\ of\ \hat{\sigma}^2$','Interpreter', 'latex');
title('Mean of Sample Variance Estimator');
legend('Location', 'best');
grid on;
set(gca, 'XScale', 'log');

% 4. 样本方差的方差
subplot(2, 2, 4);
plot(n_vals, var_of_vars, 'go-', 'MarkerSize', 4, 'DisplayName', 'Simulated');
hold on;
plot(n_vals, theory_var_var, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Theory: 2\sigma^4/(n-1)');
xlabel('Sample size n');
ylabel('Var(\hat{\sigma}^2)','Interpreter', 'latex');
title('Variance of Sample Variance Estimator');
legend('Location', 'best');
grid on;
set(gca, 'XScale', 'log');

sgtitle(sprintf('Estimator Performance (m = %.0e simulations per n)', m), 'FontSize', 14);