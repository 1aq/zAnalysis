program NNDecisionDemo;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  CoreClasses,
  PascalStrings,
  DoStatusIO,
  Learn;

var
  lr: TLearn;
  n : TPascalString;
  lt: TLearnType;

begin
  // ������ʾ������ʹ��������������ݷ���
  for lt in [ltKDT, ltKM,
    ltForest, ltLM, ltLM_MT, ltLBFGS, ltLBFGS_MT, ltLBFGS_MT_Mod, ltMonteCarlo, ltLM_Ensemble, ltLM_Ensemble_MT, ltLBFGS_Ensemble, ltLBFGS_Ensemble_MT] do
    begin
      // CreateClassifier2 �Ǵ���һ�����������֪������������ѧϰ��
      // CreateClassifier�������κ�ʱ�򣬶���һ�����������ֵ
      // ���ǻ��������½���LBFGS���о��߷���
      lr := TLearn.CreateClassifier2(lt, 5);

      // 1 1 1 1 1�������5��1��ʾ5������ά�ȣ��������˵������ֵ
      // 0��ʾ�����ţ����ߺ������Ե�
      lr.AddMemory('1 1 1 1 1=0');

      // ��������
      lr.AddMemory('1 2 1 2 1=1');

      // ��������
      lr.AddMemory('10 10 21 12 21=2');

      // 2 2 2 2 2�������5��2Ҳ��ʾ5������ά�ȣ��������˵������ֵ
      // 3��ʾ�����ţ����ߺ������Ե�
      lr.AddMemory('2 2 2 2 2=3');

      // 100��ѵ����ȣ����ں˷�������ѵ���Ĵ���
      // �����㷨��Ϊ��������������һ�����в�ͬ�ӳ�
      lr.Train(100);

      // ����������4������ֵ����Ϊ������ֻ��0,1,2,3���־��ߣ�����0123��˳�򣬶�n����������ֵ���зֱ�����
      // ��ֵ����ֵ����ʾ��ӽ��ľ���id��������ȡ���˾���id�󣬼��ɽ�����Ӧ���ӳ�����
      // ��ͬ��ѵ�������������ͬ��Ȩ��
      n := '1 2 3 4 5';
      DoStatus('(%s) %s = %s', [Learn.CLearnString[lr.LearnType], n.Text, lr.process(n)]);
      DoStatus('(%s) ���ž���ID:%d', [Learn.CLearnString[lr.LearnType], lr.processMaxIndex(LVec(n, lr.InLen))]);

      // ����������4������ֵ����Ϊ������ֻ��0,1,2,3���־��ߣ�����0123��˳�򣬶�n����������ֵ���зֱ�����
      // ��ֵ����ֵ����ʾ��ӽ��ľ���id��������ȡ���˾���id�󣬼��ɽ�����Ӧ���ӳ�����
      // ��ͬ��ѵ�������������ͬ��Ȩ��
      n := '10 10 21 12 21';
      DoStatus('(%s) %s = %s', [Learn.CLearnString[lr.LearnType], n.Text, lr.process(n)]);
      DoStatus('(%s) ���ž���ID:%d', [Learn.CLearnString[lr.LearnType], lr.processMaxIndex(LVec(n, lr.InLen))]);

      disposeObject(lr);
    end;

  DoStatus('NN������ʾ����');
  readln;

end.
