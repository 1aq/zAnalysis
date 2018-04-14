# zAnalysis是什么？ #

zAnalysis是基于Pascal语言编写开源机器学习库，它不依赖于任何三方库，并且可以跨平台和并行化计算

zAnalysis不限制你的任何商业用途和拷贝，包括二次开发

# 运行平台支持 #
- **IOS armv7 - delphi/fpc 100%兼容**
- **IOS arm64 - delphi/fpc 100%兼容**
- **Anroid - delphi/fpc 100%兼容**
- **Windows - delphi/fpc x86/100%兼容**
- **Windows - delphi/fpc x64/100%兼容**
- **Linux - delphi/fpc x64/100%兼容**
- **OSX - delphi/fpc x86/100%兼容**
- **Linux - delphi x86/不兼容 - fpc x86/100%兼容**
- **OSX - delphi x64/不兼容 - fpc x64/100兼容**


# 开发平台支持 #
- Freepascal with Lazarus
- Delphi XE10 或以上版本


# 指标

暂无指标统计程序


# zAnalysis支持哪些功能 #


**神经网络支持 Test Pass**
- 动态KD空间树支持(纯数组的非链表计算内核，支持并行化查找，内置临近K聚类，只支持双浮点)
- 高速静态KD空间树支持(纯数组的非链表计算内核，支持并行化查找，内置临近K聚类，支持8种整型和浮点变量类型)
- 临近k聚类支持
- LBFGS-大规模拟牛顿法(支持并行化，支持神经网络集成) 
- 非线性最小二乘法(牛顿法进阶版本，支持并行化，支持神经网络集成) 
- 随机森林决策树学习
- 评定模型的逻辑回归
- 蒙特卡罗抽样学习
- 图片采样：主成分采样，线性判定采样，灰度反走样，矩阵采样
- 神经网络多层感知器
- 卷积计算二次开发支持
- 分类器支持
- 因变量支持

**正太分布检测 Test Pass**
- F检测
- 二项式化分布检测
- 方差分布检测
- t分布检测
- 皮尔逊分布检测
- 斯皮尔曼分布检测

**正太分布计算 Test Pass**
- 正太分布函数
- 泊松分布
- F分布
- 二项式化分布支持计算
- 方差分布计算
- t分布计算
- 皮尔逊分布
- 斯皮尔曼分布
- Jarque-Bera检验计算
- 曼-惠特尼U检验计算
- 威尔科克森符号秩检验计算

**基础视觉库 Test Pass**
- 图片相似性相关：基于方差图采样(分别支持PCA主成分分析与LDA线性判别分析)
- 图片相似性相关：基于皮尔逊,斯皮尔曼,k空间的相似性查找
- 最小走样化缩放(专业支持的最小走样缩放，非常规处理方法)
- 光栅图片库支持FMX内置集成

**数据库集成 Test Pass**
- 内置ZDB本地数据库，ZDB可以作为大型数据库的伴侣数据库，为项目提供统计学支持
- 内置ZDB内存数据库支持
- ZDB可以轻松改造成网络数据库后台，并且能基于zServer项目轻松搭建机器学习的后台框架

**其它支持**
- 提供快速存储与恢复，可以动态读取，计算结果，无需训练
- 部分数据格式可以兼容MATLAB
- 机器学习状态可以导出成Json格式
- 以匿名函数方式训练(匿名函数只能工作于Delphi开发平台，不支持fpc)
- 安全浮点运算
- 安全动态数组处理
- 后台HPC服务器运算支持
- 工具集

# 面向未来支持的补完计划 #
- 完善使用文档和Demo
- 金融领域数据统计和分析的傻瓜支持
- 中小型企业级数据统计和分析的傻瓜支持
- 在游戏领域使用机器学习
- 自然语言处理的傻瓜支持
- 加强视觉库的傻瓜支持(物体识别支持，人脸识别支持，SIFT基础支持库)
- 对第三方大数据源支持(例如google提供的大数据源)
- 可二次开发的模型化机器学习平台
- 分布式云服务器计算后台
- 提供plot二维可视化图形api


**如果你支持zAnalysis开发，请向作者捐款，希望捐赠后能留下真实姓名和联系方式，开发建议请发至作者邮箱** [600585@qq.com](mailto:600585@qq.com "600585@qq.com")

![](alipay.jpg)



使用问题请加在互助qq群490269542
 
请不要直接加作者，谢谢大家

2018-4

