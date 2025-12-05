clc;
clear;
close all;
rng('default');
rng(2920);

f = [0.4,0.5];  % 信号频率向量（可扩展到任意数量信号）
A = [1,1];     % 不同信号的振幅向量
var = 0.1;        % 噪声方差
N = 32;          % 序列长度
dat = MUSIC_gen(f,A,var,N); % 生成包含噪声的序列

% 定义 m 值列表（可按需修改或扩展），并去重保持原顺序
mlist = floor(  [N/8, N/3, N/2, N-1]  );
mlist = unique(mlist,'stable');  % 去重并保留顺序

% 自适应计算子图行列数
n = length(mlist);
cols = ceil(sqrt(n));
rows = ceil(n/cols);

% 关键参数：信号个数（自动从频率向量获取，无需手动设置）
K = length(f);

figure;
for idx = 1:n
    m = mlist(idx);
    rh = MUSIC_pmusic(f, dat, m, 2^10);
    freq_axis = (1:length(rh))/length(rh); % 频率轴
    
    subplot(rows, cols, idx);
    h_plot = plot(freq_axis, rh, 'color', [0 0.4470 0.7410]);
    hold on;
    
    % ====== 通用峰值检测（基于数学上的局部极大值定义）======
    % 1. 检测所有局部极大值（某点大于左右相邻点）
    % 边缘处理：排除第一个和最后一个点（无法判断左右）
    peak_indices = [];
    peak_values = [];
    peak_freqs = [];
    
    % 遍历所有内部点，判断是否为局部极大值
    for i = 2:length(rh)-1
        if rh(i) > rh(i-1) && rh(i) > rh(i+1)
            peak_indices = [peak_indices, i];
            peak_values = [peak_values, rh(i)];
            peak_freqs = [peak_freqs, freq_axis(i)];
        end
    end
    
    % 2. 处理峰值：如果找到的峰值大于K个，选择幅值最大的K个
    peak_coords = zeros(K,2); % 存储最终选中的峰值 [freq, value]
    if ~isempty(peak_indices)
        % 对峰值按幅值降序排序
        [sorted_values, sorted_idx] = sort(peak_values, 'descend');
        sorted_freqs = peak_freqs(sorted_idx);
        
        % 选择前K个最大的峰值（如果峰值数量不足K个，尽量选择所有）
        num_select = min(K, length(sorted_values));
        for k = 1:num_select
            peak_coords(k,:) = [sorted_freqs(k), sorted_values(k)];
            
            % 用红点标注峰值
            plot(sorted_freqs(k), sorted_values(k), 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
        end
    else
        warning('未检测到任何局部极大值！');
    end
    
    % 获取当前坐标轴范围用于智能标注
    ax = gca;
    y_limits = ylim(ax);
    y_range = y_limits(2) - y_limits(1);
    offset = 0.15 * y_range; % Y方向偏移量 (15%的Y轴范围)
    
    % 智能标注坐标 (避免重叠)
    for k = 1:K
        if all(peak_coords(k,:) ~= 0) % 确保找到了有效峰值
            x_pos = peak_coords(k,1);
            y_pos = peak_coords(k,2) + offset;
            
            % 根据X位置调整水平对齐方式避免重叠
            h_align = 'left';
            if x_pos > 0.7 % 右侧区域
                h_align = 'right';
            elseif x_pos > 0.4 && x_pos < 0.6 % 中间区域
                h_align = 'center';
            end
            
            % 添加坐标标注（同时显示峰值排序）
            text(x_pos, y_pos, ...
                sprintf('%.3f, %.1f',  x_pos, peak_coords(k,2)), ...
                'FontSize', 10, ...
                'FontWeight', 'bold', ...
                'Color', 'red', ...
                'VerticalAlignment', 'bottom', ...
                'HorizontalAlignment', h_align, ...
                'BackgroundColor', [1 1 1 0.7]); % 半透明白底增强可读性
        end
    end
    
    % 恢复图形设置
    hold off;
    xlabel('\omega/2\pi', 'FontSize', 16, 'FontWeight', 'bold');
    title(['m=', num2str(m), '，噪声方差=', num2str(var)], 'FontSize', 16);
    grid on;
    
    % 适当扩展Y轴上限，为标注留出空间
    ylim(ax, [y_limits(1), y_limits(2) + 0.2*y_range]);
end

sgtitle(['N=', num2str(N), '，信号个数=', num2str(K)], 'FontSize', 20);

% ===================== 新增：调用计算过程展示函数 =====================
% 选择一个m值展示（推荐选mlist(3)，即N/2=16，兼顾计算效率和效果）
target_m = 16;
fprintf('\n\n==================== 展示m=%d时的MUSIC计算过程 ====================\n', target_m);

% 调用新函数展示计算过程
process_data = MUSIC_calculation_process(f, dat, target_m, 2^10);