{ ****************************************************************************** }
{ * machine Learn types    writen by QQ 600585@qq.com                          * }
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
unit LearnTypes;

{$INCLUDE zDefine.inc}

interface

uses CoreClasses, PascalStrings, UnicodeMixedLib, KDTree, KM, DoStatusIO;

type
  TLFloat = TKDTree_VecType;
  PLFloat = PKDTree_VecType;
  TLVec = TKDTree_Vec;
  PLVec = PKDTree_Vec;
  TLMatrix = TKDTree_DynamicVecBuffer;
  PLMatrix = PKDTree_DynamicVecBuffer;

  TLInt = TKMInt;
  PLInt = PKMInt;
  TLIVec = TKMIntegerArray;
  PLIVec = PKMIntegerArray;
  TLIMatrix = array of TLIVec;
  PLIMatrix = ^TLIMatrix;

  TLBVec = array of Boolean;
  PLBVec = ^TLBVec;
  TLBMatrix = array of TLBVec;
  PLBMatrix = ^TLBMatrix;

  TLComplex = record
    x, y: TLFloat;
  end;

  TLComplexVec = array of TLComplex;
  TLComplexMatrix = array of TLComplexVec;

  TLearnType = (
    ltKDT,              // KDTree, fast space operation, this not Neurons network
    ltKM,               // k-means++ clusterization, this not Neurons network
    ltForest,           // random decision forest
    ltLogit,            // Logistic regression
    ltLM,               // Levenberg-Marquardt
    ltLM_MT,            // Levenberg-Marquardt with Parallel
    ltLBFGS,            // L-BFGS
    ltLBFGS_MT,         // L-BFGS with Parallel
    ltLBFGS_MT_Mod,     // L-BFGS with Parallel and optimization
    ltMonteCarlo,       // fast Monte Carlo train
    ltLM_Ensemble,      // Levenberg-Marquardt Ensemble
    ltLM_Ensemble_MT,   // Levenberg-Marquardt Ensemble with Parallel
    ltLBFGS_Ensemble,   // L-BFGS Ensemble
    ltLBFGS_Ensemble_MT // L-BFGS Ensemble with Parallel
    );

const
  CLearnString: array [TLearnType] of SystemString = (
    'k-dimensional tree',
    'k-means++ clusterization',
    'Random forest',
    'Logistic regression',
    'Levenberg-Marquardt',
    'Levenberg-Marquardt with Parallel',
    'L-BFGS',
    'L-BFGS with Parallel',
    'L-BFGS with Parallel and optimization',
    'fast Monte Carlo',
    'Levenberg-Marquardt Ensemble',
    'Levenberg-Marquardt Ensemble with Parallel',
    'L-BFGS Ensemble',
    'L-BFGS Ensemble with Parallel'
    );

procedure DoStatus(v: TLVec); overload;
procedure DoStatus(v: TLIVec); overload;
procedure DoStatus(v: TLBVec); overload;
procedure DoStatus(v: TLMatrix); overload;
procedure DoStatus(v: TLIMatrix); overload;
procedure DoStatus(v: TLBMatrix); overload;

implementation

procedure DoStatus(v: TLVec);
var
  i: NativeInt;
begin
  for i := 0 to length(v) - 1 do
      DoStatusNoLn(umlFloatToStr(v[i]) + ' ');
  DoStatusNoLn;
end;

procedure DoStatus(v: TLIVec);
var
  i: NativeInt;
begin
  for i := 0 to length(v) - 1 do
      DoStatusNoLn(umlIntToStr(v[i]) + ' ');
  DoStatusNoLn;
end;

procedure DoStatus(v: TLBVec);
var
  i: NativeInt;
begin
  for i := 0 to length(v) - 1 do
      DoStatusNoLn(umlBoolToStr(v[i]) + ' ');
  DoStatusNoLn;
end;

procedure DoStatus(v: TLMatrix);
var
  i: Integer;
begin
  for i := 0 to high(v) do
      DoStatus(v[i]);
end;

procedure DoStatus(v: TLIMatrix);
var
  i: Integer;
begin
  for i := 0 to high(v) do
      DoStatus(v[i]);
end;

procedure DoStatus(v: TLBMatrix);
var
  i: Integer;
begin
  for i := 0 to high(v) do
      DoStatus(v[i]);
end;

end.
