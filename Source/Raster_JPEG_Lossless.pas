{ ****************************************************************************** }
{ * memory Rasterization JPEG support                                          * }
{ * by QQ 600585@qq.com                                                        * }
{ ****************************************************************************** }
{ * https://zpascal.net                                                        * }
{ * https://github.com/PassByYou888/zAI                                        * }
{ * https://github.com/PassByYou888/ZServer4D                                  * }
{ * https://github.com/PassByYou888/PascalString                               * }
{ * https://github.com/PassByYou888/zRasterization                             * }
{ * https://github.com/PassByYou888/CoreCipher                                 * }
{ * https://github.com/PassByYou888/zSound                                     * }
{ * https://github.com/PassByYou888/zChinese                                   * }
{ * https://github.com/PassByYou888/zExpression                                * }
{ * https://github.com/PassByYou888/zGameWare                                  * }
{ * https://github.com/PassByYou888/zAnalysis                                  * }
{ * https://github.com/PassByYou888/FFMPEG-Header                              * }
{ * https://github.com/PassByYou888/zTranslate                                 * }
{ * https://github.com/PassByYou888/InfiniteIoT                                * }
{ * https://github.com/PassByYou888/FastMD5                                    * }
{ ****************************************************************************** }
unit Raster_JPEG_Lossless;

{$INCLUDE zDefine.inc}

interface

uses
  CoreClasses, PascalStrings, Raster_JPEG_type, Raster_JPEG_Marker;

type
  TLosslessAction = (laNoAction, laRotateLeft, laRotateRight, laRotate180, laFlipHor, laFlipVer);

  TLosslessOperation = class(TJPEG_Persistent)
  private
    FUpdateMetadata: boolean;
    FBuffer: array of smallint;
    FHasContrastChange: boolean;
    FContrast: double;
    FOnBeforeLossless: TUpdateEvent;
    FOnAfterLossless: TUpdateEvent;
  protected
    procedure DoBeforeLossless;
    procedure DoAfterLossless;
    function GetBlockCoder: TObject;
    function GetIntensityMapCount: integer;
    procedure InfoTranspose;
    procedure MapFlipHorz;
    procedure MapFlipVert;
    procedure MapTranspose;
    procedure MapAdjustDCCoef(AMap: TJpegBlockMap; const ABrightness: double);
    procedure MapAdjustDCandACCoef(AMap: TJpegBlockMap; const ABrightness, AContrast: double);
    procedure MapCropMcuBlocks(AMap: TJpegBlockMap; AMcuX, AMcuY, AMcuWidth, AMcuHeight: integer);
    procedure CoefFlipHorz(var Coef: TCoefBlock);
    procedure CoefFlipVert(var Coef: TCoefBlock);
    procedure CoefTranspose(var Coef: TCoefBlock);
    procedure RemoveDHTMarkers;
  public
    constructor Create(AOwner: TObject); virtual;
    procedure Clear; virtual;
    // Crop the image to the window given with ALeft/ATop/ARight/ABottom. If the
    // left/top coordinates do not fall exactly on a block boundary (multiples of
    // 8 or 16, depending on encoding), then they'll be lowered to fall on the
    // closest boundary. The coordinates are also checked for image size and
    // updated accordingly.
    procedure Crop(var ALeft, ATop, ARight, ABottom: integer);
    // Flip the image horizontally
    procedure FlipHorizontal;
    // Flip the image vertically
    procedure FlipVertical;
    // Rotate the image 90 degrees clockwise
    procedure Rotate90;
    // Rotate the image 180 degrees
    procedure Rotate180;
    // Rotate the image 270 degrees clockwise (aka 90 degrees counter-clockwise)
    procedure Rotate270;
    // Transpose the image: lowerleft corner becomes upperright corner
    procedure Transpose;
    // Touch doesn't actually change the image in any way, it just causes removal
    // of the original huffman encoding tables, so new ones (generally more optimized)
    // will be created when the image is saved.
    procedure Touch;
    // Adjust the brightness of the image. For YCbCr images only the Y component
    // is adjusted. For RGB and CMYK images, the 3 color components are each
    // adjusted. Brightness adjustment only involves the DC coefficient (addition);
    // the AC coefficients are left alone.
    procedure AdjustBrightness(ABrightness: double);
    // Adjust the brightness and contrast of the image. The brightness adjustment
    // only influences the DC coefficients. If AContrast <> 1.0, the AC coefficients
    // are also adjusted (multiplied by AContrast).
    procedure AdjustBrightnessContrast(ABrightness: double; AContrast: double);
    // Set UpdateMetadata to true to force the software to update the metadata. This
    // includes e.g. the Exif rotation flag, JFIF/EXIF width/height, and JFIF thumbnail
    // (not implemented at this moment).
    property UpdateMetadata: boolean read FUpdateMetadata write FUpdateMetadata;
    // connect to this event to process code before a lossless operation
    property OnBeforeLossless: TUpdateEvent read FOnBeforeLossless write FOnBeforeLossless;
    // connect to this event to process code after a lossless operation
    property OnAfterLossless: TUpdateEvent read FOnAfterLossless write FOnAfterLossless;
  end;

implementation

uses Raster_JPEG_Coder, Raster_JPEG_Image;

procedure TLosslessOperation.DoBeforeLossless;
begin
  if assigned(FOnBeforeLossless) then
      FOnBeforeLossless(Self);
end;

procedure TLosslessOperation.DoAfterLossless;
begin
  if assigned(FOnAfterLossless) then
      FOnAfterLossless(Self);
end;

function TLosslessOperation.GetBlockCoder: TObject;
var
  FCoder: TJpegCoder;
begin
  Result := nil;
  if not(FOwner is TJpegImage) then
      exit;
  FCoder := TJpegImage(FOwner).Coder;
  if not(FCoder is TJpegBlockCoder) or not FCoder.HasCoefficients then
    begin
      DoDebugOut(Self, wsFail, sNoDCTCoefficentsAvailable);
      exit;
    end;
  if FCoder.Scale <> jsFull then
    begin
      DoDebugOut(Self, wsFail, sOperationOnlyFor8x8);
      exit;
    end;
  Result := TJpegBlockCoder(FCoder);
end;

function TLosslessOperation.GetIntensityMapCount: integer;
var
  Space: TJpegColorSpace;
begin
  Result := 1;
  Space := TJpegImage(FOwner).DetectInternalColorSpace;
  case Space of
    jcRGB, jcRGBA, jcCMYK:
      Result := 3;
  end;
end;

procedure TLosslessOperation.InfoTranspose;
var
  i: integer;
  Info: TJpegInfo;
  Temp: integer;
begin
  // Transpose parameters contained in info
  // we cannot create a global swap func since these are properties
  Info := TJpegImage(FOwner).JpegInfo;

  // Swap width/height
  Temp := Info.FWidth;
  Info.FWidth := Info.FHeight;
  Info.FHeight := Temp;

  // Swap horz/vert sampling
  Temp := Info.FHorzSamplingMax;
  Info.FHorzSamplingMax := Info.FVertSamplingMax;
  Info.FVertSamplingMax := Temp;

  // swap mcuwidth/height
  Temp := Info.FMcuWidth;
  Info.FMcuWidth := Info.FMcuHeight;
  Info.FMcuHeight := Temp;

  // Make sure to match the restart interval (if any) to new horz mcu count
  if Info.FRestartInterval = Info.FHorzMcuCount then
      Info.FRestartInterval := Info.FVertMcuCount;
  // the "else" should not be used! Can also be 0!
  { else
    Info.RestartInterval := Info.HorzMcuCount; }

  // swap horz/vert mcu count
  Temp := Info.FHorzMcuCount;
  Info.FHorzMcuCount := Info.FVertMcuCount;
  Info.FVertMcuCount := Temp;

  // We must also transpose quantization tables, since some software writes
  // non-axisymmetric quant tables
  for i := 0 to Info.FQuantizationTables.Count - 1 do
      Info.FQuantizationTables[i].Transpose;
end;

procedure TLosslessOperation.MapFlipHorz;
var
  x, y, i: integer;
  Coder: TJpegBlockCoder;
  Info: TJpegInfo;
  Map: TJpegBlockMap;
  PCoef, PBuf, PNew: PsdCoefBlock;
begin
  Coder := TJpegBlockCoder(GetBlockCoder);
  if not assigned(Coder) then
      exit;
  Info := TJpegImage(FOwner).JpegInfo;

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;

  // Process each map
  for i := 0 to Info.FFrameCount - 1 do
    begin
      Map := Coder.Maps[i];
      if Map.TotalBlockCount <= 0 then
          continue;
      Map.ClearCoefBackup;
      SetLength(FBuffer, Map.ScanStride);
      PBuf := @FBuffer[0];
      for y := 0 to Map.VertBlockCount - 1 do
        begin
          for x := 0 to Map.HorzBlockCount - 1 do
            begin
              PCoef := Map.GetCoefPointer(x, y);
              CoefFlipHorz(PCoef^);

              // copy to the buffer, inverted
              PNew := PBuf;
              inc(PNew, Map.HorzBlockCount - x - 1);
              CopyPtr(PCoef, PNew, Map.BlockStride * SizeOf(smallint));
            end;
          // Now we copy the buffer back
          CopyPtr(PBuf, Map.GetCoefPointer(0, y), Map.ScanStride * SizeOf(smallint));
        end;
    end;
end;

procedure TLosslessOperation.MapFlipVert;
var
  y, i, j: integer;
  Coder: TJpegBlockCoder;
  Info: TJpegInfo;
  Map: TJpegBlockMap;
  PCoef, PBuf, PNew: PsdCoefBlock;
begin
  Coder := TJpegBlockCoder(GetBlockCoder);
  if not assigned(Coder) then
      exit;
  Info := TJpegImage(FOwner).JpegInfo;

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;

  // Process each map
  for i := 0 to Info.FFrameCount - 1 do
    begin
      Map := Coder.Maps[i];
      if Map.TotalBlockCount <= 0 then
          continue;
      Map.ClearCoefBackup;
      SetLength(FBuffer, Map.ScanStride);
      PBuf := @FBuffer[0];

      // First flip all the blocks vertically
      PCoef := Map.GetCoefPointer(0, 0);
      for j := 0 to Map.TotalBlockCount - 1 do
        begin
          CoefFlipVert(PCoef^);
          inc(PCoef);
        end;

      // exchange scanlines
      for y := 0 to Map.VertBlockCount div 2 - 1 do
        begin
          PCoef := Map.GetCoefPointer(0, y);
          PNew := Map.GetCoefPointer(0, Map.VertBlockCount - y - 1);
          // Coef -> Buf
          CopyPtr(PCoef, PBuf, Map.ScanStride * SizeOf(smallint));
          // New -> Coef
          CopyPtr(PNew, PCoef, Map.ScanStride * SizeOf(smallint));
          // Buf -> New
          CopyPtr(PBuf, PNew, Map.ScanStride * SizeOf(smallint));
        end;
    end;
end;

procedure TLosslessOperation.MapTranspose;
var
  x, y, i, j, Temp: integer;
  CoefCount: integer;
  Coder: TJpegBlockCoder;
  Info: TJpegInfo;
  Map: TJpegBlockMap;
  PCoef, PBuf, PNew: PsdCoefBlock;
  Frame: TFrameComponent;
begin
  Coder := TJpegBlockCoder(GetBlockCoder);
  if not assigned(Coder) then
      exit;
  Info := TJpegImage(FOwner).JpegInfo;

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;

  // Process each map
  for i := 0 to Info.FFrameCount - 1 do
    begin
      Map := Coder.Maps[i];
      Map.ClearCoefBackup;
      if Map.TotalBlockCount <= 0 then
          continue;

      CoefCount := Map.ScanStride * Map.VertBlockCount;
      SetLength(FBuffer, CoefCount);
      PBuf := @FBuffer[0];

      // First transpose all the blocks
      PCoef := Map.GetCoefPointer(0, 0);
      for j := 0 to Map.TotalBlockCount - 1 do
        begin
          CoefTranspose(PCoef^);
          inc(PCoef);
        end;

      // Copy map coefficients to buffer
      CopyPtr(Map.FirstCoef, PBuf, CoefCount * SizeOf(smallint));

      // Transpose map and its frame info
      Map.Resize(Map.VertBlockCount, Map.HorzBlockCount);
      Frame := Map.Frame;
      Temp := Frame.FHorzSampling;
      Frame.FHorzSampling := Frame.FVertSampling;
      Frame.FVertSampling := Temp;

      // copy blocks back in transposed way
      PNew := PBuf;
      for x := 0 to Map.HorzBlockCount - 1 do
        for y := 0 to Map.VertBlockCount - 1 do
          begin
            CopyPtr(PNew, Map.GetCoefPointer(x, y), 64 * SizeOf(smallint));
            inc(PNew);
          end;
    end;
end;

procedure TLosslessOperation.MapAdjustDCCoef(AMap: TJpegBlockMap; const ABrightness: double);
var
  i, Quant: integer;
  Table: TQuantizationTable;
  PSrc, PDst: PsdCoefBlock;
begin
  // Make a backup of the coefficients
  if not AMap.HasCoefBackup then
      AMap.MakeCoefBackup;

  // Quantization table
  Table := TJpegImage(FOwner).JpegInfo.FQuantizationTables[AMap.Frame.FQTable];
  Quant := Table.FQuant[0];

  // First value is DC value
  PSrc := AMap.FirstCoefBackup;
  PDst := AMap.FirstCoef;
  for i := 0 to AMap.TotalBlockCount - 1 do
    begin
      PDst^[0] := round((PSrc^[0] * Quant + ABrightness) / Quant);
      inc(PSrc);
      inc(PDst);
    end;
end;

procedure TLosslessOperation.MapAdjustDCandACCoef(AMap: TJpegBlockMap;
  const ABrightness, AContrast: double);
var
  i, j, Quant: integer;
  Table: TQuantizationTable;
  PSrc, PDst: PsdCoefBlock;
begin
  // Make a backup of the coefficients
  if not AMap.HasCoefBackup then
      AMap.MakeCoefBackup;

  // Quantization table
  Table := TJpegImage(FOwner).JpegInfo.FQuantizationTables[AMap.Frame.FQTable];
  Quant := Table.FQuant[0];

  // First value is DC value
  PSrc := AMap.FirstCoefBackup;
  PDst := AMap.FirstCoef;
  for i := 0 to AMap.TotalBlockCount - 1 do
    begin
      // Adjust DC
      PDst^[0] := round((PSrc^[0] * Quant * AContrast + ABrightness) / Quant);
      // Adjust AC
      for j := 1 to 63 do
        begin
          if PSrc^[j] = 0 then
              continue;
          PDst^[j] := round(PSrc^[j] * AContrast);
        end;
      inc(PSrc);
      inc(PDst);
    end;
end;

procedure TLosslessOperation.MapCropMcuBlocks(AMap: TJpegBlockMap;
  AMcuX, AMcuY, AMcuWidth, AMcuHeight: integer);
var
  Frame: TFrameComponent;
  x, y, W, H, row: integer;
  PSrc, PDst, PFirst: PsdCoefBlock;
begin
  Frame := AMap.Frame;
  x := AMcuX * Frame.FHorzSampling;
  y := AMcuY * Frame.FVertSampling;
  W := AMcuWidth * Frame.FHorzSampling;
  H := AMcuHeight * Frame.FVertSampling;
  PFirst := AMap.FirstCoef;

  // Copy the rows
  for row := 0 to H - 1 do
    begin
      PDst := PFirst;
      inc(PDst, row * W);
      PSrc := AMap.GetCoefPointer(x, y + row);
      CopyPtr(PSrc, PDst, W * AMap.BlockStride * SizeOf(smallint));
    end;

  // Now set the new size
  AMap.Resize(W, H);
end;

procedure TLosslessOperation.CoefFlipHorz(var Coef: TCoefBlock);
var
  i, Idx: integer;
begin
  // Invert all odd indices
  for i := 0 to 31 do
    begin
      Idx := i * 2 + 1;
      Coef[Idx] := -Coef[Idx];
    end;
end;

procedure TLosslessOperation.CoefFlipVert(var Coef: TCoefBlock);
var
  y, row, i: integer;
begin
  // invert all odd rows
  for y := 0 to 3 do
    begin
      row := (y * 2 + 1) * 8;
      for i := row to row + 7 do
          Coef[i] := -Coef[i];
    end;
end;

procedure TLosslessOperation.CoefTranspose(var Coef: TCoefBlock);
var
  x, y, i, j: integer;
  Temp: smallint;
begin
  // transpose indices
  for y := 0 to 6 do
    for x := y + 1 to 7 do
      begin
        i := x + y * 8;
        j := x * 8 + y;
        Temp := Coef[i];
        Coef[i] := Coef[j];
        Coef[j] := Temp;
      end;
end;

procedure TLosslessOperation.RemoveDHTMarkers;
var
  Info: TJpegInfo;
begin
  // When encoding later, the current Huffman tables might not be complete, so
  // we remove them so they are regenerated.
  TJpegImage(FOwner).Markers.RemoveMarkers([mkDHT]);
  Info := TJpegImage(FOwner).JpegInfo;
  Info.FDCHuffmanTables.Clear;
  Info.FACHuffmanTables.Clear;
end;

constructor TLosslessOperation.Create(AOwner: TObject);
begin
  inherited Create;
  FOwner := TJPEG_Base_Object(AOwner);
end;

procedure TLosslessOperation.Clear;
begin
  FHasContrastChange := False;
end;

procedure TLosslessOperation.Crop(var ALeft, ATop, ARight, ABottom: integer);
var
  i: integer;
  Coder: TJpegBlockCoder;
  Info: TJpegInfo;
  L, T, W, H: integer;
  Map: TJpegBlockMap;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, '"lossless" crop');
  RemoveDHTMarkers;
  Coder := TJpegBlockCoder(GetBlockCoder);

  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;
  Info := TJpegImage(FOwner).JpegInfo;
  DoDebugOut(Self, wsInfo, PFormat('orig image WxH = [%d,%d]', [Info.FWidth, Info.FHeight]));
  DoDebugOut(Self, wsInfo, PFormat('crop to LTRB = [%d,%d,%d,%d]', [ALeft, ATop, ARight, ABottom]));
  if ALeft < 0 then
      ALeft := 0;
  if ATop < 0 then
      ATop := 0;
  if ARight > Info.FWidth then
      ARight := Info.FWidth;
  if ABottom > Info.FHeight then
      ABottom := Info.FHeight;
  L := (ALeft div Info.FMcuWidth);
  T := (ATop div Info.FMcuHeight);
  ALeft := L * Info.FMcuWidth;
  ATop := T * Info.FMcuHeight;

  // Determine number of mcu blocks to copy
  W := (ARight - ALeft + Info.FMcuWidth - 1) div Info.FMcuWidth;
  H := (ABottom - ATop + Info.FMcuHeight - 1) div Info.FMcuHeight;
  if (W <= 0) or (H <= 0) then
      exit;

  // Update Info
  DoDebugOut(Self, wsInfo, PFormat('MCU blocks WxH=[%d,%d]', [W, H]));
  Info.FHorzMcuCount := W;
  Info.FVertMcuCount := H;
  Info.FWidth := ARight - ALeft;
  Info.FHeight := ABottom - ATop;
  DoDebugOut(Self, wsInfo, PFormat('updated image WxH = [%d,%d]', [Info.FWidth, Info.FHeight]));

  // Crop each map
  for i := 0 to Info.FFrameCount - 1 do
    begin
      Map := Coder.Maps[i];
      if not assigned(Map) then
          continue;
      MapCropMcuBlocks(Map, L, T, W, H);
    end;
  DoAfterLossless;
end;

procedure TLosslessOperation.FlipHorizontal;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'flip horizontal');
  RemoveDHTMarkers;
  MapFlipHorz;
  DoAfterLossless;
end;

procedure TLosslessOperation.FlipVertical;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'flip vertical');
  RemoveDHTMarkers;
  MapFlipVert;
  DoAfterLossless;
end;

procedure TLosslessOperation.Rotate90;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'lossless rotate 90deg');
  RemoveDHTMarkers;
  InfoTranspose;
  MapTranspose;
  MapFlipHorz;
  DoAfterLossless;
end;

procedure TLosslessOperation.Rotate180;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'lossless rotate 180deg');
  RemoveDHTMarkers;
  MapFlipHorz;
  MapFlipVert;
  DoAfterLossless;
end;

procedure TLosslessOperation.Rotate270;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'lossless rotate 270deg');
  RemoveDHTMarkers;
  InfoTranspose;
  MapTranspose;
  MapFlipVert;
  DoAfterLossless;
end;

procedure TLosslessOperation.Transpose;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'lossless transpose');
  RemoveDHTMarkers;
  // Transpose parameters contained in info
  InfoTranspose;
  // Transpose maps
  MapTranspose;
  DoAfterLossless;
end;

procedure TLosslessOperation.Touch;
begin
  DoBeforeLossless;
  DoDebugOut(Self, wsInfo, 'lossless touch');
  RemoveDHTMarkers;
  DoAfterLossless;
end;

{ TLosslessOperation }

procedure TLosslessOperation.AdjustBrightness(ABrightness: double);
var
  i, MapCount: integer;
  Coder: TJpegBlockCoder;
  Map: TJpegBlockMap;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  if FHasContrastChange then
    begin
      AdjustBrightnessContrast(ABrightness, FContrast);
      exit;
    end;
  MapCount := GetIntensityMapCount;
  Coder := TJpegBlockCoder(GetBlockCoder);
  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;
  // Multiply the brightness adjustment by 8 (since the coefficient for DC is
  // a factor 8 too high)
  ABrightness := ABrightness * 8;
  for i := 0 to MapCount - 1 do
    begin
      Map := Coder.Maps[i];
      if Map.TotalBlockCount <= 0 then
          continue;
      MapAdjustDCCoef(Map, ABrightness);
    end;
  DoAfterLossless;
end;

procedure TLosslessOperation.AdjustBrightnessContrast(ABrightness, AContrast: double);
var
  i, MapCount: integer;
  Coder: TJpegBlockCoder;
  Map: TJpegBlockMap;
begin
  DoBeforeLossless;
  RemoveDHTMarkers;
  FHasContrastChange := True;
  FContrast := AContrast;
  MapCount := GetIntensityMapCount;
  Coder := TJpegBlockCoder(GetBlockCoder);
  // Indicate that the samples are no longer valid (requires a new IDCT to get them)
  Coder.HasSamples := False;
  // Multiply the brightness adjustment by 8 (since the coefficient for DC is
  // a factor 8 too high)
  ABrightness := ABrightness * 8;
  for i := 0 to MapCount - 1 do
    begin
      Map := Coder.Maps[i];
      if Map.TotalBlockCount <= 0 then
          continue;
      MapAdjustDCandACCoef(Map, ABrightness, AContrast);
    end;
  DoAfterLossless;
end;

end.
