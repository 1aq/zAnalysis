program rForestDemo;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils, CoreClasses, DoStatusIO, UnicodeMixedLib, Learn, LearnTypes;

// ����������ģ����Ӧ��ʱ�������������

function runF(id: TLFloat; const Print: Boolean = True): string;
begin
  case Round(id) of
    1: Result := Format('%f hey', [id]);
    2: Result := Format('%f im robot', [id]);
    3: Result := Format('%f nice to meet you', [id]);
    4: Result := Format('%f haha', [id]);
    5: Result := Format('%f lol', [id]);
    6: Result := Format('%f hello world', [id]);
    7: Result := Format('%f byebye', [id]);
    else Result := 'unknow';
  end;
  if Print then
      DoStatus(Result);
end;

var
  lr: TLearn;
  i: Integer;

begin
  System.ReportMemoryLeaksOnShutdown := True;

  // ���ɭ�־���ģ��
  // ���ɭ�־���ģ���ڹ���ʱ��Ҫ�߼����߻ع飬OutIn����1���߸�����ֵ��OutLenֻ����1
  lr := TLearn.CreateRegression2(TLearnType.ltForest, 2, 1);
  lr.AddMemory('0,0 = 1');
  lr.AddMemory('1,1 = 2');
  lr.AddMemory('1,0 = 3');
  lr.AddMemory('0,1 = 4');
  lr.AddMemory('4,5 = 5');
  lr.AddMemory('3,5 = 6');
  lr.AddMemory('5,3 = 7');

  lr.Train;

  // �����������Ѿ�ѧϰ�������ݣ����Ǵ�ӡ������֤
  runF(lr.processFV([0, 0]));
  runF(lr.processFV([1, 1]));
  runF(lr.processFV([1, 0]));
  runF(lr.processFV([0, 1]));
  runF(lr.processFV([4, 5]));
  runF(lr.processFV([3, 5]));
  runF(lr.processFV([5, 3]));

  // ���ֵ ����ѧϰ
  // ���ɭ�־���ģ�ͻ��ϸ�Ĵ��Ѿ�ѧϰ����Outֵ��ȥѰ�Һ�������ѷ�������
  // ���ɭ�������ڸ��ӵ������������
  DoStatus('************************************************');
  for i := 1 to 10 do
      runF(lr.processFV([umlRandomRange(-100, 100), umlRandomRange(-100, 100)]));

  disposeObject(lr);



  // ��ǩʽ����

  // ���ɭ�־���ģ��
  // ���ɭ�־���ģ���ڹ���ʱ��Ҫ�߼����߻ع飬OutIn����1���߸�����ֵ��OutLenֻ����1
  lr := TLearn.CreateRegression2(TLearnType.ltForest, 2, 1);
  lr.AddMemory('0,0 = ' + runF(1, False));
  lr.AddMemory('1,1 = ' + runF(2, False));
  lr.AddMemory('1,0 = ' + runF(3, False));
  lr.AddMemory('0,1 = ' + runF(4, False));
  lr.AddMemory('4,5 = ' + runF(5, False));
  lr.AddMemory('3,5 = ' + runF(6, False));
  lr.AddMemory('5,3 = ' + runF(7, False));

  lr.Train;

  DoStatus(lr.SearchToken([lr.processFV([0, 0])]));

  disposeObject(lr);
  readln;

end.
