function phi_deg_mapped = dft_improved_phase_est(signal_vec, N, T, PhaseStepDeg, A, Noise_Variance)
% dft_mapping_paper_opt  基于论文改进算法的DFT相位估计函数
%
% 用法:
%   phi_deg_mapped = dft_mapping_paper_opt(signal_vec, N, T, PhaseStepDeg, A, Noise_Variance)
%
% 输入参数:
%   signal_vec     - 1xN 实数采样序列
%   N              - 采样点数
%   T              - 周期参数 (用于计算有理数近似)
%   PhaseStepDeg   - 建立查找表时的相位步长 (单位: 度)
%   A              - 信号幅度 (用于SNR计算)
%   Noise_Variance - 噪声方差 (用于SNR计算)
%
% 输出:
%   phi_deg_mapped - 映射后的初相估计值 (单位: 度)
%
% 实现说明:
%   - 按论文思想: 取 N1 = N, 通过搜索 N2 使均方根误差近似公式最小化
%   - 使用论文公式 (22) 的平均近似形式作为目标函数
%   - 在零填充后的 DFT 结果中提取相位，再通过查找表映射到参考初相
%   - 函数包含输入检查，逻辑严谨，依赖 create_list 与 list_find 辅助函数

    % ---- 输入检查 ----
    if ~isvector(signal_vec) || numel(signal_vec) ~= N
        error('signal_vec 必须是长度为 N 的向量。');
    end
    if nargin < 6
        error('必须提供六个输入参数: signal_vec, N, T, PhaseStepDeg, A, Noise_Variance。');
    end

    % 步骤1：确定N1 = N（论文优化结论：N1取总采样点数N最优）
    N1 = N;
    if N1 < 2
        error('总采样点数N必须≥2，否则无法截取两段不同长度序列');
    end
    
    % 步骤2：求解优化N2（论文整数规划问题，通过三次方程求解）
    % 三次方程：2x³ - 2x² + 3N(N-1)x - N²(N-1) = 0
    coeffs = [2, -2, 3*N*(N-1), -N^2*(N-1)];
    roots_x = roots(coeffs);
    % 提取有效实根（忽略虚部误差≤1e-10的根）
    real_roots = roots_x(abs(imag(roots_x)) < 1e-10);
    if isempty(real_roots)
        error('三次方程未找到有效实根，无法确定最优N2');
    end
    x0 = real(real_roots(1));  % 取第一个实根（三次方程至少1个实根）
    
    % 生成N2候选集（确保1≤N2≤N1-1，避免N2=0或N2=N1）
    n2_floor = max(1, floor(x0));
    n2_ceil = min(N1-1, ceil(x0));
    n2_candidates = unique([n2_floor, n2_ceil]);  % 去重（避免floor与ceil相等）
    % 异常 fallback：若候选集为空，取x0附近有效整数
    if isempty(n2_candidates)
        n2_candidates = max(1, min(N1-1, round(x0)));
    end
    
    % 步骤3：选择最优N2（最小化平均均方根误差指标）
    min_metric = Inf;
    N2 = n2_candidates(1);
    for n2 = n2_candidates
        % 计算误差指标（论文公式22简化，忽略公共因子μ）
        numerator = sqrt(((n2 - 1)^2 / N1) + ((N1 - 1)^2 / n2));
        denominator = N1 - n2;
        if denominator <= 0
            continue;  % 避免分母为0/负数
        end
        metric = numerator / denominator;
        if metric < min_metric
            min_metric = metric;
            N2 = n2;
        end
    end
    
    % 步骤4：截取两段序列并计算DFT
    sN1 = signal_vec(1:N1);  % N1点序列（长度=N）
    sN2 = signal_vec(1:N2);  % N2点序列（长度=最优N2）
    
    % N1点DFT：找最大谱线位置（转换为论文0-based索引）
    SN1 = fft(sN1);
    [~, k1_matlab] = max(abs(SN1));
    k1 = k1_matlab - 1;  % 论文中k为0-based索引
    
    % N2点DFT：找最大谱线位置（转换为论文0-based索引）
    SN2 = fft(sN2);
    [~, k2_matlab] = max(abs(SN2));
    k2 = k2_matlab - 1;  % 论文中k为0-based索引
    
    % 步骤5：提取两段DFT的相位（弧度）
    phi_k1 = angle(SN1(k1_matlab));
    phi_k2 = angle(SN2(k2_matlab));
    
    % 步骤6：代入论文公式（12）计算初相（弧度）
    term1 = (phi_k1 - phi_k2) / pi;
    term2 = k1 * (1 - 1/N1);
    term3 = k2 * (1 - 1/N2);
    inside_brace = (N1 / (N1 - N2)) * (term1 + term2 - term3) - k1;
    phi0_rad = phi_k1 - pi * (1 - 1/N1) * inside_brace;

    [I, D] = rat(T);
    z = [signal_vec, zeros(1, (D-1)*N)];          % 零填充至长度 D*N
    Z = fft(z);
    % 使用第 I+1 个频率点 (MATLAB索引从1开始)
    binIdx = I + 1;
    if binIdx < 1 || binIdx > numel(Z)
        % 如果 I 超出范围，则退化为最大谱线法
        [~, idxMax] = max(abs(Z));
        phi_deg = rad2deg(angle(Z(idxMax)));
    else
        phi_deg = rad2deg(angle(Z(binIdx)));
    end

    % ---- 构建映射表并进行相位映射 ----
    list = create_list(N, T, PhaseStepDeg);     % 使用已有辅助函数生成映射表
    phi_deg_mapped = list_find(list, phi_deg);  % 将DFT相位映射到参考初相

    % ---- (可选) 保存调试信息 ----
    % (未返回，仅供调试使用)
    % persistent last_opt_params;
    % last_opt_params.N1 = N1;
    % last_opt_params.N2 = N2_opt;
    % last_opt_params.bestObj = bestObj;
    % last_opt_params.mu = mu;
    % last_opt_params.phi_deg_raw = phi_deg;
end
