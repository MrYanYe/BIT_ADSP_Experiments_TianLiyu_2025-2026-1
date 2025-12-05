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









三种相位估计方法在数学结构和抗噪机制上存在本质差异，这直接导致了它们在实验中的性能表现分化。最大似然法和最小二乘法都属于基于模型拟合的估计方式，它们利用整个信号的结构信息进行参数提取，具有较强的抗噪性。最大似然法通过计算信号与正余弦基函数的投影比值来估计相位，其公式为：

\[
\hat{\phi}_{ML} = -\tan^{-1}\left( \frac{\sum x_n \sin(\omega n)}{\sum x_n \cos(\omega n)} \right)
\]

而最小二乘法则将信号建模为线性组合 \( x_n = A \cos(\omega n + \phi) \)，通过构造设计矩阵 \( X \) 和观测向量 \( Y \)，求解参数向量：

\[
\hat{\theta} = (X^T X)^{-1} X^T Y
\]

这两种方法都在时域中对信号进行整体拟合，能有效平均噪声影响，因此在噪声方差增大时，估计标准差虽上升但仍保持稳定，均值也始终围绕真实值波动。

相比之下，DFT方法的估计机制是从频域中某个特定频率点提取相位：

\[
\hat{\phi}_{DFT} = \angle \left( \sum x_n e^{-j\omega n} \right)
\]

这种方式只依赖一个复数频点的相位信息，极易受到噪声干扰。当噪声较强时，频谱泄漏和相位扰动会导致该点的相位严重偏移，尤其在非整数周期采样或频率不匹配时，估计结果会迅速失真。实验中可以看到，DFT方法在噪声方差达到8以上时，估计均值开始明显偏离真实值，标准差也呈爆炸式增长，最终几乎失去估计能力。这说明DFT方法在高噪环境下不具备稳定性，其估计机制缺乏对噪声的抑制能力，是导致性能崩溃的根本原因。

如果你希望进一步分析DFT映射优化是否能缓解这种问题，我可以帮你修改代码并重新运行实验。

