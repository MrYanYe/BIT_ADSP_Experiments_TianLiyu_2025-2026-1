---
config:
  themeVariables:
    fontSize: 20px
  layout: fixed
---
flowchart TB
    A["高级数字信号处理"] --> B["信号表示与变换"] & C["随机信号统计分析"] & D["谱分析方法"] & E["信号检测与参数估计"] & F["高级应用技术"]
    B --> B1@{ label: "<b style=\"color:blue\">DFT/IDFT基础</b><br><font size=\"5\">实验1-7: DFT实验原理及验证,<br>matlab实现DFT,频谱泄露分析</font>" }
    B1 --> B11["离散傅里叶变换矩阵"] & B12["实数/复数信号DFT特性"] & B13["频谱泄露现象"] & B14["FFT算法优化"]
    C --> C1@{ label: "<b style=\"color:blue\">统计特征量</b><br><font size=\"5\">实验: 协方差矩阵、相关系数矩阵实验</font>" } & C2["随机信号模型"]
    C1 --> C11["协方差与相关系数"] & C12["协方差矩阵"] & C13["相关系数矩阵"]
    C2 --> C21["高斯分布"] & C22["中心极限定理"]
    D --> D1@{ label: "<b style=\"color:blue\">经典谱估计</b><br><font size=\"5\">实验: 功率谱实验</font>" } & D2@{ label: "<b style=\"color:blue\">现代谱估计</b><br><font size=\"5\">实验: 现代谱估计实验,<br>Levinson求功率谱,<br>MUSIC算法求功率谱</font>" }
    D1 --> D11["周期图法/直接法"] & D12["自相关法/间接法"] & D13["维纳-辛钦定理"] & D14["改进周期图法"]
    D14 --> D141["平均周期图法"] & D142["窗函数法"] & D143["Bartlett法"] & D144["Welch法"]
    D2 --> D21["AR模型法"] & D22["Levinson递推算法"] & D23["MUSIC算法"] & D24["子空间分解方法"]
    E --> E1@{ label: "<b style=\"color:blue\">参数估计理论</b><br><font size=\"5\">实验: 均值估计、方差估计实验,<br>初相估计实验</font>" } & E2@{ label: "<b style=\"color:blue\">信号检测</b><br><font size=\"5\">实验: 信号检测实验</font>" }
    E1 --> E11["最大似然估计"] & E12["最小二乘估计"] & E13["初相估计"] & E14["均值/方差估计"]
    E2 --> E21["匹配滤波器理论"] & E22["恒虚警率检测CFAR"] & E23["检测概率与虚警率"] & E24["蒙特卡洛仿真"]
    F --> F1@{ label: "<b style=\"color:blue\">脉冲压缩技术</b><br><font size=\"5\">实验: 匹配滤波器与脉冲压缩技术实验</font>" } & F2["信号预测"] & F3["噪声抑制"]
    F1 --> F11["相位编码信号处理"] & F12["BK码/m序列"] & F13["chirp信号处理"]
    F2 --> F21["线性预测"] & F22["外推技术"]
    F3 --> F31["信噪比提升"] & F32["信号提取"]
    B1 -. <b>基础工具</b><br>频谱分析的数学基础 .-> D11
    C11 -. <b>统计基础</b><br>自相关函数计算的核心 .-> D12
    D1 -. <b>性能优化</b><br>解决分辨率与方差矛盾 .-> D2
    E21 -. <b>核心实现</b><br>脉冲压缩的理论依据 .-> F1
    E13 -. <b>参数支撑</b><br>提升检测精度 .-> E22
    D21 -. <b>高效计算</b><br>AR模型参数快速求解 .-> D22
    D23 -. <b>高分辨率支持</b><br>多信号频率精确分离 .-> E2
    C22 -. <b>噪声模型</b><br>提供统计特性基础 .-> E24
    D2 -. <b>信号模型</b><br>AR模型用于信号预测 .-> F21
    E1 -. <b>估计理论</b><br>提供最优估计方法 .-> D21
    B1 -. <b>频谱分析</b><br>DFT是谱估计的基础工具 .-> D
    C -. <b>随机特性</b><br>为检测提供统计模型 .-> E
    E -. <b>理论支撑</b><br>检测与估计理论在实际系统中应用 .-> F

    B1@{ shape: rect}
    C1@{ shape: rect}
    D1@{ shape: rect}
    D2@{ shape: rect}
    E1@{ shape: rect}
    E2@{ shape: rect}
    F1@{ shape: rect}