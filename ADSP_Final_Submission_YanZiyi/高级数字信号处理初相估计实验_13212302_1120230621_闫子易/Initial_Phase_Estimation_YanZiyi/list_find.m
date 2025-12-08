function phi_find = list_find(list, phi_in)
 
    % 检查DFT算出的实际值是否在查找表范围内
    if phi_in < min(list(1,:)) || phi_in > max(list(1,:))
        error('输入的 phi 值超出了查找表的范围。');
    end
    
    % 在表中查找实际值对应的理论计算值
    [~, index] = min(abs(list(1,:) - phi_in)); % 找到最接近实际值的理论值索引

    if list(1,index) == phi_in  
        %如果存在与实际值相等的理论值，则直接输出对应索引的参考值
        phi_find = list(2,index);
    else    
        %否则使用线性插值法计算参考值
        if phi_in > list(1,index)
            %实际值大于索引处理论值
            idx1 = index;
            idx2 = index + 1;
        else    
            %实际值小于索引处理论值
            idx1 = index - 1;
            idx2 = index;
        end
        % 线性插值
        pres1 = list(1,idx1);
        pres2 = list(1,idx2);
        pref1 = list(2,idx1);
        pref2 = list(2,idx2);
        phi_find = pref1 + (phi_in - pres1)/(pres2 - pres1)*(pref2 - pref1);
    end
end


