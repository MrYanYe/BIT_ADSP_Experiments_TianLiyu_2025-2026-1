a = 0;
b = pi; % 积分上下限，可以任意取
f = @(x) sin(x)./x; % 函数句柄，可以任意取，这里我取的积不出来的sinc函数
N = 100000;
% 蒙特卡洛求积分
num = 0;
for k = 1:N
    c = [a + (b - a) * rand,rand];
    if c(2) < f(c(1))
        num = num + 1;
    end
end
% 输出结果，并且真实值进行比较
disp(['蒙特卡洛法近似计算的积分值: ', num2str((num/N)*(b-a))]);
integral_true = integral(f, a, b);
disp(['MATLAB integral 函数计算的积分值: ', num2str(integral_true)]);
disp(['相对误差: ', num2str((integral_true-((num/N)*(b-a)))/integral_true)]);
