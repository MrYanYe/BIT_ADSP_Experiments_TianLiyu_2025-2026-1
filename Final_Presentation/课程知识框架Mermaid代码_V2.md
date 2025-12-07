---
config:
  themeVariables:
    fontSize: 30px
  layout: elk
---
flowchart TB
    A["高级数字信号处理"] --> B["信号表示与变换"] & C["随机信号分析"] & D["谱分析"] & E["检测与估计"] & F["高级应用"]
    B --> B1@{ label: "<b style=\"color:blue\">DFT核心</b><br><font size=\"5\">实验: DFT实现与频谱泄露</font>" }
    B1 --> B11["DFT数学基础"] & B12["频谱泄露/FFT优化"]
    C --> C1@{ label: "<b style=\"color:blue\">统计特征</b><br><font size=\"5\">实验: 协方差矩阵</font>" } & C2["随机模型"]
    C1 --> C11["协方差/相关分析"]
    C2 --> C21["高斯分布"]
    D --> D1@{ label: "<b style=\"color:blue\">经典谱估计</b><br><font size=\"5\">实验: 周期图法</font>" } & D2@{ label: "<b style=\"color:blue\">现代谱估计</b><br><font size=\"5\">实验: MUSIC/AR模型</font>" }
    D1 --> D11["周期图法"] & D12["改进方法"]
    D2 --> D21["AR模型"] & D22["MUSIC算法"]
    E --> E1@{ label: "<b style=\"color:blue\">参数估计</b><br><font size=\"5\">实验: 初相估计</font>" } & E2@{ label: "<b style=\"color:blue\">信号检测</b><br><font size=\"5\">实验: CFAR</font>" }
    E1 --> E11["最大似然估计"]
    E2 --> E21["匹配滤波器"] & E22["CFAR检测"]
    F --> F1@{ label: "<b style=\"color:blue\">脉冲压缩</b><br><font size=\"5\">实验: chirp信号处理</font>" } & F2["信号增强"]
    F1 --> F11["匹配滤波实现"]
    F2 --> F21["噪声抑制"]
    B1 -. DFT基础 .-> D11
    C21 -. 噪声模型 .-> E22
    D1 -. 方法演进 .-> D2
    E21 -. 理论核心 .-> F11
    D22 -. 高分辨检测 .-> E2

    B1@{ shape: rect}
    C1@{ shape: rect}
    D1@{ shape: rect}
    D2@{ shape: rect}
    E1@{ shape: rect}
    E2@{ shape: rect}
    F1@{ shape: rect}