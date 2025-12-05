function [phase] = PhaseMle(z, f0, lambda)
%PHASEMLE 此处显示有关此函数的摘要
%   此处显示详细说明
N = length(z);
ph_arr = 0 : 2*pi*f0 : (N-1)*2*pi*f0;

x1 = cos(ph_arr);    %sin(2*pi*f0*n)
x2 = sin(ph_arr);    %cos(2*pi*f0*n)

de = zeros(2,2);
nu = zeros(2,2);

de(1,1) = dot(x1,z);
de(1,2) = dot(x1,x2);
de(2,1) = dot(x2,z);
de(2,2) = dot(x2,x2) + lambda;

nu(1,1) = dot(x1,x1) + lambda;
nu(1,2) = dot(x1,z);
nu(2,1) = dot(x1,x2);
nu(2,2) = dot(x2,z);

a1 = de(1,1) * de(2,2) - de(1,2) * de(2,1);
a2 = nu(1,1) * nu(2,2) - nu(1,2) * nu(2,1);

phase = rad2deg(-atan2(a2,a1));


end

