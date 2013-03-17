unit Nullpobug.MarubatsuTest;

interface

uses
  Nullpobug.UnitTest
  , Nullpobug.Marubatsu
  ;

type
  TGameTableTest = class(TTestCase)
  private
    FGameTable: TGameTable;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestCellIsEmpty;
    procedure TestUpdateCell;
  end;

  TGameTableIsFilledRowTest = class(TTestCase)
  private
    FGameTable: TGameTable;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
  end;

  TGameTableIsFilledColTest = class(TTestCase)
  private
    FGameTable: TGameTable;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
  end;

  TGameTableIsFilledDiagonalTest = class(TTestCase)
  private
    FGameTable: TGameTable;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure Test;
  end;

  TGameTest = class(TTestCase)
  private
    FGame: TGame;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestStartWithPlayer;
    procedure TestStartWithCPU;
  end;

  TGamePutTest = class(TTestCase)
  private
    FGame: TGame;
  published
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestPutPlayer;
    procedure TestPutCPU;
    procedure TestInvalid;
  end;

  TPlayerTypeToCellStateTest = class(TTestCase)
  published
    procedure Test;
  end;

  TPlayerTypeToWinnerTest = class(TTestCase)
  published
    procedure Test;
  end;

implementation

(* TGameTableTest *)
procedure TGameTableTest.SetUp;
begin
  FGameTable := TGameTable.Create;
end;

procedure TGameTableTest.TearDown;
begin
  FGameTable.Free;
end;

procedure TGameTableTest.TestCellIsEmpty;
(* すべてのセルが空の値になること *)
var
  X, Y: Integer;
begin
  for X := 0 to 2 do
    for Y := 0 to 2 do
      AssertTrue(FGameTable[X, Y] = csEmpty);
end;

procedure TGameTableTest.TestUpdateCell;
(* セルの更新ができること *)
begin
  AssertTrue(FGameTable[0, 0] = csEmpty);
  FGameTable[0, 0] := csPlayer;
  AssertTrue(FGameTable[0, 0] = csPlayer);
end;
(* end of TGameTableTest *)

(* TGameTableIsFilledRowTest *)
procedure TGameTableIsFilledRowTest.SetUp;
begin
  FGameTable := TGameTable.Create;
  FGameTable[0, 0] := csPlayer;
  FGameTable[0, 1] := csPlayer;
  FGameTable[0, 2] := csPlayer;
end;

procedure TGameTableIsFilledRowTest.TearDown;
begin
  FGameTable.Free;
end;

procedure TGameTableIsFilledRowTest.Test;
begin
  // 0行だけ埋まっている
  AssertTrue(FGameTable.IsFilledRow(0, csPlayer));
  AssertFalse(FGameTable.IsFilledRow(1, csPlayer));
  AssertFalse(FGameTable.IsFilledRow(2, csPlayer));
  AssertFalse(FGameTable.IsFilledRow(0, csEmpty));
  AssertTrue(FGameTable.IsFilledRow(1, csEmpty));
  AssertTrue(FGameTable.IsFilledRow(2, csEmpty));
end;
(* end of TGameTableIsFilledRowTest *)

(* TGameTableIsFilledColTest *)
procedure TGameTableIsFilledColTest.SetUp;
begin
  FGameTable := TGameTable.Create;
  FGameTable[0, 0] := csPlayer;
  FGameTable[1, 0] := csPlayer;
  FGameTable[2, 0] := csPlayer;
end;

procedure TGameTableIsFilledColTest.TearDown;
begin
  FGameTable.Free;
end;

procedure TGameTableIsFilledColTest.Test;
begin
  // 0行だけ埋まっている
  AssertTrue(FGameTable.IsFilledCol(0, csPlayer));
  AssertFalse(FGameTable.IsFilledCol(1, csPlayer));
  AssertFalse(FGameTable.IsFilledCol(2, csPlayer));
  AssertFalse(FGameTable.IsFilledCol(0, csEmpty));
  AssertTrue(FGameTable.IsFilledCol(1, csEmpty));
  AssertTrue(FGameTable.IsFilledCol(2, csEmpty));
end;
(* end of TGameTableIsFilledColTest *)

(* TGameTableIsFilledDiagonalTest *)
procedure TGameTableIsFilledDiagonalTest.SetUp;
begin
  FGameTable := TGameTable.Create;
  FGameTable[0, 0] := csPlayer;
  FGameTable[1, 1] := csPlayer;
  FGameTable[2, 2] := csPlayer;
  FGameTable[0, 2] := csPlayer;
  FGameTable[2, 0] := csPlayer;
end;

procedure TGameTableIsFilledDiagonalTest.TearDown;
begin
  FGameTable.Free;
end;

procedure TGameTableIsFilledDiagonalTest.Test;
begin
  // \と/が埋まっている
  AssertTrue(FGameTable.IsFilledDiagonal(dtBackSlash, csPlayer));
  AssertTrue(FGameTable.IsFilledDiagonal(dtSlash, csPlayer));
  AssertFalse(FGameTable.IsFilledDiagonal(dtBackSlash, csCPU));
  AssertFalse(FGameTable.IsFilledDiagonal(dtSlash, csCPU));
end;
(* end of TGameTableIsFilledDiagonalTest *)

(* TGameTest *)
procedure TGameTest.SetUp;
begin
  FGame := TGame.Create;
end;

procedure TGameTest.TearDown;
begin
  FGame.Free;
end;

procedure TGameTest.TestStartWithPlayer;
(* プレイヤーを指定して開始(プレイヤー) *)
begin
  FGame.Start(gptPlayer);
  AssertTrue(FGame.State = gsPlayerTurn);
end;

procedure TGameTest.TestStartWithCPU;
(* プレイヤーを指定して開始(CPU) *)
begin
  FGame.Start(gptCPU);
  AssertTrue(FGame.State = gsCPUTurn);
end;
(* end of TGameTest *)

(* TGamePutTest *)
procedure TGamePutTest.SetUp;
begin
  FGame := TGame.Create;
  FGame.Table[0, 1] := csPlayer;
end;

procedure TGamePutTest.TearDown;
begin
  FGame.Free;
end;

procedure TGamePutTest.TestPutPlayer;
(* TGame.PutメソッドでPlayerが値を置けること *)
begin
  FGame.Put(0, 0, gptPlayer);
  AssertTrue(FGame.Table[0, 0] = csPlayer);
end;

procedure TGamePutTest.TestPutCPU;
(* TGame.PutメソッドでCPUが値を置けること *)
begin
  FGame.Put(0, 0, gptCPU);
  AssertTrue(FGame.Table[0, 0] = csCPU);
end;

procedure TGamePutTest.TestInvalid;
(* TGame.Putメソッドで既に値が入っていると置けない *)
begin
  AssertRaises(
    EAleadyFilled,
    procedure begin
      FGame.Put(0, 1, gptPlayer);
    end
  );
end;
(* end of TGamePutTest *)

(* TPlayerTypeToCellStateTest *)
procedure TPlayerTypeToCellStateTest.Test;
begin
  AssertTrue(PlayerTypeToCellState(gptPlayer) = csPlayer);
  AssertTrue(PlayerTypeToCellState(gptCPU) = csCPU);
end;
(* end of TPlayerTypeToCellStateTest *)

(* TPlayerTypeToWinnerTest *)
procedure TPlayerTypeToWinnerTest.Test;
begin
  AssertTrue(PlayerTypeToWinner(gptPlayer) = gwPlayer);
  AssertTrue(PlayerTypeToWinner(gptCPU) = gwCPU);
end;
(* end of TPlayerTypeToWinnerTest *)

initialization
  RegisterTest(TGameTableTest);
  RegisterTest(TGameTableIsFilledRowTest);
  RegisterTest(TGameTableIsFilledColTest);
  RegisterTest(TGameTableIsFilledDiagonalTest);
  RegisterTest(TGameTest);
  RegisterTest(TGamePutTest);
  RegisterTest(TPlayerTypeToCellStateTest);
  RegisterTest(TPlayerTypeToWinnerTest);

end.
