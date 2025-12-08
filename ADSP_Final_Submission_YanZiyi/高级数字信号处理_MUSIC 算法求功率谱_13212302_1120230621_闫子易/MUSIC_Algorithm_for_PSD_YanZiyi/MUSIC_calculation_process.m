function [process_data] = MUSIC_calculation_process(f, x, p, num)
    % MUSIC谱计算过程详细展示（兼容旧MATLAB版本，修复colorbar只读错误）
    % 输入：f=信号频率向量 | x=数据行向量 | p=自相关矩阵阶数 | num=变换点数
    % 输出：process_data=过程数据结构体（含中间计算结果）
    
    % ===================== 初始化与参数检查 =====================
    fprintf('\n===========================================================\n');
    fprintf('【MUSIC计算过程】m=%d, num=%d（开始计算）\n', p, num);
    fprintf('===========================================================\n');
    
    % 确保输入x是行向量
    if iscolumn(x), x = x.'; end
    
    % ===================== 复现原MUSIC核心计算 =====================
    Rxx = MUSIC_macf(x, p);          % 自相关矩阵（p×p）
    [v, d] = eig(Rxx);               % 特征分解（v是p×p列向量矩阵）
    eigvals = diag(d);
    [~, idx] = sort(eigvals, 'ascend');  % 特征值升序排序
    v = v(:, idx);                   % 排序后的特征向量（p×p，每列是一个特征向量）
    m_signal = length(f);            % 信号个数
    noise_dim = p - m_signal;        % 噪声子空间维度（乘加次数=noise_dim）
    
    % 维度合法性检查
    if noise_dim <= 0
        error('自相关矩阵阶数p=%d需大于信号个数m=%d！', p, m_signal);
    end
    if num <= 0
        error('变换点数num需为正整数！');
    end
    
    % ===================== 记录分母乘加过程（矩阵存储，无cell） =====================
    temp = zeros(1, num);                    % 初始分母（1×num行向量）
    V_conj_prod = zeros(noise_dim, num);     % 乘法结果矩阵（noise_dim×num）
    temp_intermediate = zeros(noise_dim, num);% 累加结果矩阵（noise_dim×num）
    
    % 逐次计算并输出细节
    for i = 1:noise_dim
        % 乘法：FFT后转置为行向量，确保维度一致
        v_col = v(:, i);                     % 第i个噪声特征向量（p×1列向量）
        V = fft(v_col, num).';               % FFT后转置为1×num行向量
        prod_step = V .* conj(V);            % 乘法：|V|²（1×num行向量）
        V_conj_prod(i, :) = prod_step;       % 矩阵第i行存储本次乘法结果
        
        % 累加：行向量+行向量，维度匹配
        temp = temp + prod_step;             % 累加后仍为1×num行向量
        temp_intermediate(i, :) = temp;      % 矩阵第i行存储本次累加后的分母
        
        % 命令行输出（优化格式，无重复）
        fprintf('\n【第%d/%d次乘加】\n', i, noise_dim);
        fprintf('  乘法结果（|V|²）：最小值=%.6f，最大值=%.6f，均值=%.6f\n', ...
                min(prod_step), max(prod_step), mean(prod_step));
        fprintf('  累加后分母：最小值=%.6f，最大值=%.6f，均值=%.6f\n', ...
                min(temp), max(temp), mean(temp));
    end
    
    % ===================== 计算最终结果 =====================
    final_denominator = temp;               % 最终分母（1×num行向量）
    final_music = 1 ./ final_denominator;    % 最终MUSIC谱（1×num行向量）
    
    % 最终结果输出
    fprintf('\n===========================================================\n');
    fprintf('【最终结果】\n');
    fprintf('  分母范围：[%.6f, %.6f]，均值=%.6f\n', ...
            min(final_denominator), max(final_denominator), mean(final_denominator));
    fprintf('  MUSIC谱范围：[%.6f, %.6f]，峰值=%.6f\n', ...
            min(final_music), max(final_music), max(final_music));
    fprintf('===========================================================\n');
    
    % ===================== 存储过程数据 =====================
    process_data = struct(...
        'freq', (0:num-1)/num, ...          % 归一化频率轴（1×num行向量）
        'V_conj_prod', V_conj_prod, ...     % 乘法结果矩阵（noise_dim×num）
        'temp_intermediate', temp_intermediate, ...  % 累加结果矩阵（noise_dim×num）
        'final_denominator', final_denominator, ...  % 最终分母（1×num）
        'final_music', final_music, ...     % 最终MUSIC谱（1×num）
        'noise_dim', noise_dim, ...         % 乘加次数
        'signal_freq', f ...                % 真实信号频率
    );
    
    % ===================== 可视化过程（兼容旧MATLAB，修复colorbar错误） =====================
    visualize_MUSIC_process(process_data);
end

% -------------------------------------------------------------------------
function visualize_MUSIC_process(process_data)
    % 子函数：可视化乘加过程（兼容旧MATLAB版本）
    freq = process_data.freq;               % 1×num行向量
    final_music = process_data.final_music; % 1×num行向量
    final_denominator = process_data.final_denominator; % 1×num行向量
    noise_dim = process_data.noise_dim;     % 乘加次数
    signal_freq = process_data.signal_freq; % 真实信号频率
    temp_intermediate = process_data.temp_intermediate; % 累加矩阵（noise_dim×num）
    
    % 创建图形窗口
    % figure('Position', [100, 100, 1200, 800]);
    figure();
    sgtitle('MUSIC谱计算过程可视化', 'FontSize', 16, 'FontWeight', 'bold');
    
    % ===================== 子图1：最终MUSIC谱（标注2个极大值） =====================
    subplot(2, 2, 1);
    plot(freq, final_music, 'b-', 'LineWidth', 1.5);
    hold on;
    
    % 通用局部极大值检测（数学定义：某点大于左右相邻点）
    music_peaks_freq = [];
    music_peaks_val = [];
    for i = 2:length(final_music)-1
        if final_music(i) > final_music(i-1) && final_music(i) > final_music(i+1)
            music_peaks_freq = [music_peaks_freq, freq(i)];
            music_peaks_val = [music_peaks_val, final_music(i)];
        end
    end
    
    % 选择幅值最大的2个极大值
    selected_peaks = [];
    if ~isempty(music_peaks_val)
        % 按幅值降序排序
        [sorted_vals, sorted_idx] = sort(music_peaks_val, 'descend');
        sorted_freqs = music_peaks_freq(sorted_idx);
        
        % 选前2个（不足2个则选所有）
        num_select = min(2, length(sorted_vals));
        selected_peaks = [sorted_freqs(1:num_select); sorted_vals(1:num_select)];
    end
    
    % 错位标注坐标（避免重叠）
    vert_offset = [0.12, 0.08];  % 垂直偏移比例（上移）
    horz_offset = [0.005, -0.005]; % 水平偏移
    y_max = max(final_music);
    
    for k = 1:size(selected_peaks, 2)
        f_val = selected_peaks(1, k);
        music_val = selected_peaks(2, k);
        
        % 计算错位位置
        y_offset = music_val * vert_offset(k);
        f_val_offset = f_val + horz_offset(k);
        f_val_offset = max(min(f_val_offset, max(freq)), min(freq)); % 限制在频率范围内
        
        % 绘制红点（填充）
        plot(f_val, music_val, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
        % 标注坐标（只显示数值）
        text(f_val_offset, music_val + y_offset, sprintf('(%.3f, %.3f)', f_val, music_val), ...
             'FontSize', 10, 'Color', 'r', 'HorizontalAlignment', 'center');
    end
    
    xlabel('归一化频率 \omega/2\pi', 'FontSize', 12);
    ylabel('MUSIC谱值（1/分母）', 'FontSize', 12);
    title('最终MUSIC谱', 'FontSize', 14, 'FontWeight', 'bold');
    grid on; 
    ylim([0, 1.4*y_max]); % 扩大y轴范围，确保标注完全显示
    
    % ===================== 子图2：关键频率点的累加过程（保持不变） =====================
    subplot(2, 2, 2);
    % 选择3个关键频率点（真实信号频率+中间频率）
    selected_freqs = [signal_freq,0.6];
    selected_freqs = unique(selected_freqs);  % 去重
    colors = lines(length(selected_freqs));
    
    for k = 1:length(selected_freqs)
        f_val = selected_freqs(k);
        [~, idx] = min(abs(freq - f_val));  % 找到频率对应的列索引
        accum_vals = temp_intermediate(:, idx);  % 矩阵第idx列=所有累加步骤的分母值
        plot(1:noise_dim, accum_vals, 'o-', 'Color', colors(k, :), ...
             'LineWidth', 1.2, 'MarkerSize', 4, ...
             'DisplayName', sprintf('f=%.4f', f_val));
        hold on;
    end
    xlabel('累加步骤（第i次噪声特征向量贡献）', 'FontSize', 12);
    ylabel('分母temp值', 'FontSize', 12);
    title('关键频率点的分母累加过程', 'FontSize', 14, 'FontWeight', 'bold');
    grid on; legend('Location', 'best', 'FontSize', 10);
    
    % ===================== 子图3：分母累加过程热力图（保持不变） =====================
    subplot(2, 2, 3);
    imagesc(freq, 1:noise_dim, temp_intermediate);  % 直接用累加矩阵绘图
    cbar = colorbar;  % 先创建colorbar对象（兼容所有版本）
    cbar.YLabel.String = '分母temp值';  % 再设置Y轴标签（替代只读的Label属性）
    xlabel('归一化频率 \omega/2\pi', 'FontSize', 12);
    ylabel('累加步骤', 'FontSize', 12);
    title('分母累加过程热力图', 'FontSize', 14, 'FontWeight', 'bold');
    colormap('jet');
    
    % ===================== 子图4：最终分母分布（标注2个极小值） =====================
    subplot(2, 2, 4);
    plot(freq, final_denominator, 'g-', 'LineWidth', 1.5);
    hold on;
    
    % 通用局部极小值检测（数学定义：某点小于左右相邻点）
    den_minima_freq = [];
    den_minima_val = [];
    for i = 2:length(final_denominator)-1
        if final_denominator(i) < final_denominator(i-1) && final_denominator(i) < final_denominator(i+1)
            den_minima_freq = [den_minima_freq, freq(i)];
            den_minima_val = [den_minima_val, final_denominator(i)];
        end
    end
    
    % 选择幅值最小的2个极小值
    selected_minima = [];
    if ~isempty(den_minima_val)
        % 按幅值升序排序（从小到大）
        [sorted_vals, sorted_idx] = sort(den_minima_val, 'ascend');
        sorted_freqs = den_minima_freq(sorted_idx);
        
        % 选前2个（不足2个则选所有）
        num_select = min(2, length(sorted_vals));
        selected_minima = [sorted_freqs(1:num_select); sorted_vals(1:num_select)];
    end
    
    % 错位标注坐标（避免重叠）
    vert_offset = [0.15, 0.10];  % 垂直偏移比例（下移）
    horz_offset = [0.005, -0.005]; % 水平偏移
    y_min = min(final_denominator);
    y_max_den = max(final_denominator);
    
    for k = 1:size(selected_minima, 2)
        f_val = selected_minima(1, k);
        den_val = selected_minima(2, k);
        
        % 计算错位位置
        y_offset = den_val * vert_offset(k);
        f_val_offset = f_val + horz_offset(k);
        f_val_offset = max(min(f_val_offset, max(freq)), min(freq)); % 限制在频率范围内
        
        % 绘制红点（填充）
        plot(f_val, den_val, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
        % 标注坐标（只显示数值）
        text(f_val_offset, den_val - y_offset, sprintf('(%.3f, %.6f)', f_val, den_val), ...
             'FontSize', 10, 'Color', 'r', 'HorizontalAlignment', 'center');
    end
    
    xlabel('归一化频率 \omega/2\pi', 'FontSize', 12);
    ylabel('最终分母temp值', 'FontSize', 12);
    title('最终分母分布', 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    % 调整y轴范围，确保最小值标注可见
    y_lim_min = y_min * (1 - 0.25);  % 扩大下方范围
    y_lim_max = y_max_den * 1.1;
    ylim([y_lim_min, y_lim_max]);
    
    % 调整子图间距
    set(gcf, 'Position', [100, 100, 1200, 800]);
    whitebg(gcf, 'white');
    sgtitle('MUSIC谱计算过程可视化', 'FontSize', 16, 'FontWeight', 'bold'); % 重新设置标题确保显示
end