%线谱估计--MUSIC方法
function [music]=pmusic(f,x,p,num)

%x   :数据行向量
%m   :Rxx阶数,m>p
%num :期望的变换点数

temp=zeros(1,num);

%特征分解
Rxx=macf(x,p);  %得到序列的p阶自相关矩阵
[v,d]=eig(Rxx); %求Rxx矩阵的特征向量和特征值


%按照特征值大小对特征值和特征向量排序
for i=1:p-1
    for j=1:p-i
        if(d(j,j)>d(j+1,j+1))
            c=d(j,j);
            d(j,j)=d(j+1,j+1);  
            d(j+1,j+1)=c;
            c=v(:,j);
            v(:,j)=v(:,j+1);
            v(:,j+1)=c;
        end
    end
end

m=length(f);    %复正弦信号的个数

for i=1:p-m 
  V=fft(v(:,i),num);
  temp=temp+V.*conj(V);  %该式对应MUSIC谱计算公式中的分母
end
  
music=1./temp;  %由MUSIC谱的计算公式得到
