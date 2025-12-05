function [rxx,rxx1]=acf(x,M)

%function [rxx,rxx1]=acf(x,M)
%求一组数据的估计自相关函数.
%公式取自<<现代谱估计>> P58 (4.20)
%x   : 数据样本(行向量),下标(k=1,2,...,N)
%M   : 期望的自相关序列的阶数,M<=N.
%rxx : 自相关函数(行向量),下标为正(k=1,2,...,M).
%rxx1: 自相关函数(行向量),下标为(k=1,2,...,2*M-1)
%                         相当于(k=-M+1,...,0,...M-1)

[a,N]=size(x);
rxx=zeros(1,M);

for k=0:M-1
  for n=1:N-k
     rxx(k+1)=rxx(k+1)+conj(x(n))*x(n+k);
  end
  rxx(k+1)=rxx(k+1)/N;
end

rxx1=zeros(1,2*M-1);
rxx1(M)=rxx(1);
for i=1:M-1
   rxx1(i)=conj(rxx(M-i+1));
   rxx1(i+M)=rxx(i+1);
end

  

  