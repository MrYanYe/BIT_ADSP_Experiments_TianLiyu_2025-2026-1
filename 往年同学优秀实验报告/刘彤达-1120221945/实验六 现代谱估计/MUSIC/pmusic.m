function [music]=pmusic(x,p,m,num)

%线谱估计--MUSIC方法
%x   :数据行向量
%p   :协波数已知
%m   :Rxx阶数,m>p
%num :期望的变换点数

temp=zeros(1,num);

%特征分解
Rxx=macf(x,m);
[v,d]=eig(Rxx);

%d的特征向量不是从小到大排列的!

%排序
for i=1:m-1
for j=1:m-i
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

%现在是从小到大排列的!
for i=1:m-p
  fft( (v(:,i))',num);
  temp=temp+ans.*conj(ans);  
end
  
music=1./temp;
