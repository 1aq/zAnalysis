unit ColorSegmentationMainFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, System.IOUtils,

  CoreClasses, UnicodeMixedLib, PascalStrings, Geometry2DUnit, MemoryRaster,
  zDrawEngine, zDrawEngineInterface_SlowFMX, FMX.Controls.Presentation;

type
  TColorSegmentationMainForm = class(TForm)
    segListPB: TPaintBox;
    segPB: TPaintBox;
    Timer1: TTimer;
    Splitter1: TSplitter;
    openButton: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure openButtonClick(Sender: TObject);
    procedure segListPBPaint(Sender: TObject; Canvas: TCanvas);
    procedure segPBMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure segPBPaint(Sender: TObject; Canvas: TCanvas);
    procedure Timer1Timer(Sender: TObject);
  private
    drawIntf: TDrawEngineInterface_FMX;
  public
    tex: TMemoryRaster;
    tex_box: TRectV2;
    colors: TRColors;
    pickColor: TRColor;
    SegImgList: TMemoryRasterList;
    LastSegBox: TArrayRectV2;

    // ����ֵ�ü������ɫ
    function RemoveColor(c: TRColor): Boolean;

    // ������ķָ�������ɫ����ID
    procedure DoSegColor(Color: TRColor; var Classify: TSegClassify);

    // �����ָ�
    procedure BuildSeg;
  end;

var
  ColorSegmentationMainForm: TColorSegmentationMainForm;
  color_threshold: TGeoFloat = 0.1;

implementation

{$R *.fmx}


procedure TColorSegmentationMainForm.FormCreate(Sender: TObject);
begin
  drawIntf := TDrawEngineInterface_FMX.Create;
  tex := NewRasterFromFile(umlCombineFileName(TPath.GetLibraryPath, 'ColorSeg1.bmp'));
  colors := AnalysisColors(tex, nil, 65535);
  SegImgList := TMemoryRasterList.Create;
  SetLength(LastSegBox, 0);

  TComputeThread.RunP(nil, nil, procedure(Sender: TComputeThread)
    var
      i: Integer;
    begin
      DrawPool(segPB).PostScrollText(15, Format('���� |s:12,color(1,0,0)|%d||����ɫ ���ھ�ֵ������...', [colors.count]),
        16, DEColor(0.5, 1.0, 0.5));
      while i < colors.count do
        begin
          if RemoveColor(colors[i]) then
              i := 0
          else
              inc(i);
        end;
      RemoveColor(RColor(0, 0, 0));
      colors.Remove(RColor(0, 0, 0));
      DrawPool(segPB).PostScrollText(15, Format('��ֵ���Ժ�ʣ�� |s:12,color(1,0,0)|%d||����ɫ...', [colors.count]),
        16, DEColor(0.5, 1.0, 0.5));
    end);
end;

procedure TColorSegmentationMainForm.segListPBPaint(Sender: TObject; Canvas: TCanvas);
var
  d: TDrawEngine;
  r: TRectV2;
begin
  drawIntf.SetSurface(Canvas, Sender);
  d := DrawPool(Sender, drawIntf);
  d.ViewOptions := [voEdge];

  d.FillBox(d.ScreenRect, DEColor(0.2, 0.2, 0.2));

  LockObject(SegImgList);
  d.BeginCaptureShadow(Vec2(-5, 5), 0.9);
  r := d.DrawPicturePackingInScene(SegImgList, 10, Vec2(0, 0), 1.0);
  d.EndCaptureShadow;
  UnLockObject(SegImgList);

  d.DrawText('���طָ��', 16, d.ScreenRect, DEColor(0.5, 1.0, 0.5), False);
  d.Flush;
end;

procedure TColorSegmentationMainForm.segPBMouseUp(Sender: TObject; Button:
  TMouseButton; Shift: TShiftState; X, Y: Single);
var
  pt: TVec2;
  i: Integer;
  c: TRColorEntry;
begin
  LockObject(SegImgList);
  for i := 0 to SegImgList.count - 1 do
      DisposeObject(SegImgList[i]);
  SegImgList.Clear;
  UnLockObject(SegImgList);

  pt := RectProjection(tex_box, tex.BoundsRectV2, Vec2(X, Y));
  if PointInRect(pt, tex.BoundsRectV2) then
    begin
      pickColor := tex.PixelVec[pt];

      if RColorDistance(pickColor, RColor(0, 0, 0)) < color_threshold then
        begin
          DrawPool(segPB).PostScrollText(5, '����ʰȡ��ɫ', 24, DEColor(1, 0, 0));
          exit;
        end;

      c.BGRA := pickColor;

      DrawPool(segPB).PostScrollText(5, Format('���ڷָ���ɫ|color(%d,%d,%d)|(%d,%d,%d)||' + #13#10, [c.r, c.G, c.B, c.r, c.G, c.B]),
        24, DEColor(1.0, 1.0, 1.0));

      BuildSeg;
    end;
end;

procedure TColorSegmentationMainForm.segPBPaint(Sender: TObject; Canvas: TCanvas);
var
  d: TDrawEngine;
  n: U_String;
  i: Integer;
  c: TRColorEntry;
begin
  drawIntf.SetSurface(Canvas, Sender);
  d := DrawPool(Sender, drawIntf);
  d.ViewOptions := [voEdge];

  d.FillBox(d.ScreenRect, DEColor(0.5, 0.5, 0.5));

  tex_box := d.FitDrawPicture(tex, tex.BoundsRectV2, RectEdge(d.ScreenRect, -20), 1.0);

  for i := 0 to length(LastSegBox) - 1 do
      d.DrawBox(RectTransformToDest(tex.BoundsRectV2, tex_box, LastSegBox[i]), DEColor(1, 0.5, 0.5, 1), 2);

  d.DrawDotLineBox(tex_box, Vec2(0.5, 0.5), 0, DEColor(0.8, 0.1, 0.4), 3);

  n := '';
  LockObject(colors);
  for i := 0 to colors.count - 1 do
    begin
      c.BGRA := colors[i];
      n.Append(Format('||�²��� |color(%d,%d,%d)|(%d,%d,%d)||' + #13#10, [c.r, c.G, c.B, c.r, c.G, c.B]));
    end;
  d.DrawText('|s:16|ѡ��һ����ɫ' + #13#10 + n, 12, d.ScreenRect, DEColor(0.5, 1.0, 0.5), False);
  UnLockObject(colors);

  d.Flush;
end;

procedure TColorSegmentationMainForm.Timer1Timer(Sender: TObject);
begin
  EnginePool.Progress(Interval2Delta(Timer1.Interval));
  Invalidate;
end;

function TColorSegmentationMainForm.RemoveColor(c: TRColor): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := 0;
  LockObject(colors);
  while i < colors.count do
    begin
      // ����ֵ�ü������ɫ
      if (colors[i] <> c) and (RColorDistance(c, colors[i]) < color_threshold) then
        begin
          colors.Delete(i);
          Result := True;
        end
      else
          inc(i);
    end;
  UnLockObject(colors);
end;

procedure TColorSegmentationMainForm.DoSegColor(Color: TRColor; var Classify: TSegClassify);
var
  i: Integer;
begin
  // ������ķָ�������ɫ����ID
  // Classify�� 0 ��ʾ�����ɫ���طָ�������0�Ļ����ָ����ᰴClassify���з���
  Classify := 0;
  if RColorDistance(Color, RColor(0, 0, 0)) < color_threshold then
      exit;

  // ���ʰȡ����ɫ��Χ����ֵcolor_threshold�ھ͸��߷ָ��������� Classify ��1����
  if RColorDistance(pickColor, Color) < color_threshold then
      Classify := 1;
end;

procedure TColorSegmentationMainForm.BuildSeg;
begin
  TComputeThread.RunP(nil, nil, procedure(ThSender: TComputeThread)
    var
      s: TColorSegmentation;
      first_total, i, j, k: Integer;
      sp: TSegPool;
      nm: TMemoryRaster;
    begin
      s := TColorSegmentation.Create(tex);

      // �ָ�������ɫ����ӿ�
      s.OnSegColor := DoSegColor;

      // ִ�зָ�
      s.BuildSegmentation;

      // ��¼һ���״ηָ�����
      first_total := s.count;

      // �����ָ��Ժ������������������ǽ������Ƴ�
      // ��ֵ100��ʾ�ָ���Ƭ�������ܺ��������100��
      s.RemoveNoise(100);

      SetLength(LastSegBox, s.count);

      for i := 0 to s.count - 1 do
        begin
          sp := s[i];
          LastSegBox[i] := sp.BoundsRectV2(True);
          // BuildDatamap�����Ὣ�ָ�����ͶӰ��һ���¹�դ��
          nm := sp.BuildClipDatamap(RColor(0, 0, 0, 0), pickColor);
          // ����ʾ�ķָ����ϸ��ָ�ͼ�λ��ϱ߿�
          // nm.FillNoneBGColorBorder(RColor(0, 0, 0, 0), RColorInv(pickColor), 4);

          LockObject(SegImgList);
          SegImgList.Add(nm);
          UnLockObject(SegImgList);
        end;

      DrawPool(segPB).PostScrollText(5,
        Format('�ָ��:��⵽ |s:16,color(1,0,0)|%d|| ������ͼ��(����������Ƭͼ��),��ʵ����Чֻ�� |s:16,color(1,0,0)|%d|| ��ͼ��', [first_total, SegImgList.count]),
        20, DEColor(1, 1, 1));
      DisposeObject(s);
    end);
end;

procedure TColorSegmentationMainForm.openButtonClick(Sender: TObject);
var
  i: Integer;
begin
  OpenDialog1.Filter := TBitmapCodecManager.GetFilterString;
  if not OpenDialog1.Execute then
      exit;

  DisposeObject(tex);
  tex := NewRasterFromFile(OpenDialog1.FileName);
  colors := AnalysisColors(tex, nil, 65535);
  SetLength(LastSegBox, 0);

  DrawPool(segPB).PostScrollText(15, Format('���� |s:12,color(1,0,0)|%d||����ɫ ���ھ�ֵ������...', [colors.count]),
    16, DEColor(0.5, 1.0, 0.5));
  while i < colors.count do
    begin
      if RemoveColor(colors[i]) then
          i := 0
      else
          inc(i);
    end;
  RemoveColor(RColor(0, 0, 0));
  colors.Remove(RColor(0, 0, 0));
  DrawPool(segPB).PostScrollText(15, Format('��ֵ���Ժ�ʣ�� |s:12,color(1,0,0)|%d||����ɫ...', [colors.count]),
    16, DEColor(0.5, 1.0, 0.5));
end;

end.
