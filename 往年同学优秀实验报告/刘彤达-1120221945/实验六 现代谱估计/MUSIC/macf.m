function [matrix]=macf(x,M)

%function [matrix]=macf(x,M)
%求估计自相关矩阵
%x     :数据行向量,下标(k=1,2,...,N)
%M     :期望的自相关矩阵的阶数,M<=N.
%matrix:自相关矩阵[MxM]

[s,N]=size(x);
matrix=zeros(M,M);
[rxx,rxx1]=acf(x,M);
for j=1:M-1
   c=rxx1(j);
   rxx1(j)=rxx1(2*M-j);
   rxx1(2*M-j)=c;
end

for i=1:M
  matrix(i,:)=rxx1(M-i+1:2*M-i);
end
