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

实验
1. \( N = 256 \)，估计 \( \hat{\phi}_{ml} \left\{ \begin{array}{l} 30^\circ \\ 90^\circ \\ 135^\circ \end{array} \right. \)
修改 \( N \uparrow \) 2倍增到65536，看标准差变化
2. \( k = 1 \)，整周期，非整周期时(\( 1.1, 1.3, 1.8 \))，如何优化 性能变化？
3. 改噪声方差，看 \( \hat{\phi}_{ml} \) 标准差变化，关系作图
4. 对比，DFT求初相方法（整周期和非整周期）谁优谁劣





1.N = 256，估计 phi^_ml 30度，90度，135度 
修改 N↑ 2 倍增到 65536，看标准差变化
2.k = 1，整周期，非整周期时( 1.1, 1.3, 1.8 )，如何优化 性能变化？
3.改噪声方差，看 phi^_ml 标准差变化，关系作图
4.对比，DFT 求初相方法（整周期和非整周期）谁优谁劣