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














这次实验让我对参数化谱估计和传统DFT之间的差异有了更直观的认识：在 MATLAB 中实现 Levinson 递推、用 \(N=32\)、\(f_s=1000\) 的信号（100、120、405 Hz）做对比时，我亲眼看到 DFT 因点数限制（\(\Delta f=1000/32=31.25\) Hz）无法分辨相差 20 Hz 的两条谱线，而 AR/Levinson 在合适阶数下能突破这个格点限制；具体地，当 \(p=8\) 或 \(p=12\) 时两法都分不清 100 和 120 Hz，但把 \(p\) 提高到 16（即 \(N/2\)）后 Levinson 能把两条谱线分开，继续把 \(p\) 增到 30 又出现过拟合，说明阶数过大反而有害；另外我也观察到 SNR 的影响：在高 SNR（例如 50 dB）下谱峰更尖锐、旁瓣更小，而在低 SNR（如 -1 dB）时 AR 方法仍能较好地检测到弱信号，这是因为参数化模型降低了估计自由度；还有一个实际体会是“掩蔽效应”，当两个临近分量幅度不一致（1 与 2）时，Levinson 频谱可能只显示较强的那条，说明幅度差会影响可分辨性。通过画不同 SNR 下的 \(\delta^2\) 随阶数 \(P\) 变化曲线，我也验证了一个常见规律：\(\delta^2\) 随 \(P\) 下降但边际收益递减（在 \(P<5\) 时下降最快，之后趋于平缓），这让我在今后选阶数时会更注重在分辨率与过拟合之间权衡，而不是一味追求更高阶数；总体上这次实验既加深了我对 Levinson 算法数学推导的理解，也让我在实际调参、绘图和结果判断上积累了可复用的经验。