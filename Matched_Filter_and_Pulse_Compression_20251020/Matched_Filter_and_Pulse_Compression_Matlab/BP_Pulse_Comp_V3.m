clc; clear; close all;

% === 选择信号类型 ===
% BP_Type = 1 -> BK 二相码（示例）
% BP_Type = 2 -> m 序列（需指定 BP_Length）
% BP_Type = 3 -> 线性 chirp
BP_Type = 3;         % 1,2,3
BP_Length = 255;     % 用于 m 序列（63/127/255/511/1023/2047）
noieseAmp = 100;       % 噪声幅度（对 chirp 可按波形幅度调整）
% 对于 chirp，可修改下面参数（仅在 BP_Type==3 时生效）
chirp_fs = 1e3;      % 采样率 Hz
chirp_Tp = 0.02;     % 脉冲宽度 s
chirp_B  = 2e6;      % 带宽 Hz

bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, noieseAmp, chirp_fs, chirp_Tp, chirp_B);

% ======================
function bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, noieseAmp, chirp_fs, chirp_Tp, chirp_B)
% 支持三种信号：二相码(1)、m序列(2)、线性chirp(3)
% 返回 bp_pc_result 为脉压后结果（复或实），并绘图

% 生成信号
if BP_Type == 1
    bp_echo = [1,1,1,1,1,-1,-1,1,1,-1,1,-1,1];  % BK 码示例
    t_vec = 0:length(bp_echo)-1; fs = 1;
    seqName = sprintf('BK 序列（Length=%d）', length(bp_echo));
elseif BP_Type == 2
    bp_echo = produce_m(BP_Length);     % 生成 m 序列
    t_vec = 0:length(bp_echo)-1; fs = 1;
    seqName = sprintf('m 序列（Length=%d）', length(bp_echo));
elseif BP_Type == 3
    if nargin < 6
        error('调用 chirp 模式需传入 chirp_fs, chirp_Tp, chirp_B 三个参数。');
    end
    fs = chirp_fs;
    Tp = chirp_Tp;
    B  = chirp_B;
    N = round(Tp*fs);
    t = (0:N-1)/fs;
    f0 = -B/2;
    k = B / Tp;
    % 生成基带实值 chirp，若需复包络可用 exp(1j*...)
    bp_echo = cos(2*pi*(f0.*t + 0.5*k.*t.^2));
    t_vec = t;
    seqName = sprintf('线性 chirp（Tp=%.4g s B=%.3g Hz fs=%.0f Hz）', Tp, B, fs);
else
    error('不支持的 BP_Type，取值 1,2,3。');
end

sig_length = length(bp_echo);
sigAmp = max(abs(bp_echo));

% 叠加噪声
noise1 = noieseAmp * randn(1, sig_length);
bp_echo_noise = bp_echo + noise1;

% 建立匹配滤波器（共轭反转）
bp_MF = conj(bp_echo(end:-1:1));

% 脉冲压缩（卷积，full）
bp_pc_result = conv(bp_echo_noise, bp_MF);

% 找峰值（按幅值）
[cm, ct] = max(abs(bp_pc_result));
loc_idx = ct;                       % 峰值的样本索引（1-based）
if exist('fs','var') && fs>1
    loc_t = (loc_idx-1)/fs;         % 峰值对应的时间（秒）
else
    loc_t = NaN;
end

% 绘图
figure('Position',[100 100 1000 700]);

% 子图 1：原始信号
subplot(221);
plot(t_vec, bp_echo, 'b-','LineWidth',1);
if BP_Type == 1
    title('BK 码回波信号');
elseif BP_Type == 2
    title('m 序列回波信号');
else
    title('chirp 脉冲信号 s(t)');
end
xlabel('样本 / 时间 (s)');
ylim([min(bp_echo)-0.2*sigAmp, max(bp_echo)+0.2*sigAmp]);
grid on;

% 子图 2：加噪信号
subplot(222);
plot(t_vec, bp_echo_noise, 'k-');
title('加噪声的回波信号');
xlabel('样本 / 时间 (s)');
ylim([min(bp_echo_noise)-0.2*sigAmp, max(bp_echo_noise)+0.2*sigAmp]);
grid on;

% 子图 3：匹配滤波响应并标注峰值（统一横轴并绘制 abs）
subplot(223);
% 统一横轴：若存在采样频率 fs>1，则用时间轴；否则用索引轴
Lpc = length(bp_pc_result);
if exist('fs','var') && fs>1
    x_axis = (0:Lpc-1)/fs;
    x_peak = loc_t;
    plot(x_axis, abs(bp_pc_result), 'b-','LineWidth',1);
    hold on;
    plot(x_peak, abs(bp_pc_result(loc_idx)), 'ro','MarkerFaceColor','r');
    % 在横轴为时间时同时显示索引和时间，避免误解
    % txt = sprintf('  loc_idx=%d  t=%.6g s  amp=%.3g', loc_idx, x_peak, abs(bp_pc_result(loc_idx)));
    txt = sprintf('  t=%.6g s  amp=%.3g',  x_peak, abs(bp_pc_result(loc_idx)));
    text(x_peak, abs(bp_pc_result(loc_idx)), txt, 'VerticalAlignment','bottom');
    xlabel('时间 (s)');
    xlim([min(x_axis) max(x_axis)]);
else
    x_axis = 1:Lpc;
    x_peak = loc_idx;
    plot(x_axis, abs(bp_pc_result), 'b-','LineWidth',1);
    hold on;
    plot(x_peak, abs(bp_pc_result(loc_idx)), 'ro','MarkerFaceColor','r');
    text(x_peak, abs(bp_pc_result(loc_idx)), sprintf('  (loc=%d, amp=%.3g)', loc_idx, abs(bp_pc_result(loc_idx))));
    xlabel('样本索引');
    xlim([1 Lpc]);
end
hold off;
title('匹配滤波器响应 峰值检测');
grid on;

% 子图 4：dB 标度
subplot(224);
bp_pc_display = abs(bp_pc_result) + 1e-12;
bp_pc_db = 20*log10(bp_pc_display / max(bp_pc_display));
if exist('fs','var') && fs>1
    plot((0:length(bp_pc_db)-1)/fs, bp_pc_db, 'm-');
    xlabel('时间 (s)');
    xlim([min(x_axis) max(x_axis)]);
else
    plot(bp_pc_db, 'm-');
    xlabel('样本索引');
    xlim([1 length(bp_pc_db)]);
end
ylim([max(bp_pc_db)-80, 5]);
ylabel('dB');
title('dB');
grid on;

% 总标题
sgtitleStr = sprintf('脉冲压缩 %s  — 信号幅度: %.3g  噪声幅度: %.3g', seqName, sigAmp, noieseAmp);
if exist('sgtitle','builtin') || exist('sgtitle','file')
    sgtitle(sgtitleStr);
elseif exist('suptitle','file')
    suptitle(sgtitleStr);
else
    subplot(221);
    text(0.5, 1.15, sgtitleStr, 'Units', 'normalized', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

% 在命令窗口显示峰值信息，既显示样本索引也显示时间（若有）
if exist('fs','var') && fs>1
    fprintf('峰值索引 (ct) = %d, 峰值时间 (s) = %.9g, 峰值幅值 (cm) = %.6g\n', loc_idx, loc_t, cm);
else
    fprintf('峰值索引 (ct) = %d, 峰值幅值 (cm) = %.6g\n', loc_idx, cm);
end

end

% === 生成 m 序列函数（保留原实现） ===
function ms = produce_m(ms_Length)
if ms_Length == 63
    x=[0,0,1,0,1,0]; y=[5,6];
elseif ms_Length == 127
    x=[0,0,1,0,1,0,0]; y=[6,7];
elseif ms_Length == 255
    x=[0,0,1,0,1,0,0,0]; y=[4,5,6,8];
elseif ms_Length == 511
    x=[0,0,1,0,1,0,0,0,1]; y=[5,9];
elseif ms_Length == 1023
    x=[0,0,1,0,1,0,0,0,1,0]; y=[7,10];
elseif ms_Length == 2047
    x=[0,0,1,0,1,0,0,0,1,0,1]; y=[9,11];
else
    error('不支持的 ms_Length，请使用 63/127/255/511/1023/2047');
end
k=length(x); ms=x;
if ms_Length == 255
    for i=k+1:2^k-1
        tmp1 = xor( ms(i-y(1)), ms(i-y(2)) );
        tmp2 = xor( ms(i-y(3)), tmp1 );
        tmp3 = xor( ms(i-y(4)), tmp2 );
        ms(i) = tmp3;
    end
else
    for i=k+1:2^k-1
        ms(i)=xor(ms(i-y(1)),ms(i-y(2)));
    end
end
ms = ms * -2 + 1; % 将 0/1 -> -1/1
end
