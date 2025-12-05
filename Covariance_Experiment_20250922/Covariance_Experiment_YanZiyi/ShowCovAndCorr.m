function ShowCovAndCorr(X, Y)
    % Matlab自带函数
    C1 = cov(X, Y);
    disp('Matlab自带函数计算的协方差矩阵:');
    disp(C1);

    % 自写协方差函数
    C2 = MyCov(X, Y);
    disp('自写子函数计算的协方差矩阵:');
    disp(C2);
    
    % Matlab自带函数
    R1 = corrcoef(X, Y);
    disp('Matlab自带函数计算的相关系数矩阵:');
    disp(R1);

    % 自写相关系数函数
    R2 = MyCorrCoef(X, Y);
    disp('自写子函数计算的相关系数矩阵:');
    disp(R2);
end

% function ShowCovAndCorr(X)
%     % Matlab 自带函数
%     C1 = cov(X');
%     disp('Matlab自带函数计算的协方差矩阵:');
%     disp(C1);
% 
%     % 自写协方差函数
%     C2 = MyCov(X');
%     disp('自写子函数计算的协方差矩阵:');
%     disp(C2);
% 
%     % 自写相关系数函数
%     R = MyCorrCoef(X');
%     disp('自写子函数计算的相关系数矩阵:');
%     disp(R);
% end
