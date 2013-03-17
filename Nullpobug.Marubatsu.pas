unit Nullpobug.Marubatsu;

interface

uses
  System.SysUtils
  ;

type
  EStateError = class(Exception);
  EAleadyFilled = class(Exception);
  EInvalidDiagonaltype = class(Exception);
  EInvalidPlayerType = class(Exception);

  // ゲームのプレイヤータイプ
  TGamePlayerType = (gptPlayer, gptCPU);
  // ゲームの勝者
  TGameWinner = (gwNone, gwPlayer, gwCPU);
  // ゲームの進行状態
  TGameState = (gsInit, gsPlayerTurn, gsCPUTurn, gsEnd);
  // マス目の状態
  TCellState = (csEmpty, csPlayer, csCPU);
  // 対角線の種類(\, /)
  TDiagonalType = (dtBackSlash, dtSlash);

  TGameTable = class
  private
    FCells: array [0..2, 0..2] of TCellState;
  public
    constructor Create;
    function GetCell(X, Y: Integer): TCellState;
    procedure SetCell(X, Y: Integer; State: TCellState);
    function IsFilledRow(X: Integer; State: TCellState): Boolean;
    function IsFilledCol(Y: Integer; State: TCellState): Boolean;
    function IsFilledDiagonal(DiagonalType: TDiagonalType;
        State: TCellState): Boolean;
    function GetWidth: Integer;
    function GetHeight: Integer;
    property Cell[X, Y: Integer]: TCellState read GetCell write SetCell; default;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
  end;

  TGame = class
  private
    FState: TGameState;
    FTable: TGameTable;
    FWinner: TGameWinner;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start; overload;
    procedure Start(Starter: TGamePlayerType); overload;
    procedure Put(X, Y: Integer; Player: TGamePlayerType);
    procedure DetermineWinner;
    procedure UpdateState(NextPlayer: TGamePlayerType);
    procedure Finish(Winner: TGameWinner);
    property State: TGameState read FState;
    property Table: TGameTable read FTable;
    property Winner: TGameWinner read FWinner;
  end;

function PlayerTypeToCellState(PlayerType: TGamePlayerType): TCellState;
function PlayerTypeToWinner(PlayerType: TGamePlayerType): TGameWinner;

implementation

(* TGameTable *)
constructor TGameTable.Create;
var
  X, Y: Integer;
begin
  // 盤面を空に設定する
  for X := Low(FCells) to High(FCells) do
    for Y := Low(FCells[X]) to High(FCells[X]) do
      FCells[X][Y] := csEmpty;
end;

function TGameTable.GetCell(X, Y: Integer): TCellState;
(* 指定した位置のマス目の値を返す *)
begin
  Result := FCells[X][Y];
end;

procedure TGameTable.SetCell(X, Y: Integer; State: TCellState);
(* 指定した位置のマス目の値を変更する *)
begin
  FCells[X][Y] := State;
end;

function TGameTable.IsFilledRow(X: Integer; State: TCellState): Boolean;
(* 指定した行がすべて同じ状態ならTrueを返す *)
var
  Y: Integer;
begin
  Result := True;
  for Y := Low(FCells[X]) to High(FCells[X]) do
    // 一つでも違う場合はFalseを返す
    if FCells[X][Y] <> State then
    begin
      Result := False;
      Exit;
    end;
end;

function TGameTable.IsFilledCol(Y: Integer; State: TCellState): Boolean;
(* 指定した列がすべて同じ状態ならTrueを返す *)
var
  X: Integer;
begin
  Result := True;
  for X := Low(FCells) to High(FCells) do
    // 一つでも違う場合はFalseを返す
    if FCells[X][Y] <> State then
    begin
      Result := False;
      Exit;
    end;
end;

function TGameTable.IsFilledDiagonal(DiagonalType: TDiagonalType;
    State: TCellState): Boolean;
(* 指定した斜めの値がすべて同じならTrueを返す *)
var
  X, Y: Integer;
begin
  Result := True;
  for X := Low(FCells) to High(FCells) do
  begin
    case DiagonalType of
      dtBackSlash:
        // \の判定
        Y := X;
      dtSlash:
        // /の判定
        Y := 2 - X;
      else
        raise EInvalidDiagonaltype.Create('Invalid diagonal type.');
    end;
    if FCells[X][Y] <> State then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TGameTable.GetWidth: Integer;
(* テーブルの幅を返す *)
begin
  Result := High(FCells) + 1;
end;

function TGameTable.GetHeight: Integer;
(* テーブルの高さを返す *)
begin
  Result := High(FCells[0]) + 1;
end;
(* end of TGameTable *)

(* TGame *)
constructor TGame.Create;
(* コンストラクタ *)
begin
  // ゲームの初期化
  FState := gsInit;
  FTable := TGameTable.Create;
  FWinner := gwNone;
end;

destructor TGame.Destroy;
begin
  FTable.Free;
  inherited Destroy;
end;

procedure TGame.Start;
(* ゲームを開始する *)
var
  Starter: TGamePlayerType;
begin
  // ランダムで開始プレイヤーを決める
  Starter := TGamePlayerType(Random(Integer(High(TGamePlayerType))));
  // プレイヤーを指定して開始
  Start(Starter);
end;

procedure TGame.Start(Starter: TGamePlayerType);
(* 開始プレイヤーを指定してゲームを開始する *)
begin
  if State <> gsInit then
    raise EStateError.Create('Invalid state.');
  UpdateState(Starter);
end;

procedure TGame.Put(X, Y: Integer; Player: TGamePlayerType);
(* マルバツを置く *)
begin
  // 対象のマス目が空でなければエラー
  if FTable[X, Y] <> csEmpty then
    raise EAleadyFilled.CreateFmt('(%d, %d) is already filled.', [X, Y]);
  case Player of
    gptPlayer:
      FTable[X, Y] := csPlayer;
    gptCPU:
      FTable[X, Y] := csCPU;
  end;
end;

procedure TGame.DetermineWinner;
(*
  勝敗の判定
  縦、横、斜めのうちどれかが揃っていたら勝者を更新する
 *)
var
  X, Y: Integer;
  DiagonalType: TDiagonalType;
  PlayerType: TGamePlayerType;
begin
  for PlayerType in [gptPlayer, gptCPU] do
  begin
    // 横が揃っているかを判定
    for Y := 0 to FTable.Height - 1 do
      if FTable.IsFilledRow(Y, PlayerTypeToCellState(PlayerType)) then
      begin
        // 揃っていたら勝者を設定して終了
        Finish(PlayerTypeToWinner(PlayerType));
        Exit;
      end;
    // 縦が揃っているかを判定
    for X := 0 to FTable.Height - 1 do
      if FTable.IsFilledCol(X, PlayerTypeToCellState(PlayerType)) then
      begin
        // 揃っていたら勝者を設定して終了
        Finish(PlayerTypeToWinner(PlayerType));
        Exit;
      end;
    // 斜めが揃っているかを判定
    for DiagonalType in [dtBackSlash, dtSlash] do
      if FTable.IsFilledDiagonal(DiagonalType, PlayerTypeToCellState(PlayerType)) then
      begin
        // 揃っていたら勝者を設定して終了
        Finish(PlayerTypeToWinner(PlayerType));
        Exit;
      end;
  end;
end;

procedure TGame.UpdateState(NextPlayer: TGamePlayerType);
(*
  ゲームの状態を更新
  NextPlayer: 次のプレイヤー
 *)
begin
  // 終了している場合は何もしない
  if FState = gsEnd then
    Exit;
  // 勝敗を判定する
  DetermineWinner;
  // 勝者が確定しているなら終了する
  if FWinner <> gwNone then
    Exit;
  // 次のプレイヤーの状態に変更する
  case NextPlayer of
    gptPlayer:
      FState := gsPlayerTurn;
    gptCPU:
      FState := gsCPUTurn;
  end;
end;

procedure TGame.Finish(Winner: TGameWinner);
(* 勝者を設定してゲームを終了状態にする *)
begin
  FWinner := Winner;
  FState := gsEnd;
end;
(* end of TGame *)

function PlayerTypeToCellState(PlayerType: TGamePlayerType): TCellState;
(* TGamePlayerTypeに対応するTCellStateを返す *)
begin
  case PlayerType of
    gptPlayer:
      Result := csPlayer;
    gptCPU:
      Result := csCPU;
    else
      raise EInvalidPlayerType.Create('Invalid player type.');
  end;
end;

function PlayerTypeToWinner(PlayerType: TGamePlayerType): TGameWinner;
(* TGamePlayerTypeに対応するTGameWinnerを返す *)
begin
  case PlayerType of
    gptPlayer:
      Result := gwPlayer;
    gptCPU:
      Result := gwCPU;
    else
      raise EInvalidPlayerType.Create('Invalid player type.');
  end;
end;

end.
