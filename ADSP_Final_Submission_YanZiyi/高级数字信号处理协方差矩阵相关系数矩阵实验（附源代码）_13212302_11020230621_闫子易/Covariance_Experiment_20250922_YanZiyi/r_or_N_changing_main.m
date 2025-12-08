clear; close all; clc;
sigma = 1;

% 模式选择：'r' 表示相关系数变化，'N' 表示样本量变化
mode = 'N_changing'; % 可改成 'r_changing'

% ---------- 根据模式选择输出文件 ----------
switch mode
    case 'r_changing'
        filename = 'Matrixs_r.txt';
    case 'N_changing'
        filename = 'Matrixs_N.txt';
end

% 如果文件存在，先清空；如果不存在，会新建
fid = fopen(filename, 'w');
fclose(fid);

% 开始记录命令行输出
diary(filename);

switch mode
    case 'r_changing'
        % ---------- 相关系数变化 ----------
        N = 500;
        r_values = -1:0.05:1; % 要考察的相关系数
        num_cases = length(r_values);
        num_rows = ceil(sqrt(num_cases));
        num_cols = ceil(num_cases/num_rows);

        for k = 1:num_cases
            r = r_values(k);
            subplot(num_rows, num_cols, k);
            GenerateDataAndPlot(N, sigma, r);
        end
        sgtitle(sprintf('%s 下的散点图', mode), 'Interpreter', 'none');
        PlotCorrelationAndCovariance(N, sigma, r_values);

    case 'N_changing'
        % ---------- 样本量变化 ----------
        N_values = 100:50:1000; % 要考察的样本量
        r = 0.5; % 固定相关系数
        num_cases = length(N_values);
        num_rows = ceil(sqrt(num_cases));
        num_cols = ceil(num_cases/num_rows);

        for k = 1:num_cases
            N = N_values(k);
            subplot(num_rows, num_cols, k);
            GenerateDataAndPlot(N, sigma, r);
        end
        sgtitle(sprintf('%s 下的散点图', mode), 'Interpreter', 'none');
        PlotCorrelationAndCovariance(N_values, sigma, r);
end

% ---------- 停止记录 ----------
diary off;
