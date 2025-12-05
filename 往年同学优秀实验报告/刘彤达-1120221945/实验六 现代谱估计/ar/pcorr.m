function [corr,var]=pcorr(x,p,num)

%function [corr]=pcorr(x,p,num)
%AR谱估计--自相关法
%x   :数据样本行向量
%p   :Ak的阶数
%num :期望的功率谱的点数

[s,N]=size(x)
[rxx,rxx1]=acf(x,p+1);
mr = macf(x,p);
ak=-inv(mr)*(rxx(1,2:p+1)).';   %rxx(1,2:p+1),去掉rxx(0), %a的值
temp=[1;ak];

var=0;
for i=1:p
  var=var+ak(i)*rxx1(p-i+1);
end
var=rxx(1)+var;



p0=fft(temp,num);
p1=p0.*conj(p0);
p2=var./p1;
corr=abs(p2);

%figure(100);plot(corr)
%翻转
% for i=1:num/2
%   c=corr(i);
%   corr(i)=corr(i+num/2);
%   corr(i+num/2)=c;
% end
%figure(101);plot(corr)



