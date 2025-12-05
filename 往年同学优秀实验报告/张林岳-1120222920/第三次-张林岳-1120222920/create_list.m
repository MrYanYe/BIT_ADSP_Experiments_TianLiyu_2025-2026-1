function list = create_list(N, T, st)
    % 创建参考值矩阵
    phi_ref = 0:st:180;
    phi_refdeg = deg2rad(phi_ref); 
    
    % 创建理论计算值矩阵
    M = sin(2*pi*T)/sin(2*pi/N*T);
    theta = 2*pi*(1/N-1)*T;
    Re = (N + M*cos(theta))*cos(phi_refdeg) + M*sin(theta)*sin(phi_refdeg);%实部
    Im = (N - M*cos(theta))*sin(phi_refdeg) + M*sin(theta)*cos(phi_refdeg);%虚部
    phi_resrad = atan2(Im,Re);
    phi_res = rad2deg(phi_resrad); 

    % 建立理论计算值和参考值的映射关系
    list = [phi_res; phi_ref];
end

