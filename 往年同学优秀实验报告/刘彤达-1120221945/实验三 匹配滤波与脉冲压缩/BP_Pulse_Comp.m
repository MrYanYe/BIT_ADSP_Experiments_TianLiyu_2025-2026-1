% Author: Tian Liyu, BIT
% Date: Nov 18, 2009
% Description: binary phase-coded signal pulse compression
%matlab ver: 7.0.4,   R14

function bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, Code_Width, Fs, noieseAmp)

if BP_Type == 1
	bp_echo = [1,1,1,1,1,-1,-1,1,1,-1,1,-1,1];
else
	bp_echo = produce_m(BP_Length);
end
sig_length = length(bp_echo);

%noieseAmp = 2;    %噪声幅度
%rng(2);     %rng噪声固定
noise1 = noieseAmp * randn(1, sig_length);      %实高斯白噪声

bp_echo_noise = bp_echo + noise1;


figure(1)
subplot(2,1,1)
plot(bp_echo);
if BP_Type == 1
	title('BK码回波信号')
else
	title('m序列回波信号')
end
axis([0 length(bp_echo)+1 -2 2])

subplot(2,1,2)
plot(bp_echo_noise);

%chirp_MF:  chirp脉压的匹配滤波器, 信号的(共轭)反转
bp_MF = bp_echo(length(bp_echo) : -1 : 1);
title('加噪声的回波信号')
axis([0 length(bp_echo_noise)+1 min(bp_echo_noise)-1 max(bp_echo_noise)+1]);


%二相码脉冲压缩
%bp_pc_result = conv(bp_echo, bp_MF);
bp_pc_result = conv(bp_echo_noise, bp_MF);
figure(2)
plot(bp_pc_result);
title('二相码脉压的结果')

bp_pc_result = abs(bp_pc_result) + 0.1;         %加0.1 防止对0求对数
figure(3)
plot(20*log10(bp_pc_result/max(bp_pc_result)));
title('二相码脉压的结果(dB表示)')
ylabel('dB');
grid

%产生m序列的函数
function	ms = produce_m(ms_Length)

if ms_Length == 63
	x=[0,0,1,0,1,0]; 	%basic code, 可以设置为任何不为全0的0-1序列
	y=[5,6];     			%feedback link
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
	end;
else
	for i=k+1:2^k-1
        ms(i)=xor(ms(i-y(1)),ms(i-y(2)));
	end;
end

ms=ms*-2+1;     %0-1序列转化为 -1/1 序列
