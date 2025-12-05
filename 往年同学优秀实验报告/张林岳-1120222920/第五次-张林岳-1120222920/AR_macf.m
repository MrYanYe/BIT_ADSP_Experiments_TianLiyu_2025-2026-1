%求估计自相关矩阵
function [matrix]=macf(x,M)

%x     :数据行向量,下标(k=1,2,...,N)
%M     :期望的自相关矩阵的阶数,M<=N.
%matrix:自相关矩阵[MxM]

matrix=zeros(M,M);
[~,rxx1]=acf(x,M);

for j=1:M-1
   c=rxx1(j);
   rxx1(j)=rxx1(2*M-j);
   rxx1(2*M-j)=c;       %交换自相关函数中的元素
end

for i=1:M
  matrix(i,:)=rxx1(M-i+1:2*M-i);    %由自相关函数生成自相关矩阵
end
