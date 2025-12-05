function [burg,var]=pburg(x,ip,num)

%function [burg,var]=pburg(x,ip,num)
%AR谱估计--伯格法
%x   :数据样本行向量
%ip  :Ak的阶数
%num :期望的功率谱的点数


[s,N]=size(x)
ebk1=zeros(1,N);%%存储后向误差
efk1=zeros(1,N);%%存储前向误差
ebk=zeros(1,N);%%存储更新后的后向误差
efk=zeros(1,N);%%存储更新后的前向误差
aa=zeros(ip,ip);


rho0=0;%%最小预测误差
for i=1:N
   rho0=rho0+(abs(x(i))^2)/N;
end
for i=2:N
   efk1(i)=x(i);
   ebk1(i-1)=x(i-1);
end  
%迭代
for k=1:ip
    sumn=0;
    sumd=0;
     for i=k+1:N
      sumn=sumn+efk1(i)*conj(ebk1(i-1));
      sumd=sumd+abs(efk1(i))^2+abs(ebk1(i-1))^2;    
     end
    aa(k,k)=-2*sumn/sumd;
  
    if k==1
      rho(k)=(1-abs(aa(k,k))^2)*rho0;
    else
      rho(k)=(1-abs(aa(k,k))^2)*rho(k-1);
    end

%if(ip==1) 
%  break; %跳出k循环
%end
    if k>1
       for j=1:k-1
        aa(j,k)=aa(j,k-1)+aa(k,k)*conj(aa(k-j,k-1));
       end
    end      
    for i=k+2:N
      efk(i)=efk1(i)+aa(k,k)*ebk1(i-1);%%%更新前向误差
      ebk(i-1)=ebk1(i-2)+conj(aa(k,k))*efk1(i-1);%%%更新后向误差
    end
    for i=k+2:N
      efk1(i)=efk(i);
      ebk1(i-1)=ebk(i-1);   
    end
end %k循环

var=rho(ip);
Ak=zeros(1,ip);
for i=1:ip
  Ak(i)=aa(i,ip);
end
  
%对Ak做FFT
b=[1,Ak];
fft(b,num);
p=ans.*conj(ans);
p1=var./p;          % (5.9)式
burg=abs(p1);

%翻转
for i=1:num/2
  c=burg(i);
  burg(i)=burg(i+num/2);
  burg(i+num/2)=c;
end








  