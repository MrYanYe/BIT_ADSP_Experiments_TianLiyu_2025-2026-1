%AR谱估计--伯格法
function [burg,var]=pburg(x,ip,num)

%x   :数据样本行向量
%ip  :Ak的阶数
%num :期望的功率谱的点数

[~,N]=size(x);
bp_1=zeros(1,N);
ep_1=zeros(1,N);
bp=zeros(1,N);      %后向预测误差
ep=zeros(1,N);      %前向预测误差
a=zeros(ip,ip);

rho0=0;
for n=1:N
   rho0=rho0+(abs(x(n))^2)/N;   %确定初始条件
end

for n=2:N
   ep_1(n)=x(n);
   bp_1(n-1)=x(n-1);    %递推
end  
%迭代
for p=1:ip
    sumn=0;
    sumd=0;
     for n=p+1:N
      sumn=sumn+ep_1(n)*conj(bp_1(n-1));
      sumd=sumd+abs(ep_1(n))^2+abs(bp_1(n-1))^2;    
     end
    a(p,p)=-2*sumn/sumd;        %求得Kp
  
    if p==1
      rho(p)=(1-abs(a(p,p))^2)*rho0;
    else
      rho(p)=(1-abs(a(p,p))^2)*rho(p-1);    %由sigma_P^2的递推公式得到
    end

%if(ip==1) 
%  break; %跳出k循环
%end
    if p>1
       for i=1:p-1
        a(i,p)=a(i,p-1)+a(p,p)*conj(a(p-i,p-1));    %由a_pi的计算公式得到
       end
    end      
    for n=p+2:N
      ep(n)=ep_1(n)+a(p,p)*bp_1(n-1);
      bp(n-1)=bp_1(n-2)+conj(a(p,p))*ep_1(n-1);     %由前向-后向预测误差递推公式得到
    end
    for n=p+2:N
      ep_1(n)=ep(n);
      bp_1(n-1)=bp(n-1);   %递推
    end
end 

var=rho(ip);        %rho(ip)即为ip阶模型估计的sigma^2
Ak=zeros(1,ip);

for n=1:ip
  Ak(n)=a(n,ip);    %储存P阶模型的系数a_pi
end
  
%对Ak做FFT
b=[1,Ak];
B=fft(b,num);
p=B.*conj(B);
p1=var./p;          %由功率谱表达式得到
burg=abs(p1);

% %翻转
% for i=1:num/2
%   c=burg(i);
%   burg(i)=burg(i+num/2);
%   burg(i+num/2)=c;
% end








  