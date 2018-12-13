program NNDecisionDemo;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  DoStatusIO,
  LearnTypes,
  Learn;

var
  lr: TLearn;
  n: TPascalString;
  lt: TLearnType;

begin
  // ������ʾ������ʹ��������������ݷ���
  for lt in [
    ltKDT,            // KDTree, fast space operation, this not Neurons network
  ltKM,               // k-means++ clusterization, this not Neurons network
  ltForest,           // random decision forest
  ltLogit,            // Logistic regression
  ltLM,               // Levenberg-Marquardt
  ltLM_MT,            // Levenberg-Marquardt with parallel
  ltLBFGS,            // L-BFGS
  ltLBFGS_MT,         // L-BFGS with parallel
  ltLBFGS_MT_Mod,     // L-BFGS with parallel and optimization
  ltLM_Ensemble,      // Levenberg-Marquardt Ensemble
  ltLM_Ensemble_MT,   // Levenberg-Marquardt Ensemble with parallel
  ltLBFGS_Ensemble,   // L-BFGS Ensemble
  ltLBFGS_Ensemble_MT // L-BFGS Ensemble with parallel
    ] do
    begin
      // CreateClassifier2 �Ǵ���һ�����������֪������������ѧϰ��
      // CreateClassifier�������κ�ʱ�򣬶���һ�����������ֵ
      lr := TLearn.CreateClassifier2(lt, 5);

      // 1 1 1 1 1�������һ��1��ʾn������ά�ȣ��������˵������ֵ
      // k1��ʾ�����ţ����ߺ������Ե�
      lr.AddMemory('1 1 1 1 1=k1');      // ��������ֵ0
      lr.AddMemory('1 2 1 2 1=k2');      // ��������ֵ1
      lr.AddMemory('10 10 21 12 21=k3'); // ��������ֵ2
      lr.AddMemory('2 2 2 2 2=k4');      // ��������ֵ3
      lr.AddMemory('1 2 3 4 5=k5');      // ��������ֵ4
      lr.AddMemory('2 2 3 4 7=k6');      // ��������ֵ5
      lr.AddMemory('3 4 5 6 7=k7');      // ��������ֵ6
      lr.AddMemory('9 3 2 3 7=k1');      // ��������ֵ7
      lr.AddMemory('3 3 9 1 1=k3');      // ��������ֵ7

      // 10��ѵ����ȣ����ں˷�������ѵ���Ĵ���
      // �����㷨��Ϊ��������������һ�����в�ͬ�ӳ�
      lr.Train(10);

      // ����������7������ֵ����Ϊ������ֻ��k1,k2,k3,k4,k5,k6,k7�ľ��ߣ�����˳�򣬶�n����������ֵ���зֱ�����
      // ��ֵ����ֵ����ʾ��ӽ��ľ���id��������ȡ���˾���id�󣬼��ɽ�����Ӧ���ӳ�����
      // ��ͬ��ѵ�������������ͬ�ľ������ȼ�
      n := '2 2 5 4 6.5';
      // lr.process(n)���ص��ǰ��������еľ���Ȩ��
      DoStatus('(%s) %s = %s', [LearnTypes.CLearnString[lr.LearnType], n.Text, lr.process(n)]);
      DoStatus('(%s) ���ž���:%s', [LearnTypes.CLearnString[lr.LearnType], lr.ProcessMaxToken(LVec(n, lr.InLen))]);

      disposeObject(lr);
    end;

  DoStatus('NN������ʾ����');
  readln;

end.
