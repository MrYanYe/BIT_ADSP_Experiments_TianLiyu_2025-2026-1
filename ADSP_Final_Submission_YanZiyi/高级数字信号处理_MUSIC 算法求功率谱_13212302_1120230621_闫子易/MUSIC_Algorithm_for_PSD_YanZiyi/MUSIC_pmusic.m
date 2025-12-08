% 线谱估计 -- MUSIC方法
% f    : 复正弦信号频率向量
% x    : 数据行向量
% p    : Rxx阶数 (p > 信号个数)
% num  : 期望的变换点数
%
% 输出:
% music : MUSIC谱估计结果

function [music] = MUSIC_pmusic(f, x, p, num)

    % 初始化谱向量
    temp = zeros(1, num);

    % Step 1: 构造自相关矩阵
    Rxx = MUSIC_macf(x, p);

    % Step 2: 特征分解
    [v, d] = eig(Rxx);

    

    

    % Step 3: 按特征值大小排序（升序）
    eigvals = diag(d);
    [~, idx] = sort(eigvals, 'ascend');

%     % 取实部或绝对值并按降序排列
% eigvals_abs = abs(eigvals);
% eigvals_sorted = sort(eigvals_abs, 'descend');
% 
% % 绘图：线性刻度和对数刻度两种可选
% figure;
% % subplot(2,1,1);
% stem(eigvals_sorted, 'filled');
% xlabel('Index');
% ylabel('Eigenvalue magnitude');
% title(['Sorted eigenvalues (p = ', num2str(p), ')']);
% grid on;

    

    v = v(:, idx);
    d = diag(eigvals(idx));

    % Step 4: 计算噪声子空间
    m = length(f);   % 信号个数
    for i = 1 : p - m
        V = fft(v(:, i), num);
        temp = temp + V .* conj(V);  % MUSIC谱分母
    end

    % Step 5: 计算MUSIC谱
    music = 1 ./ temp;
end





















% %线谱估计--MUSIC方法
% function [music]=MUSIC_pmusic(f,x,p,num)
% 
% %x   :数据行向量
% %m   :Rxx阶数,m>p
% %num :期望的变换点数
% 
% temp=zeros(1,num);
% 
% %特征分解
% Rxx=MUSIC_macf(x,p);  %得到序列的p阶自相关矩阵
% [v,d]=eig(Rxx); %求Rxx矩阵的特征向量和特征值
% 
% 
% %按照特征值大小对特征值和特征向量排序
% for i=1:p-1
%     for j=1:p-i
%         if(d(j,j)>d(j+1,j+1))
%             c=d(j,j);
%             d(j,j)=d(j+1,j+1);  
%             d(j+1,j+1)=c;
%             c=v(:,j);
%             v(:,j)=v(:,j+1);
%             v(:,j+1)=c;
%         end
%     end
% end
% 
% m=length(f);    %复正弦信号的个数
% 
% for i=1:p-m 
%   V=fft(v(:,i),num);
%   temp=temp+V.*conj(V);  %该式对应MUSIC谱计算公式中的分母
% end
% 
% music=1./temp;  %由MUSIC谱的计算公式得到
