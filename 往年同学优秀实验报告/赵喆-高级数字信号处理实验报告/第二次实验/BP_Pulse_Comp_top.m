% Author: Tian Liyu, BIT
% Date: Nov. 18, 2009
% Description: Set parameters, then call BP_Pulse_Comp
%matlab ver: 7.0.4,   R14

clear all;
close all;
%rng(2);
%BK code parameters
% BP_Type = 1;	%1-BK code, BP_Length = 13; 2-m sequence, BP_Length
% BP_Length = 13;
% Code_Width = 0.1e-6;
% Fs = 10e6;

%m sequence parameters
BP_Type = 2;	
BP_Length = 127;		% 63/127/255/511/1023/2047
Code_Width = 0.1e-6;
Fs = 10e6; 
noieseAmp = 5;          %

bp_pc_result = BP_Pulse_Comp(BP_Type, BP_Length, Code_Width, Fs, noieseAmp);



