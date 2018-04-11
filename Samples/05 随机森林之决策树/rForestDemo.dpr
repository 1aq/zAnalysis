program rForestDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, CoreClasses, DoStatusIO, UnicodeMixedLib, Learn;

// ����������ģ����Ӧ��ʱ�������������
procedure runF(id: TLearnFloat);
begin
  case Round(id) of
    1: dostatus('%f hey', [id]);
    2: dostatus('%f im robot', [id]);
    3: dostatus('%f nice to meet you', [id]);
    4: dostatus('%f haha', [id]);
    5: dostatus('%f lol', [id]);
    6: dostatus('%f hello world', [id]);
    7: dostatus('%f byebye', [id]);
    else raiseInfo('%f no memory', [id]);
  end;
end;

var
  lr: TLearn;
  i : Integer;
begin
  System.ReportMemoryLeaksOnShutdown := True;

  // ���ɭ�־���ģ��
  // ���ɭ�־���ģ���ڹ���ʱ��Ҫ�߼����߻ع飬OutIn����1���߸�����ֵ��OutLenֻ����1
  lr := TLearn.Create(TLearnType.ltForest, 2, 1);
  lr.AddMemory('0,0 = 1');
  lr.AddMemory('1,1 = 2');
  lr.AddMemory('1,0 = 3');
  lr.AddMemory('0,1 = 4');
  lr.AddMemory('4,5 = 5');
  lr.AddMemory('3,5 = 6');
  lr.AddMemory('5,3 = 7');

  lr.Train;

  // �����������Ѿ�ѧϰ�������ݣ����Ǵ�ӡ������֤
  runF(lr.processRF([0, 0]));
  runF(lr.processRF([1, 1]));
  runF(lr.processRF([1, 0]));
  runF(lr.processRF([0, 1]));
  runF(lr.processRF([4, 5]));
  runF(lr.processRF([3, 5]));
  runF(lr.processRF([5, 3]));

  // ���ֵ ����ѧϰ
  // ���ɭ�־���ģ�ͻ��ϸ�Ĵ��Ѿ�ѧϰ����Outֵ��ȥѰ�Һ�������ѷ�������
  // ���ɭ�������ڸ��ӵ������������
  DoStatus('************************************************');
  for i := 1 to 10 do
    begin
      runF(lr.processRF([umlRandomRange(-100, 100), umlRandomRange(-100, 100)]));
      TCoreClassThread.Sleep(100);
    end;

  disposeObject(lr);
  readln;
end.
