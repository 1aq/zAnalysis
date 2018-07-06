# zAnalysis是什么？ #

zAnalysis是基于Pascal语言编写的大型统计学开源库，它不依赖于任何三方库，并且可以跨平台和并行化计算

zAnalysis不限制你的任何商业用途和拷贝，包括二次开发

# 运行平台支持 #
- **IOS armv7 - delphi/fpc 100%兼容**
- **IOS arm64 - delphi/fpc 100%兼容**
- **Anroid - delphi/fpc 100%兼容**
- **Windows - delphi/fpc x86/100%兼容**
- **Windows - delphi/fpc x64/100%兼容**
- **Linux - delphi/fpc x64/100%兼容**
- **OSX - delphi/fpc x86/100%兼容**
- **Linux - delphi x86/不兼容 - fpc x86/x64/100%兼容**
- **OSX - 下一次更新版本会全面支持x64/x86**
- **树莓派Linux - 下一次更新版本会全面支持树莓派**


# 开发平台支持 #
- Freepascal with Lazarus，http://lazarus.freepascal.org/
- CodeTyphone，http://www.pilotlogic.com/
- Delphi XE10 或以上版本，http://embarcadero.com/


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
- sift高斯金字塔及sift特征匹配支持
- HOG梯度方向直方图及特征匹配
- 图片相似性相关：基于方差图采样(分别支持PCA主成分分析与LDA线性判别分析，这里的方差图采样不是梯度方差图)
- 图片相似性相关：基于皮尔逊,斯皮尔曼,k空间的相似性查找
- 最小走样化缩放技术（高斯平滑缩放，灰度缩放，快速平滑缩放）
- 光栅库不需要任何外部底层api支持，天然工作于系统内存中，并且平台无关性
- 光栅库内核支持并行化框架
- 光栅库支持JpegLS无损压缩(灰度，RGB，RGBA)
- 光栅库支持BRRC梯度压缩，支持哈夫曼压缩
- 光栅库支持顶点渲染
- 光栅库支持平台无关性的字体系统
- 光栅库支持面向H264及YUV2MPEG的视频打包
- 光栅库支持AGG高保真像素系统

**数据库集成 Test Pass**
- 内置ZDB本地数据库，ZDB可以作为大型数据库的伴侣数据库，为项目提供统计学支持
- 内置ZDB内存数据库支持
- ZDB可以轻松改造成网络数据库后台，并且能基于zServer项目轻松搭建机器学习的后台框架

**其它支持**
- 100%兼容linux桌面开发(fpc方向)
- ffmpeg待支持（平台无关性）
- 小型渲染引擎支持（平台无关性，支持并行化渲染，支持多线程渲染，支持所有运行平台）
- zSound音频库支持（平台无关性，支持播放音乐，音效，混音等等功能）
- 提供快速存储与恢复，可以动态读取，计算结果，无需训练
- 部分数据格式可以兼容MATLAB
- 机器学习状态可以导出成Json格式
- 以匿名函数方式训练(匿名函数只能工作于Delphi开发平台，不支持fpc)
- 安全浮点运算
- 安全动态数组处理
- 后台HPC服务器运算支持
- 工具集


## 面向未来支持的补完计划
- 完善使用文档和Demo
- 金融领域数据统计和分析的傻瓜支持
- 中小型企业级数据统计和分析的傻瓜支持
- 在游戏领域使用机器学习
- 自然语言处理的傻瓜支持(完善中，请参见我的开源项目 https://github.com/PassByYou888/zChinese)
- 加强视觉库的傻瓜支持(物体识别支持，人脸识别支持，**已经支持SIFT，HOG算法**)
- 对第三方大数据源支持(例如google提供的大数据源)
- 可二次开发的模型化机器学习平台
- 分布式云服务器计算后台
- 提供plot二维可视化图形api(光栅库已经加强，下一版本将提供模型呈现系统)

## 编译注意事项


**首次编译前，先运行Source\MemoryRaster_DefaultFont_build.bat，生成一次字体库**

**默认环境下，光栅引擎不支持中文，假如要使用中文，请用字体工具重新生成一次中文字体库（让它包含GBK字符集）**

**在Source中的子目录，均对开发或则运行平台有所要求**
- source\DrawInterfaceInFMX，必须使用delphi+fmx才能进行编译，运行平台支持ios,android,osx,windows，不支持linux
- source\SoundInterfaceInFMX，，必须使用delphi+fmx才能进行编译，运行平台支持ios,android,osx,windows，不支持linux
- source\SoundInterfaceInBass，bass是平台无关性(fpc+delphi+所有操作系统)，详见zSound开源工程的部署方法 https://github.com/PassByYou888/zSound

**在Source中的所有库均为平台无关性支持**
- source中的所有*.pas均为平台关性，包括编译器fpc+laz与delphi的支持，包括各个系统环境的支持，均能无关性

**编译和开发基于Linux桌面的机器学习应用是fpc方向，需要搭建环境，请参看文档**

- Linux桌面开发指南.pdf

**在linux或则fpc编译器出来的应用启动缓慢的解决办法**
1. 解决办法1：自行外挂一个内存管理单元，比如TCMAlloc
2. 解决办法2：使用字体工具，将字体库改小（不创建BGK字符集），重新生成字体库
3. 解决办法3：将 https://github.com/PassByYou888/zRasterization/Source 中的所有文件copy到zAnalysis/Source中覆盖

**在Windows中使用高速d2d绘图请参看文档**

- 在苹果和安卓手机平台中让DrawEngine在FMX中加速工作.docx



## 近期更新日志

**2018-7-6**
- 大幅修正底层库的命名规则
- 全面支持Linux桌面级的机器学习应用程序开发
- 对fpc编译器3.1.1全面支持
- 新增大小字节序支持
- 修复对32位fpc编译器不认for用Int64的问题
- 修复字符串在fpc编译器运行于linux发生异常的问题
- 新增pascal预编译工具，将pascal代码规范成c风格的全部统一大小写，全面兼容Linux区分大小写文件名的机制
- 下次更新会新增声纹特征提取

**2018-6-25**
- 通过写模板缓冲区技术，修正顶点渲染器发生三角边缘重叠的问题
- 增加高速椭圆绘制与高速椭圆填充
- 将顶点渲染器record修饰符改为class修饰符
- Learn增加SaveToFile，LoadFromFile
- ObjectData.pas, UnicodeMixedLib.Pas 大量常量重命名
- 调节了高斯精度

**2018-6-22**

**更新列表**
- 修复JLS无损压缩的格式不兼容JPEG问题（现在每次打开JLG会检查3个标签，不会再出现不兼容错误）
- 将JLS无损压缩的Log提示改用了DoStatus
- JLS无损压缩已经通过官方JLS样本测试
- 将内存光栅库的字节序格式改为了标准BGRA格式
- 修复内存光栅库中色彩到浮点转换bug
- sift金字塔系统不再是只支持灰度，现在支持尺度色差
- zDrawEngine中的方框绘制，方框填充，文字绘制，现在支持旋转特性
- 多线程渲染的数据交换需求：zDrawEngine中的Command List，现在可以被复制出来
- 修改了DoStatus的锁机制，现在DoStatus支持在并行线程打印，不再会发生线程锁死，调试更方便
- 大量更新Gemetry2DUnit中的函数命名
- 移除一个在CoreAtomic.inc中的检查函数，小幅提升多线程性能
- 将TLearn的Constructor修饰符以Class function替代

**新增功能**

- 新增纯pascal实现的H264软编码器，全平台已测试通过
- 新增YUV4MPEG格式支持，全平台已测试通过
- 新增高保真AGG库，剔除了原AGG库中的所有字体系统，大面积修复AGG的编译和跨平台问题，，全平台已测试通过
- 新增基于三角插值模拟矩阵运算的软件渲染器
- 软件渲染器已与H264+YUV4MPEG相互贯通，可以在渲染中同时输出视频
- 新增反走样字体系统，反走样字体系统跨平台，良好支持FPC+Delphi
- 新增高速梯度直方图的特征算法
- 在MemoryRaster库内置了AGG系统，反走样字体系统，三角填充系统
- 基于zDrawEngine新增了直接向MemoryRaster输出的软件渲染接口
- 在Learn新增了梯度直方图的全面性支持
- 在Learn新增了Sift的部分支持
- 新增FontBuild工具(创建跨平台字体库)
- 新增Demo：15 yuv视频转换h264
- 新增Demo：16 软渲染器
- 新增Demo：18 基于梯度方向的大规模图片特征码提取与识别
- 新增Demo：19 基于神经元的梯度方向识别


----------


使用问题请加在互助qq群490269542
 
请不要直接加作者，谢谢大家

2018-4

