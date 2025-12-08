function C = MyCov(X, Y)
% myCov 计算两个随机变量的协方差矩阵
% 输入:
%   X, Y - 两个等长的随机变量向量
% 输出:
%   C - 2x2 协方差矩阵

    if length(X) ~= length(Y)
        error('X 和 Y 的长度必须相同');
    end
    
    % 转换为矩阵形式
    data = [X(:), Y(:)];
    
    % 使用公式计算协方差矩阵
    n = size(data,1);
    mu = mean(data,1);
    C = (data - mu)' * (data - mu) / (n-1);
end
