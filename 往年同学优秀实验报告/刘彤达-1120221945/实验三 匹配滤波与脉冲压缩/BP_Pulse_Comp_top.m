% Author: Tian Liyu, BIT
% Date: Nov. 18, 2009
% Description: Set parameters, then call BP_Pulse_Comp
%matlab ver: 7.0.4,   R14

clear all;
close all;
%m sequence parameters
BP_Type = 2;	%更改为1和2两种类型
BP_Length = 1023;		% 63/127/255/511/1023/2047
Code_Width = 0.1e-6;
Fs = 10e6; 
noieseAmp = 10.5     %更改噪声信号幅度

bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, Code_Width, Fs, noieseAmp);



