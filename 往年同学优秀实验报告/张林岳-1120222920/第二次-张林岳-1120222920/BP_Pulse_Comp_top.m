clc;
clear;
BP_Type =input('BP_type=');
BP_Length = 511;        % 63/127/255/511/1023/2047
noieseAmp = input('noieseAmp=');    %噪声幅度
bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, noieseAmp);

%脉冲压缩函数
function bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, noieseAmp)
if BP_Type == 1
    bp_echo = [1,1,1,1,1,-1,-1,1,1,-1,1,-1,1];  %生成 BK 码
else
    bp_echo = produce_m(BP_Length);     %生成 m 序列
end
sig_length = length(bp_echo);
noise1 = noieseAmp * randn(1, sig_length);  %生成噪声信号
bp_echo_noise = bp_echo + noise1;   %回波信号
subplot(221);
plot(bp_echo);
if BP_Type == 1
    title('BK 码回波信号');
else
    title('m 序列回波信号');
end
axis([1 length(bp_echo) -2 2]);
subplot(222);
plot(bp_echo_noise);

%chirp_MF: chirp 脉压的匹配滤波器, 信号的(共轭)反转
bp_MF = bp_echo(length(bp_echo) : -1 : 1);%将回波信号反转
title('加噪声的回波信号');
axis([1 length(bp_echo_noise) min(bp_echo_noise)-1 max(bp_echo_noise)+1]);

%二相码脉冲压缩
bp_pc_result = conv(bp_echo_noise, bp_MF);
[cm,ct]=max(bp_pc_result);
subplot(223);
plot(bp_pc_result);
text(ct,cm,['(',num2str(ct),',',num2str(cm),')']);
title('二相码脉压的结果');
xlim([1,length(bp_pc_result)]);

bp_pc_result = abs(bp_pc_result) + 0.1; %加 0.1 防止对 0 求对数
subplot(224);
plot(20*log10(bp_pc_result/max(bp_pc_result)));
title('二相码脉压的结果(dB 表示)');
ylabel('dB');
xlim([1,length(bp_pc_result)]);
end

%产生 m 序列的函数
function ms = produce_m(ms_Length)
if ms_Length == 63
    x=[0,0,1,0,1,0]; %basic code, 可以设置为任何不为全 0 的 0-1 序列
    y=[5,6]; %feedback link
elseif ms_Length == 127
    x=[0,0,1,0,1,0,0];
    y=[6,7];
elseif ms_Length == 255
    x=[0,0,1,0,1,0,0,0];
    y=[4,5,6,8];
elseif ms_Length == 511
    x=[0,0,1,0,1,0,0,0,1];
    y=[5,9];
elseif ms_Length == 1023
    x=[0,0,1,0,1,0,0,0,1,0];
    y=[7,10];
elseif ms_Length == 2047
    x=[0,0,1,0,1,0,0,0,1,0,1];
    y=[9,11];
end
k=length(x);
ms=x;
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
end     %生成非0即1序列
ms=ms*-2+1; %将非 0 即 1 序列转化为非-1 即 1 序列
end