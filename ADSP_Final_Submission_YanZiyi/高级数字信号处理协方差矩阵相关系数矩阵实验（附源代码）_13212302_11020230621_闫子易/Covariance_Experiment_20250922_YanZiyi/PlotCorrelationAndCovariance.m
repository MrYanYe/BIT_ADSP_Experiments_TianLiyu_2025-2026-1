


function PlotCorrelationAndCovariance(N, sigma, r_values)
    % 判断是 N 变化还是 r 变化
    if numel(r_values) > 1 && numel(N) == 1
        variable = 'r';
        values = r_values;
    elseif numel(N) > 1 && numel(r_values) == 1
        variable = 'N';
        values = N;
    else
        error('N 和 r_values 不能同时是数组，只能有一个是数组');
    end

    % 结果存储
    Cov_all = zeros(2,2,length(values));
    Corr_all = zeros(2,2,length(values));

    for k = 1:length(values)
        if variable == "r"
            [X, Y] = GenerateRandomVariables(N, sigma, values(k));
        else
            [X, Y] = GenerateRandomVariables(values(k), sigma, r_values);
        end

        Cov_all(:,:,k) = MyCov(X, Y);
        Corr_all(:,:,k) = MyCorrCoef(X, Y);

        % 检查相关系数
        if any(abs(Corr_all(:,:,k)) > 1+1e-10, 'all')
            warning('相关系数超出范围: %f', max(abs(Corr_all(:,:,k)),[],'all'));
        end
    end

    % 转换为热力图数据: 每个矩阵元素随变量变化
    figure;
    colormap("jet"); 
    for i = 1:2
        for j = 1:2
            subplot(2,2,(i-1)*2+j);
            imagesc(values, 1, squeeze(Cov_all(i,j,:))');
            colorbar;
            xlabel(variable);
            ylabel(sprintf('Cov(%d,%d)', i,j));
            title(sprintf('协方差矩阵元素 C(%d,%d) 随 %s 变化', i,j,variable));
        end
    end
    sgtitle('协方差矩阵热力图');

    figure;
    colormap("jet"); 
    for i = 1:2
        for j = 1:2
            subplot(2,2,(i-1)*2+j);
            imagesc(values, 1, squeeze(Corr_all(i,j,:))');
            colorbar;
            xlabel(variable);
            ylabel(sprintf('Corr(%d,%d)', i,j));
            title(sprintf('相关系数矩阵元素 R(%d,%d) 随 %s 变化', i,j,variable));
            caxis([-1 1]); % 相关系数范围限制
        end
    end
    sgtitle('相关系数矩阵热力图');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % 绘制 Cov_all 折线图
    figure;
    for i = 1:2
        for j = 1:2
            subplot(2,2,(i-1)*2+j);
            plot(values, squeeze(Cov_all(i,j,:)), 'LineWidth', 1.5);
            xlabel(variable);
            ylabel(sprintf('Cov(%d,%d)', i, j));
            grid on;
        end
    end
    sgtitle('Covariance Matrix Elements');
    
    % 绘制 Corr_all
    figure;
    for i = 1:2
        for j = 1:2
            subplot(2,2,(i-1)*2+j);
            plot(values, squeeze(Corr_all(i,j,:)), 'LineWidth', 1.5);
            xlabel(variable);
            ylabel(sprintf('Corr(%d,%d)', i, j));
            grid on;
        end
    end
    sgtitle('Correlation Matrix Elements');







end   % PlotCorrelationAndCovariance







% function PlotCorrelationAndCovariance(N, sigma, r)
%     % 判断哪个是数组
%     if numel(N) > 1 && numel(r) == 1
%         varying_var = 'N';
%         x_values = N;
%     elseif numel(r) > 1 && numel(N) == 1
%         varying_var = 'r';
%         x_values = r;
%     else
%         error('N 和 r 不能同时为数组，必须有一个是单个数值。');
%     end
% 
%     num_vals = length(x_values);
% 
%     % 存储协方差矩阵和相关系数矩阵 (每个是2x2)
%     cov_mats = zeros(2,2,num_vals);
%     corr_mats = zeros(2,2,num_vals);
% 
%     % 遍历
%     for k = 1:num_vals
%         if strcmp(varying_var, 'r')
%             r_k = x_values(k);
%             N_k = N;
%         else
%             r_k = r;
%             N_k = x_values(k);
%         end
% 
%         % 协方差矩阵
%         Sigma = [sigma^2, r_k*sigma^2; r_k*sigma^2, sigma^2];
%         data = mvnrnd([0 0], Sigma, N_k);  % 生成数据
%         X = data(:,1);
%         Y = data(:,2);
% 
%         C = MyCov(X, Y);
%         R = MyCorrCoef(X, Y);
% 
%         cov_mats(:,:,k) = C;
%         corr_mats(:,:,k) = R;
%     end
% 
%     % ==== 绘制协方差矩阵热力图 ====
%     figure('Name','Covariance Matrix Variation');
%     for i = 1:2
%         for j = 1:2
%             subplot(2,2,(i-1)*2+j);
%             imagesc(x_values, 1, squeeze(cov_mats(i,j,:))'); 
%             colormap('jet'); colorbar;
%             xlabel(varying_var);
%             yticks([]);
%             title(sprintf('Cov(%d,%d)', i,j));
%         end
%     end
% 
%     % ==== 绘制相关系数矩阵热力图 ====
%     figure('Name','Correlation Matrix Variation');
%     for i = 1:2
%         for j = 1:2
%             subplot(2,2,(i-1)*2+j);
%             imagesc(x_values, 1, squeeze(corr_mats(i,j,:))'); 
%             colormap('jet'); colorbar;
%             xlabel(varying_var);
%             yticks([]);
%             title(sprintf('Corr(%d,%d)', i,j));
%         end
%     end
% end




% function PlotCorrelationAndCovariance(N, sigma, r)
%     % 判断哪个是数组
%     if numel(N) > 1 && numel(r) == 1
%         varying_var = 'N';
%         x_values = N;
%     elseif numel(r) > 1 && numel(N) == 1
%         varying_var = 'r';
%         x_values = r;
%     else
%         error('N 和 r 不能同时为数组，必须有一个是单个数值。');
%     end
% 
%     num_vals = length(x_values);
% 
%     % 存储协方差和相关系数
%     cov_xy = zeros(1, num_vals);
%     corr_xy = zeros(1, num_vals);
% 
%     % 遍历
%     for k = 1:num_vals
%         if strcmp(varying_var, 'r')
%             r_k = x_values(k);
%             N_k = N;
%         else
%             r_k = r;
%             N_k = x_values(k);
%         end
% 
%         % 协方差矩阵
%         Sigma = [sigma^2, r_k*sigma^2; r_k*sigma^2, sigma^2];
%         cov_xy(k) = Sigma(1,2);
% 
%         % 相关系数矩阵
%         R = [1, r_k; r_k, 1];
%         corr_xy(k) = R(1,2);
% 
%         % 如果想画散点，可以在这里生成数据
%         % X = mvnrnd([0 0], Sigma, N_k);
%         % figure; scatter(X(:,1), X(:,2));
%     end
% 
%     % 绘制协方差和相关系数随变量变化
%     figure('Name','Covariance and Correlation');
%     subplot(2,1,1);
%     plot(x_values, cov_xy, 'b-o','LineWidth',1.5);
%     xlabel(varying_var); ylabel('Cov(X,Y)');
%     title(['协方差随 ', varying_var, ' 的变化']);
%     grid on;
% 
%     subplot(2,1,2);
%     plot(x_values, corr_xy, 'r-s','LineWidth',1.5);
%     xlabel(varying_var); ylabel('Corr(X,Y)');
%     title(['相关系数随 ', varying_var, ' 的变化']);
%     grid on;
% end





% function PlotCorrelationAndCovariance(N, sigma, r_values)
%     num_r = length(r_values);
%     num_rows = ceil(sqrt(num_r));
%     num_cols = ceil(num_r/num_rows);
% 
%     % 存储协方差矩阵和相关系数矩阵的元素
%     cov_xy = zeros(1, num_r);
%     corr_xy = zeros(1, num_r);
% 
%     figure('Name','Scatter Plots for Different r');
%     for k = 1:num_r
%         r = r_values(k);
% 
% 
% 
%         % 协方差矩阵
%         Sigma = [sigma^2, r*sigma^2; r*sigma^2, sigma^2];
%         cov_xy(k) = Sigma(1,2);
% 
%         % 相关系数矩阵
%         R = [1, r; r, 1];
%         corr_xy(k) = R(1,2);
%     end
% 
%     % 单独画协方差和相关系数随 r 的变化
%     figure('Name','Covariance and Correlation vs r');
%     subplot(2,1,1);
%     plot(r_values, cov_xy, 'b-o','LineWidth',1.5);
%     xlabel('r'); ylabel('Cov(X,Y)');
%     title('协方差随 r 的变化');
%     grid on;
% 
%     subplot(2,1,2);
%     plot(r_values, corr_xy, 'r-s','LineWidth',1.5);
%     xlabel('r'); ylabel('Corr(X,Y)');
%     title('相关系数随 r 的变化');
%     grid on;
% end
