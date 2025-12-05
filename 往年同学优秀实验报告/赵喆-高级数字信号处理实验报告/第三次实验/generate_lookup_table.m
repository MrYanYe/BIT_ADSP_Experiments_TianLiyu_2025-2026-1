function lookup_table = generate_lookup_table(N, F)
    % 创建 psi 和 phi 之间的映射关系
    psi_arr_deg = 0:0.5:180; % 以步长 0.5 构建 psi 数组
    psi_arr = deg2rad(psi_arr_deg); % 将 psi 转换为弧度制
    
    % 计算 M 和 theta
    M = sin(2*pi*F)/sin(2*pi/N*F);
    theta = -2*pi*(1-1/N)*F;
    
    % 计算 phi_array
    phi_array = atan2((N - M*cos(theta)) * sin(psi_arr) + M*sin(theta) * cos(psi_arr), ...
                      (N + M*cos(theta)) * cos(psi_arr) + M*sin(theta) * sin(psi_arr));
    phi_array_deg = rad2deg(phi_array); % 将 phi 转换为角度制

    % 构建查找表，将 phi 和 psi 对应关系存储
    lookup_table = [phi_array_deg', psi_arr_deg'];
end

