function psi_output = find_psi_from_table(lookup_table, phi_input)
    % 检查输入的 phi 是否在查找表范围内
    if phi_input < min(lookup_table(:,1)) || phi_input > max(lookup_table(:,1))
        error('输入的 phi 值超出了查找表的范围。');
    end
    
    % 在查找表中查找对应的 psi 值
    [~, idx] = min(abs(lookup_table(:,1) - phi_input)); % 找到最接近的索引
    if lookup_table(idx,1) == phi_input
        % 如果表中存在精确的 phi 值，则直接输出对应的 psi
        psi_output = lookup_table(idx,2);
    else
        % 如果表中没有精确的 phi 值，使用线性插值法计算 psi
        if phi_input > lookup_table(idx,1)
            idx1 = idx;
            idx2 = idx + 1;
        else
            idx1 = idx - 1;
            idx2 = idx;
        end
        
        % 线性插值
        phi1 = lookup_table(idx1,1);
        phi2 = lookup_table(idx2,1);
        psi1 = lookup_table(idx1,2);
        psi2 = lookup_table(idx2,2);
        psi_output = psi1 + (phi_input - phi1) * (psi2 - psi1) / (phi2 - phi1);
    end
end


