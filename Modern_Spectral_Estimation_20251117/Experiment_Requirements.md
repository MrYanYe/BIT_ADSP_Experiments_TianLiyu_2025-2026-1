---
title: Markdown编辑环境搭建
author: wuqx1999
date: 2023年9月21日
# 指定汉字字体，如果缺少中文显示将不正常
CJKmainfont: 方正苏新诗柳楷简体-yolan
   latex 选项
fontsize: 12pt
linkcolor: blue
urlcolor: green
citecolor: cyan
filecolor: magenta
toccolor: red
geometry: margin=0.3in
papersize: A4
documentclass: article

# pandoc设置
output:
   word_document
   # path: 你想保存的路径，默认与.md文档同文件
# 打印背景色
# 保存文件时自动生成
# export_on_save:
#   pandoc: true
---

① f1, f2 两个正弦波叠加，加噪声，SNR
|f1-f2|=Δf, 
例如，长度32，Δf<1/(32·Ts)

② AR 模型求解功率谱, P=5,15,25,35…… 谱有两个峰

③ SNR 变化，看功率谱变化

④ Δf变化，看功率谱变化

⑤ p变化，看功率谱变化

⑥ 两个正弦波幅度比变化，看功率谱变化

⑦ 预测(外推)波形：单个正弦波+噪声

x[n−1]∼x[n−p]
-> x[n]
x[n]∼x[n-p+1]
-> x[n+1]
​
外推多长,正弦波消失
阶次p可变，看是否外推更长

噪声增加 → 外推影响

合适  ${P},{SNR}$  ，加另一个正弦波，用外推后总数据做DFT，是否能出现两个谱峰

![](https://cdn-mineru.openxlab.org.cn/result/2025-11-22/6ea8af3d-4120-4f3e-bb2d-a3759cd6037c/c3422cb998b9e50f0cf2035228aa0d9a930fa281bece61851088622873be2206.jpg)

![](https://cdn-mineru.openxlab.org.cn/result/2025-11-22/6ea8af3d-4120-4f3e-bb2d-a3759cd6037c/ee559b02c9332caa8eb6f56b35c213f764907ac23564765835ba257fd0cbab8a.jpg)

x[n] = 两个正弦波 + 噪声
