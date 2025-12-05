function R = MyCorrCoef(X, Y)
% myCorr 计算两个随机变量的相关系数矩阵
% 输入:
%   X, Y - 两个等长的随机变量向量
% 输出:
%   R - 2x2 相关系数矩阵

    C = MyCov(X, Y);   % 先调用协方差矩阵
    d = sqrt(diag(C)); % 标准差向量
    R = C ./ (d * d'); % 相关系数矩阵
end
