%%
%(1)
clc;
clear;
close all;
rng('default');
rng(2);

N=1e6;      %序列点数
w=randn(1,N)+i*randn(1,N);
w=abs(w);
[max0,index]=max(w);
figure(1);
plot(w(index-10:index+10));     %绘制最大值及周围20个值
title('最大值及其前后20点','FontSize',16);
m=mean(w);
k=max0*0.99/m;  %倍数
line=m*k;
error=0;
for p=1:N
        if w(p)>line
            error=error+1;  %如果有值大于门限，则虚警数+1
        end
end
% for s=1:20
%     k=3.5+0.05*s;     %设置倍数取值范围
%     error(s)=0;       %用于记录每个倍数的虚警点数
%     line=m*k;   %设置门限
%     for p=1:N
%         if w(p)>line
%             error(s)=error(s)+1;  %如果有值大于门限，则虚警数+1
%         end
%     end
% end
% figure(2);
% plot(3.5+0.05*(1:length(error)),error);   %绘制虚警次数与倍数的关系
% xlabel('倍数','FontSize',16);
% title('虚警次数','FontSize',16);

%%
%(2)
clc;
clear;
close all;
rng(2);

N=1e6;      %每次仿真生成的点数
error=0;    %用于记录虚警点数
figure(1);
for j=1:10
    w=abs(randn(1,N)+i*randn(1,N));
    [a_max(j),index]=max(w);
    subplot(2,5,j);
    plot(w(index-10:index+10));
    title(['第',num2str(j),'次序列的最大值及前后20点'],FontSize=12);
    if j==1
        m=mean(w);
        k=w(index)*0.99/m;
        line=m*k;  %根据第一次仿真的最大值设置门限
    end
    for p=1:N
        if w(p)>line
            error=error+1;  %如果有值大于门限，则虚警数+1
        end
    end
end 
figure(2);
plot(a_max);    %绘制10次序列的最大值
title('10个序列的最大值','FontSize',16);

%%
%(3)
clc;
clear;
close all;
rng(2);

N=1e6;      %每次仿真生成的点数
error=0;    %用于记录虚警点数
for j=1:100
    wj=abs(randn(1,N)+i*randn(1,N));
    w((j-1)*N+1:j*N)=wj;    %将新生成的序列拼接在w后面
    [a_max(j),~]=max(wj);   %存储当前序列的最大值
end
plot(a_max);
title('100个序列的最大值','FontSize',16);
last_max=max(a_max);
% last_line=a_max(1)*0.99;
last_line=last_max*0.98;
for p=1:N*100   %进行1e8次循环
    if w(p)>last_line
        error=error+1;  %如果有值大于门限，则虚警数+1
    end
end