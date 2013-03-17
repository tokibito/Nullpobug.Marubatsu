unit Nullpobug.Marubatsu.CPU;

interface

uses
  System.SysUtils
  , Nullpobug.Marubatsu
  ;

type
  TAbstractCPU = class abstract
  private
    FGame: TGame;
    FPlayerType: TGamePlayerType;
  public
    constructor Create(Game: TGame; PlayerType: TGamePlayerType = gptCPU);
    procedure Play; virtual; abstract;
    property Game: TGame read FGame;
  end;

  TCPU1 = class(TAbstractCPU)
  public
    procedure Play; override;
  end;

implementation

(* TAbstractCPU *)
constructor TAbstractCPU.Create(Game: TGame; PlayerType: TGamePlayerType = gptCPU);
begin
  FGame := Game;
  FPlayerType := PlayerType;
end;
(* end of TAbstractCPU *)

(* TCPU1 *)
procedure TCPU1.Play;
(* ゲームを進行する *)
var
  X, Y: Integer;
begin
  // 空いてる場所に置く
  for X := 0 to FGame.Table.Width - 1 do
    for Y := 0 to FGame.Table.Height - 1 do
      if FGame.Table[X, Y] = csEmpty then
        FGame.Put(X, Y, FPlayerType);
end;
(* end of TCPU1 *)

end.
