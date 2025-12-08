function [X, Y] = GenerateRandomVariables(N, sigma, r)
    % GenerateData 生成二维相关数据
    %
    % 输入参数:
    %   N     - 样本数量
    %   sigma - 标准差缩放因子
    %   r     - 相关系数 (-1 <= r <= 1)
    %
    % 输出参数:
    %   X, Y  - 生成的数据向量

    % 随机数
    u1 = randn(1,N);
    u2 = randn(1,N);

    % X ~ N(1, 2^2)
    % X = 1 + 2 * u1;
    X = u1;

    % Y 与 X 存在相关性
    % Y = sigma * r .* u1 + sigma * sqrt(1 - r^2) .* u2;
    Y = X.^2;
end
