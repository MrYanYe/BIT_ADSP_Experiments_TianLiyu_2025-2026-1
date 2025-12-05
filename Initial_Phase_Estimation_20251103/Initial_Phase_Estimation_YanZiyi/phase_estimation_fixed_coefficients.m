function phase_estimation_fixed_coefficients(N, phi_true, T, A, Noise_Variance, useDFTOptim)
% phase_estimation - Monte Carlo仿真比较三种相位估计方法
%
% 输入参数:
%   N                 - 信号长度
%   phi_true          - 信号初相位 (单位: 度)
%   T                 - 样本数据包含的周期
%   A                 - 信号幅度
%   Noise_Variance    - 噪声方差
%   useDFTOptim- 是否使用DFT映射优化 (1=是,0=否)
%
% 输出:
%   在命令行打印三种估计方法的均值和标准差
%   绘制估计结果图

    rng(1);   % 设置随机种子
    numMonteCarlo = 1000;     % 蒙特卡洛仿真次数
    phase = deg2rad(phi_true);% 转换为弧度
    f0 = T/N;                 % 信号的数字频率
    PhaseStepDeg = 0.5;       % 映射关系步长

    % 根据开关设定显示名称
    if useDFTOptim
        dftDisplayName = 'DFT+Optimization';
    else
        dftDisplayName = 'DFT';
    end

    % -------------------------
    % 信号生成
    % -------------------------
    ph_arr = 0 : 2*pi*f0 : (N-1)*2*pi*f0;
    s0 = A*cos(ph_arr + phase);


    % 最大似然相关变量
    sin_s = sin(ph_arr);
    cos_s = cos(ph_arr);

    % DFT相关变量
    [I,D] = rat(T); %#ok<ASGLU>

    % 最小二乘相关变量
    X0 = [A*cos_s; -A*sin_s].';
    X = pinv(X0.'*X0)*X0.';

    % -------------------------
    % Monte Carlo 仿真
    % -------------------------
    phase_est1 = zeros(1, numMonteCarlo);
    phase_est2 = zeros(1, numMonteCarlo);
    phase_est3 = zeros(1, numMonteCarlo);

    for m = 1:numMonteCarlo
        w = normrnd(0, sqrt(Noise_Variance), 1, N); % 噪声
        Signal_with_Noise = s0 + w;

        % 最大似然估计
        phase_est1(m) = rad2deg(-atan2(dot(Signal_with_Noise, sin_s), ...
                                       dot(Signal_with_Noise, cos_s)));

        % DFT估计
        if useDFTOptim
            % 调用优化函数 (需用户提供 dft_mapping_opt.m)
            % phase_est2(m) = dft_mapping_opt(Signal_with_Noise, N, T, PhaseStepDeg);
            phase_est2(m) = dft_improved_phase_est(Signal_with_Noise,  N, T, PhaseStepDeg, A, Noise_Variance);
        else
            Z = fft(Signal_with_Noise);
            [~,index] = max(abs(Z));
            phase_est2(m) = rad2deg(angle(Z(index)));
        end

        % 最小二乘估计
        Y = Signal_with_Noise.';
        theta = X*Y;
        phase_est3(m) = rad2deg(atan2(theta(2), theta(1)));
    end

    % -------------------------
    % 输出结果
    % -------------------------
    fprintf('最大似然估计：\n  est_mean = %.4f\n  est_std = %.4f\n\n', ...
            mean(phase_est1), std(phase_est1));

    fprintf('%s估计：\n  est_mean = %.4f\n  est_std = %.4f\n\n', ...
            dftDisplayName, mean(phase_est2), std(phase_est2));

    fprintf('最小二乘估计：\n  est_mean = %.4f\n  est_std = %.4f\n', ...
            mean(phase_est3), std(phase_est3));

    % -------------------------
    % 绘图
    % -------------------------
    
    % 第一幅图：加噪声后的信号
    figure;
    plot(0:N-1, Signal_with_Noise, 'b');
    xlabel('采样点序号 (样本点)','FontSize',12);
    ylabel('信号幅度','FontSize',12);
    title('加噪声后的信号波形','FontSize',16);
    grid on;



    figure;
    subplot(311);
    plot(phase_est1);
    hold on;
    yline(phi_true, 'r', 'LineWidth', 1.5);
    title('最大似然估计','FontSize',16);

    subplot(312);
    plot(phase_est2);
    hold on;
    yline(phi_true, 'r', 'LineWidth', 1.5);
    title([dftDisplayName '估计'],'FontSize',16);

    subplot(313);
    plot(phase_est3);
    hold on;
    yline(phi_true, 'r', 'LineWidth', 1.5);
    title('最小二乘估计','FontSize',16);

    % 在总图右上角添加标注
    txt = sprintf('红线为真实初相位 %d°', phi_true);
    annotation('textbox',[0.75 0.93 0.2 0.05],'String',txt,...
               'EdgeColor','none','FontSize',12,'Color','r');
end
