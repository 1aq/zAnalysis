unit NNPicutreCompareFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.TabControl, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.Layouts, FMX.ListBox, FMX.Objects, FMX.StdCtrls,

  FMX.Surfaces,

  CoreClasses, DoStatusIO, MemoryRaster, PascalStrings, ObjectDataManager, ItemStream,
  zDrawEngineInterface_SlowFMX,
  Learn, LearnTypes;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    GlobalLayout: TLayout;
    ListBox1: TListBox;
    Image1: TImage;
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Splitter1: TSplitter;
    Button5: TButton;
    Button6: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshGRLib;
    procedure DoListItemClick(Sender: TObject);
  public
    { Public declarations }
    pack  : TObjectDataManagerOfCache;
    mrList: TCoreClassListForObj;
    lr    : TLearn;
    procedure DoStatusM(AText: SystemString; const ID: Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  m: TLMatrix;
  t: TTimeTick;
begin
  if lr <> nil then
      DisposeObject(lr);

  t := GetTimeTick;
  lr := TLearn.CreateClassifier(ltKDT, 100);
  DoStatus('�������� %d * %d ��������...', [Trunc(Sqrt(lr.InLen)), Trunc(Sqrt(lr.InLen))]);
  for i := 0 to mrList.Count - 1 do
    begin
      m := Learn.LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[i]));
      lr.AddMatrix(m, [i]);
    end;
  DoStatus('���������������...��ʱ%dms', [GetTimeTick - t]);

  GlobalLayout.Enabled := False;
  DoStatus('����ʹ�� %s ѵ��������...', [LearnTypes.CLearnString[lr.LearnType]]);

  // ���ѵ��ʱ�뽫1�Ĵ󣬱���50
  // ���ʹ����"ltLBFGS_MT, ltLM_MT"��Щ���з�ʽѵ��������ֵ���+nά�ȵ����飬����˲��Ե�16G�����ڴ棬��������£���һ����ֻ��������룬���������������
  // Ϊ��֤Demo��˳�����У�����������ʹ�õ���ѵ����ֻ���ĺ�С�ڴ�

  t := GetTimeTick;
  lr.TrainP(1,
    procedure(const LSender: TLearn; const state: Boolean)
    begin
      if state then
          DoStatus('������ѵ�����...��ʱ%dms', [GetTimeTick - t])
      else
          DoStatus('������ѵ��ʧ��!!!');
      DoStatus(lr.Info);
      GlobalLayout.Enabled := True;
    end);
end;

procedure TForm1.DoStatusM(AText: SystemString; const ID: Integer);
begin
  Memo1.Lines.Add(AText);
  Memo1.GoToTextEnd;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  rs       : TResourceStream;
  sr       : TItemSearch;
  mr       : TMemoryRaster;
  itmStream: TItemStream;
begin
  AddDoStatusHook(Self, DoStatusM);

  rs := TResourceStream.Create(hInstance, 'pngPack', RT_RCDATA);
  pack := TObjectDataManagerOfCache.CreateAsStream(rs, '', ObjectDataMarshal.ID, True, False, True);
  mrList := TCoreClassListForObj.Create;

  if pack.ItemFindFirst('/', '*.png', sr) then
    begin
      repeat
        itmStream := TItemStream.Create(pack, sr.HeaderPOS);
        mr := TMemoryRaster.Create;
        LoadMemoryBitmap(itmStream, mr);
        mrList.Add(mr);
        DisposeObject(itmStream);
      until not pack.ItemFindNext(sr);
    end;

  lr := nil;

  RefreshGRLib;

  Button1Click(Button1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  DeleteDoStatusHook(Self);
  for i := 0 to mrList.Count - 1 do
      DisposeObject(mrList[i]);
  DisposeObject(mrList);
  DisposeObject(pack);
  if lr <> nil then
      DisposeObject(lr);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
  m: TLMatrix;
  t: TTimeTick;
begin
  if lr <> nil then
      DisposeObject(lr);

  t := GetTimeTick;
  lr := TLearn.CreateClassifier(ltLBFGS, 100);
  DoStatus('�������� %d * %d ��������...', [Trunc(Sqrt(lr.InLen)), Trunc(Sqrt(lr.InLen))]);
  for i := 0 to mrList.Count - 1 do
    begin
      m := Learn.LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[i]));
      lr.AddMatrix(m, [i]);
    end;
  DoStatus('���������������...��ʱ%dms', [GetTimeTick - t]);

  GlobalLayout.Enabled := False;
  DoStatus('����ʹ�� %s ѵ��������...', [LearnTypes.CLearnString[lr.LearnType]]);

  // ���ѵ��ʱ�뽫1�Ĵ󣬱���50
  // ���ʹ����"ltLBFGS_MT, ltLM_MT"��Щ���з�ʽѵ��������ֵ���+nά�ȵ����飬����˲��Ե�16G�����ڴ棬��������£���һ����ֻ��������룬���������������
  // Ϊ��֤Demo��˳�����У�����������ʹ�õ���ѵ����ֻ���ĺ�С�ڴ�

  t := GetTimeTick;
  lr.TrainP(10,
    procedure(const LSender: TLearn; const state: Boolean)
    begin
      if state then
          DoStatus('������ѵ�����...��ʱ%dms', [GetTimeTick - t])
      else
          DoStatus('������ѵ��ʧ��!!!');
      DoStatus(lr.Info);
      GlobalLayout.Enabled := True;
    end);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i: Integer;
  m: TLMatrix;
  t: TTimeTick;
begin
  if lr <> nil then
      DisposeObject(lr);

  t := GetTimeTick;
  lr := TLearn.CreateClassifier(ltLM, 100);
  DoStatus('�������� %d * %d ��������...', [Trunc(Sqrt(lr.InLen)), Trunc(Sqrt(lr.InLen))]);
  for i := 0 to mrList.Count - 1 do
    begin
      m := Learn.LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[i]));
      lr.AddMatrix(m, [i]);
    end;
  DoStatus('���������������...��ʱ%dms', [GetTimeTick - t]);

  GlobalLayout.Enabled := False;
  DoStatus('����ʹ�� %s ѵ��������...', [LearnTypes.CLearnString[lr.LearnType]]);

  // ���ѵ��ʱ�뽫1�Ĵ󣬱���50
  // ���ʹ����"ltLBFGS_MT, ltLM_MT"��Щ���з�ʽѵ��������ֵ���+nά�ȵ����飬����˲��Ե�16G�����ڴ棬��������£���һ����ֻ��������룬���������������
  // Ϊ��֤Demo��˳�����У�����������ʹ�õ���ѵ����ֻ���ĺ�С�ڴ�

  t := GetTimeTick;

  lr.TrainP(1,
    procedure(const LSender: TLearn; const state: Boolean)
    begin
      if state then
          DoStatus('������ѵ�����...��ʱ%dms', [GetTimeTick - t])
      else
          DoStatus('������ѵ��ʧ��!!!');
      DoStatus(lr.Info);
      GlobalLayout.Enabled := True;
    end);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i: Integer;
  m: TLMatrix;
  t: TTimeTick;
begin
  if lr <> nil then
      DisposeObject(lr);

  t := GetTimeTick;
  lr := TLearn.CreateClassifier(ltForest, 100);
  DoStatus('�������� %d * %d ��������...', [Trunc(Sqrt(lr.InLen)), Trunc(Sqrt(lr.InLen))]);
  for i := 0 to mrList.Count - 1 do
    begin
      m := Learn.LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[i]));
      lr.AddMatrix(m, [i]);
    end;
  DoStatus('���������������...��ʱ%dms', [GetTimeTick - t]);

  GlobalLayout.Enabled := False;
  DoStatus('����ʹ�� %s ѵ��������...', [LearnTypes.CLearnString[lr.LearnType]]);

  // ���ѵ��ʱ�뽫1�Ĵ󣬱���50
  // ���ʹ����"ltLBFGS_MT, ltLM_MT"��Щ���з�ʽѵ��������ֵ���+nά�ȵ����飬����˲��Ե�16G�����ڴ棬��������£���һ����ֻ��������룬���������������
  // Ϊ��֤Demo��˳�����У�����������ʹ�õ���ѵ����ֻ���ĺ�С�ڴ�

  t := GetTimeTick;

  lr.TrainP(1,
    procedure(const LSender: TLearn; const state: Boolean)
    begin
      if state then
          DoStatus('������ѵ�����...��ʱ%dms', [GetTimeTick - t])
      else
          DoStatus('������ѵ��ʧ��!!!');
      DoStatus(lr.Info);
      GlobalLayout.Enabled := True;
    end);
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i: Integer;
  m: TLMatrix;
  t: TTimeTick;
begin
  if lr <> nil then
      DisposeObject(lr);

  t := GetTimeTick;
  lr := TLearn.CreateClassifier(ltLBFGS_Ensemble, 100);
  DoStatus('�������� %d * %d ��������...', [Trunc(Sqrt(lr.InLen)), Trunc(Sqrt(lr.InLen))]);
  for i := 0 to mrList.Count - 1 do
    begin
      m := Learn.LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[i]));
      lr.AddMatrix(m, [i]);
    end;
  DoStatus('���������������...��ʱ%dms', [GetTimeTick - t]);

  GlobalLayout.Enabled := False;
  DoStatus('����ʹ�� %s ѵ��������...', [LearnTypes.CLearnString[lr.LearnType]]);

  // ���ѵ��ʱ�뽫1�Ĵ󣬱���50
  // ���ʹ����"ltLBFGS_MT, ltLM_MT"��Щ���з�ʽѵ��������ֵ���+nά�ȵ����飬����˲��Ե�16G�����ڴ棬��������£���һ����ֻ��������룬���������������
  // Ϊ��֤Demo��˳�����У�����������ʹ�õ���ѵ����ֻ���ĺ�С�ڴ�

  t := GetTimeTick;
  lr.TrainP(1,
    procedure(const LSender: TLearn; const state: Boolean)
    begin
      if state then
          DoStatus('������ѵ�����...��ʱ%dms', [GetTimeTick - t])
      else
          DoStatus('������ѵ��ʧ��!!!');
      DoStatus(lr.Info);
      GlobalLayout.Enabled := True;
    end);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  i: Integer;
  m: TLMatrix;
  t: TTimeTick;
begin
  if lr <> nil then
      DisposeObject(lr);

  t := GetTimeTick;
  lr := TLearn.CreateClassifier(ltLM_Ensemble, 100);
  DoStatus('�������� %d * %d ��������...', [Trunc(Sqrt(lr.InLen)), Trunc(Sqrt(lr.InLen))]);
  for i := 0 to mrList.Count - 1 do
    begin
      m := Learn.LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[i]));
      lr.AddMatrix(m, [i]);
    end;
  DoStatus('���������������...��ʱ%dms', [GetTimeTick - t]);

  GlobalLayout.Enabled := False;
  DoStatus('����ʹ�� %s ѵ��������...', [LearnTypes.CLearnString[lr.LearnType]]);

  // ���ѵ��ʱ�뽫1�Ĵ󣬱���50
  // ���ʹ����"ltLBFGS_MT, ltLM_MT"��Щ���з�ʽѵ��������ֵ���+nά�ȵ����飬����˲��Ե�16G�����ڴ棬��������£���һ����ֻ��������룬���������������
  // Ϊ��֤Demo��˳�����У�����������ʹ�õ���ѵ����ֻ���ĺ�С�ڴ�

  t := GetTimeTick;
  lr.TrainP(1,
    procedure(const LSender: TLearn; const state: Boolean)
    begin
      if state then
          DoStatus('������ѵ�����...��ʱ%dms', [GetTimeTick - t])
      else
          DoStatus('������ѵ��ʧ��!!!');
      DoStatus(lr.Info);
      GlobalLayout.Enabled := True;
    end);
end;

procedure TForm1.DoListItemClick(Sender: TObject);
var
  m         : TLMatrix;
  fin, fout : TLVec;
  fMax, fMin: TLFloat;
  i         : Integer;
  pb        : TProgressBar;
begin
  if lr = nil then
      exit;

  m := LMatrixSampler(True, Trunc(Sqrt(lr.InLen)), TMemoryRaster(mrList[TListboxItem(Sender).Index]));
  fin := LVec(m, lr.InLen);
  if lr.process(@fin, @fout) then
    begin
      DoStatus('��ӽ���ͼƬ������%d', [LMaxVecIndex(fout)]);
      MemoryBitmapToBitmap(TMemoryRaster(mrList[LMaxVecIndex(fout)]), Image1.Bitmap);

      // ����һ������
      fMax := LMaxVec(fout);
      fMin := LMinVec(fout);
      for i := 0 to length(fout) - 1 do
        begin
          pb := TProgressBar(ListBox1.ListItems[i].TagObject);
          pb.Max := fMax;
          pb.Min := fMin;
          pb.Value := fout[i];
        end;
    end;
end;

procedure TForm1.RefreshGRLib;
var
  litm: TListboxItem;
  img : TImage;
  pb  : TProgressBar;
  i   : Integer;
begin
  ListBox1.Clear;

  ListBox1.BeginUpdate;
  for i := 0 to mrList.Count - 1 do
    begin
      litm := TListboxItem.Create(ListBox1);
      litm.Parent := ListBox1;
      litm.Height := ListBox1.Width / 3.0 - 6;
      litm.Margins.Rect := Rectf(1, 1, 1, 1);
      litm.OnClick := DoListItemClick;

      img := TImage.Create(litm);
      img.Parent := litm;
      img.Align := TAlignLayout.Client;
      img.HitTest := False;
      MemoryBitmapToBitmap(TMemoryRaster(mrList[i]), img.Bitmap);

      pb := TProgressBar.Create(img);
      pb.Parent := img;
      pb.Align := TAlignLayout.Client;
      pb.HitTest := False;
      pb.Opacity := 0.5;
      pb.Margins.Rect := Rectf(2, 2, 2, 2);
      pb.Max := 1;
      pb.Min := 0;
      pb.Value := 0;

      litm.TagObject := pb;
    end;
  ListBox1.EndUpdate;
end;

end.
