sigma_values = 1:1:100; % Sigma值的范围
variance_values = zeros(size(sigma_values)); % 初始化方差值数组

% 循环不同的sigma值，计算方差
for i = 1:length(sigma_values)
    variance_values(i) = estimate_delay_variance(sigma_values(i));
end

% 绘制方差与sigma值的关系图
figure;
plot(sigma_values, variance_values, '-o');
xlabel('Sigma');
ylabel('Variance of Delay Estimation Error');
title('Relationship between Sigma and Variance of Delay Estimation Error');
grid on;

% 定义函数estimate_delay_variance
function var1 = estimate_delay_variance(sigma)
    randn('state',1); % 设置随机数生成器的种子
    N=500; % 数据点数量
    M=20; % 传输脉冲信号的宽度
    MN=5000; % 蒙特卡洛模拟的次数
    N0=248; % 真实的延迟时间
    a=1.5; % 脉冲信号的幅度

    % 初始化信号
    echo_signal=zeros(N,1);
    transmit_signal=a*ones(M,1);
    echo_signal(N0:(N0+M-1))=a;

    % 初始化延迟估计误差数组
    Delayestimate_error=zeros(1,MN);

    % 进行蒙特卡洛模拟
    for j=1:MN
        receive_signal=echo_signal+sigma.*randn(N,1); % 添加高斯噪声
        correl=zeros(N,1); % 初始化相关性数组
        for k=1:(N-M)
            correl(k)=sum(transmit_signal.*receive_signal(k:(k+M-1))); % 计算相关性
        end
        [cmax,ctime]=max(correl); % 找到最大相关性
        delayestimate_error(j)=ctime-N0; % 计算延迟估计误差
    end

    % 计算方差
    var1=var(delayestimate_error);
end