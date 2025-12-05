clear;
N = 256;
F = 0.2;
psi_arr_deg = 0:0.5:180;
% psi_arr_deg = 30;
psi_arr = deg2rad(psi_arr_deg);
M = sin(2*pi*F)/sin(2*pi/N*F);
theta = -2*pi*(1-1/N)*F;
phi_array = atan2((N-M*cos(theta))*sin(psi_arr)+M*sin(theta)*cos(psi_arr), ...
    (N+M*cos(theta))*cos(psi_arr)+M*sin(theta)*sin(psi_arr));
% phi_array2 = atan2(N*sin(psi_arr)+M*sin(theta-psi_arr), ...
%     N*cos(psi_arr)+M*cos(theta-psi_arr));
phi_array_deg = rad2deg(phi_array);
figure;
plot(psi_arr_deg, phi_array_deg);
hold on;
plot(psi_arr_deg,psi_arr_deg);