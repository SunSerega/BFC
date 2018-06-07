unit BoardData;

interface

{$region Loging}

procedure WTF(name: string; params obj: array of object);

procedure SaveError(params obj: array of object);

procedure Log(params data: array of object);

procedure Log2(params data: array of object);

procedure Log3(params data: array of object);

{$endregion}

type
  Piece = shortint;
  
  MateGE=class(Exception)
    
    white_win:boolean;
    
    constructor(white_win:boolean);
    begin
      self.white_win := white_win;
    end;
    
    public function ToString:string; override := 
      white_win?'Победили белые':'Победили чёрные';
    
  end;
  DrawGE=class(Exception)
    
    constructor := exit;
    
    public function ToString:string; override := 'Ничья';
    
  end;

const
  WKing = $0;
  WQueen = $1;
  WBishop = $2;
  WKnight = $3;
  WRook = $4;
  WPawn = $5;
  
  BKing = $6;
  BQueen = $7;
  BBishop = $8;
  BKnight = $9;
  BRook = $A;
  BPawn = $B;
  
  Empty = -1;

type
  Move = class;
  
  Board = class
    
    {$region field's}
    
    wko := true;//король в оригинальной позиции
    wlro := true;//левая тура в оригинальной позиции
    wrro := true;//правая тура в оригинальной позиции
    
    bko := true;
    blro := true;
    brro := true;
    
    
    fmp: shortint?;//пешка которая только что походила на 2 клетки
    
    
    white_move := true;//чей ход
    
    
    cls: array[,] of Piece;
    
    {$endregion field's}
    
    {$region method's}
    
    procedure StartMove;
    begin
      
      fmp := nil;
      
    end;
    
    procedure FinishMove;
    begin
      
      white_move := not white_move;
      
      var ms := GetAllMoves;
      var e := ms.GetEnumerator;
      var mn := e.MoveNext;
      //if not GetAllMoves.GetEnumerator.MoveNext then
      if not mn then
      begin
        if white_move?WKingUnderAttack:BKingUnderAttack then
          raise new MateGE(not white_move) else
          raise new DrawGE;
      end;
      
    end;
    
    function WKingUnderAttack: boolean;
    begin
      for var x := 0 to 7 do
        for var y := 0 to 7 do
          if (cls[x, y] = WKing) then
          begin
            Result := UnderAttack(x, y, false);
            exit;
          end;
    end;
    
    function BKingUnderAttack: boolean;
    begin
      for var x := 0 to 7 do
        for var y := 0 to 7 do
          if (cls[x, y] = BKing) then
          begin
            Result := UnderAttack(x, y, true);
            exit;
          end;
    end;
    
    function Copy: Board;
    begin
      
      Result := new Board;
      Result.cls := PABCSystem.Copy(self.cls);
      
      
      Result.bko := self.bko;
      Result.blro := self.blro;
      Result.brro := self.brro;
      
      Result.wko := self.wko;
      Result.wlro := self.wlro;
      Result.wrro := self.wrro;
      
      
      Result.fmp := self.fmp;
      Result.white_move := self.white_move;
      
    end;
    
    function IsWhite(x, y: shortint) := cls[x, y] div 6 = 0;
    function IsBlack(x, y: shortint) := cls[x, y] div 6 = 1;
    
    function UnderAttackByPawn(x, y: shortint; by_white: boolean): boolean;
    function UnderAttackByRook(x, y: shortint; by_white: boolean): boolean;
    function UnderAttackByKnight(x, y: shortint; by_white: boolean): boolean;
    function UnderAttackByBishop(x, y: shortint; by_white: boolean): boolean;
    function UnderAttackByQueen(x, y: shortint; by_white: boolean): boolean;
    function UnderAttackByKing(x, y: shortint; by_white: boolean): boolean;
    
    function UnderAttack(x, y: shortint; by_white: boolean) :=
    UnderAttackByPawn(x, y, by_white) or
      UnderAttackByRook(x, y, by_white) or
      UnderAttackByKnight(x, y, by_white) or
      UnderAttackByBishop(x, y, by_white) or
      UnderAttackByQueen(x, y, by_white) or
      UnderAttackByKing(x, y, by_white);
    
    
    
    function GetAllMovesForPawn(x, y: shortint): sequence of Move;
    function GetAllMovesForRook(x, y: shortint): sequence of Move;
    function GetAllMovesForKnight(x, y: shortint): sequence of Move;
    function GetAllMovesForBishop(x, y: shortint): sequence of Move;
    function GetAllMovesForQueen(x, y: shortint): sequence of Move;
    function GetAllMovesForKing(x, y: shortint): sequence of Move;
    
    function GetAllMoves(x, y: shortint): sequence of Move;
    begin
      case cls[x, y] mod 6 of
        WKing: Result := GetAllMovesForKing(x, y);
        WQueen: Result := GetAllMovesForQueen(x, y);
        WBishop: Result := GetAllMovesForBishop(x, y);
        WKnight: Result := GetAllMovesForKnight(x, y);
        WRook: Result := GetAllMovesForRook(x, y);
        WPawn: Result := GetAllMovesForPawn(x, y);
      else Result := new Move[0];
      end;
    end;
    
    function GetAllMoves: sequence of Move;
    
    {$endregion method's}
    
    {$region constructor's}
    
    constructor :=
    cls := new Piece[8, 8];
    
    class function GetStartBoard: Board;
    begin
      Result := new Board;
      Result.cls := new Piece[8, 8](
        ($A, $B, -1, -1, -1, -1, $5, $4),
        ($9, $B, -1, -1, -1, -1, $5, $3),
        ($8, $B, -1, -1, -1, -1, $5, $2),
        ($7, $B, -1, -1, -1, -1, $5, $1),
        ($6, $B, -1, -1, -1, -1, $5, $0),
        ($8, $B, -1, -1, -1, -1, $5, $2),
        ($9, $B, -1, -1, -1, -1, $5, $3),
        ($A, $B, -1, -1, -1, -1, $5, $4)
      )
    end;
  
    {$endregion constructor's}
  
  end;
  
  Move = abstract class
    
    const sm:byte=1;
    const ep:byte=2;
    const crm:byte=3;
    const pm:byte=4;
    
    procedure UseOn(b: Board; look_for_GE:boolean); abstract;
    procedure Save(bw: System.IO.BinaryWriter); abstract;
    function GetAllColoredTiles:sequence of (integer,integer,byte); abstract;
    function IsEndPos(x,y:integer):boolean; abstract;
    
    function IsSameSM(m:Move):boolean;
    function IsPromotion:boolean;
    
  end;

implementation

{$region Loging}

var
  StartTime := System.DateTime.Now;
  
procedure WTF(name: string; params obj: array of object) := lock name do System.IO.File.AppendAllText(name, string.Join('', obj.ConvertAll(a -> _ObjectToString(a))) + char(13) + char(10));

procedure SaveError(params obj: array of object);
begin
  (new System.Threading.Thread(()->begin
    
    (new System.Threading.Thread(()->System.Console.Beep(1000, 1000))).Start;
    if not System.IO.File.Exists('Errors.txt') then
      WTF('Errors.txt', 'Started|', StartTime);
    var b := true;
    while b do
      try
        WTF('Errors.txt', new object[2](System.DateTime.Now, '|') + obj);
        b := false;
      except
      end;
    
  end)).Start;
end;

procedure Log(params data: array of object) := WTF('Log.txt', data);

procedure Log2(params data: array of object) := WTF('Log2.txt', data);

procedure Log3(params data: array of object) := WTF('Log3.txt', data);

{$endregion}

type
  SimpleMove = class(Move)
    
    fromX, fromY: shortint;
    toX, toY: shortint;
    
    procedure UseOn(b: Board; look_for_GE:boolean); override;
    begin
      
      b.StartMove;
      
      var sf := b.cls[fromX, fromY];
      
      if sf = WKing then b.wko := false else
      if sf = BKing then b.bko := false else
      
      if (sf = WRook) and (fromY = 7) then begin
        
        if fromX = 0 then b.wlro := false else
        if fromX = 7 then b.wrro := false;
        
      end else if (sf = BRook) and (fromY = 0) then begin
        
        if fromX = 0 then b.blro := false else
        if fromX = 7 then b.brro := false;
        
      end else if sf mod 6 = WPawn then begin
        
        if sf div 6 = 0 then
        begin
          if (fromY = 1) and (toY = 3) then
            b.fmp := fromX;
        end else
        begin
          if (fromY = 6) and (toY = 4) then
            b.fmp := fromX;
        end;
        
      end;
      
      b.cls[toX, toY] := b.cls[fromX, fromY];
      b.cls[fromX, fromY] := Empty;
      
      if look_for_GE then b.FinishMove;
      
    end;
    
    public function ToString: string; override;
    begin
      Result := '  -  ';
      Result[1] := char(integer('A') + fromX);
      Result[2] := char(integer('8') - fromY);
      Result[4] := char(integer('A') + toX);
      Result[5] := char(integer('8') - toY);
    end;
    
    function GetAllColoredTiles:sequence of (integer,integer,byte); override;
    begin
      Result := Arr(
        (integer(toX),integer(toY),sm)
      );
    end;
    
    function IsEndPos(x,y:integer):boolean; override := (x = toX) and (y=toY);
    
    procedure Save(bw: System.IO.BinaryWriter); override := raise new System.Exception;
    
    constructor(fx, fy, tx, ty: shortint);
    begin
      fromX := fx;
      fromY := fy;
      toX := tx;
      toY := ty;
    end;
    
    public function GetHashCode:integer; override := 
      (byte(fromX) shl 24) or
      (byte(fromY) shl 16) or
      (byte(toX) shl 8) or
      (byte(toY));
    
  end;
  Castling = class(Move)
    
    white: boolean;
    left: boolean;
    
    wl_ct := Arr(
      (2,7,sm),
      (0,7,crm),
      (3,7,crm)
    );
    wr_ct := Arr(
      (6,7,sm),
      (7,7,crm),
      (5,7,crm)
    );
    bl_ct := Arr(
      (2,0,sm),
      (0,0,crm),
      (3,0,crm)
    );
    br_ct := Arr(
      (6,0,sm),
      (7,0,crm),
      (5,0,crm)
    );
    
    procedure UseOn(b: Board; look_for_GE:boolean); override;
    begin
      
      b.StartMove;
      
      var x1, x2, x3, y: integer;
      if left then
      begin
        x1 := 2;
        x2 := 3;
        x3 := 0;
      end else
      begin
        x1 := 6;
        x2 := 5;
        x3 := 7;
      end;
      if white then
      begin
        y := 7;
        b.wko := false;
        b.cls[x1, y] := WKing;
        b.cls[x2, y] := WRook;
      end else
      begin
        y := 0;
        b.bko := false;
        b.cls[x1, y] := BKing;
        b.cls[x2, y] := BRook;
      end;
      b.cls[x3, y] := Empty;
      b.cls[4, y] := Empty;
      
      if look_for_GE then b.FinishMove;
      
    end;
    
    public function ToString: string; override := left?'0-0-0':'0-0';
    
    function GetAllColoredTiles:sequence of (integer,integer,byte); override :=
      left?(
        white?wl_ct:bl_ct
      ):(
        white?wr_ct:br_ct
      );
    
    function IsEndPos(x,y:integer):boolean; override := 
    (left?(x=2):(x=6)) and
    (white?(y=7):(y=0));
    
    procedure Save(bw: System.IO.BinaryWriter); override := raise new System.Exception;
    
    constructor(white, left: boolean);
    begin
      self.white := white;
      self.left := left;
    end;
  
  end;
  EnPassant = class(Move)
    
    fromX, fromY: shortint;
    toX, toY: shortint;
    
    procedure UseOn(b: Board; look_for_GE:boolean); override;
    begin
      
      b.StartMove;
      
      b.cls[toX, toY] := b.cls[fromX, fromY];
      b.cls[fromX, fromY] := Empty;
      b.cls[toX, fromY] := Empty;
      
      if look_for_GE then b.FinishMove;
      
    end;
    
    public function ToString: string; override;
    begin
      Result := '  -  e.p.';
      Result[1] := char(integer('A') + fromX);
      Result[2] := char(integer('8') - fromY);
      Result[4] := char(integer('A') + toX);
      Result[5] := char(integer('8') - toY);
    end;
    
    function GetAllColoredTiles:sequence of (integer,integer,byte); override;
    begin
      Result := Arr(
        (integer(toX),integer(toY),sm),
        (integer(toX),integer(fromY),ep)
      );
    end;
    
    function IsEndPos(x,y:integer):boolean; override := (x = toX) and (y=toY);
    
    procedure Save(bw: System.IO.BinaryWriter); override := raise new System.Exception;
    
    constructor(fx, fy, tx, ty: shortint);
    begin
      fromX := fx;
      fromY := fy;
      toX := tx;
      toY := ty;
    end;
  
  end;
  Promotion = class(Move)
    
    x, y: shortint;
    nft: Piece;
    
    procedure UseOn(b: Board; look_for_GE:boolean); override;
    begin
      
      b.StartMove;
      
      b.cls[x, y] := nft;
      
      if look_for_GE then b.FinishMove;
      
    end;
    
    public function ToString: string; override;
    begin
      Result := '  = ';
      Result[1] := char(integer('A') + x);
      Result[2] := char(integer('8') - y);
      case nft mod 6 of
        WRook:Result[4] := 'R';
        WKnight:Result[4] := 'N';
        WBishop:Result[4] := 'B';
        WQueen:Result[4] := 'Q';
      end;
    end;
    
    function GetAllColoredTiles:sequence of (integer,integer,byte); override := Arr(
      (integer(x),integer(y),pm)
    );
    
    function IsEndPos(x,y:integer):boolean; override;
    begin
      case nft mod 6 of
        WRook: Result := (x=2) and ((y=-1)or(y=8));
        WKnight: Result := (x=3) and ((y=-1)or(y=8));
        WBishop: Result := (x=4) and ((y=-1)or(y=8));
        WQueen: Result := (x=5) and ((y=-1)or(y=8));
      end;
    end;
    
    procedure Save(bw: System.IO.BinaryWriter); override := raise new System.Exception;
    
    constructor(fx, fy: shortint; fig: Piece);
    begin
      x := fx;
      y := fy;
      nft := fig;
    end;
  
  end;



function OnlyAllowed(self:sequence of Move; b:Board):sequence of Move; extensionmethod :=
  self.where(m->begin
    
    m.UseOn(b,false);
    Result := not (b.white_move ? b.WKingUnderAttack : b.BKingUnderAttack);
    
  end);

function Board.UnderAttackByPawn(x, y: shortint; by_white: boolean): boolean;
begin
  if by_white?(y = 7):(y=0) then exit;
  var ny := by_white ? y + 1 : y - 1;
  if
    ((x <> 0) and (cls[x - 1, ny] mod 6 = WPawn) and (by_white = IsWhite(x - 1, ny))) or
    ((x <> 7) and (cls[x + 1, ny] mod 6 = WPawn) and (by_white = IsWhite(x + 1, ny)))
    then
    Result := true
end;

function Board.UnderAttackByRook(x, y: shortint; by_white: boolean): boolean;
begin
  for var nx := x - 1 downto 0 do
    if (cls[nx, y] mod 6 = WRook) and (IsWhite(nx, y) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[nx, y] <> Empty then break;
  for var nx := x + 1 to 7 do
    if (cls[nx, y] mod 6 = WRook) and (IsWhite(nx, y) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[nx, y] <> Empty then break;
  for var ny := y - 1 downto 0 do
    if (cls[x, ny] mod 6 = WRook) and (IsWhite(x, ny) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[x, ny] <> Empty then break;
  for var ny := y + 1 to 7 do
    if (cls[x, ny] mod 6 = WRook) and (IsWhite(x, ny) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[x, ny] <> Empty then break;
end;

function Board.UnderAttackByKnight(x, y: shortint; by_white: boolean) :=
((x <= 6) and (y <= 5) and (cls[x + 1, y + 2] mod 6 = WKnight) and (by_white = IsWhite(x + 1, y + 2))) or
  ((x <= 6) and (y >= 2) and (cls[x + 1, y - 2] mod 6 = WKnight) and (by_white = IsWhite(x + 1, y - 2))) or
  ((x >= 1) and (y >= 2) and (cls[x - 1, y - 2] mod 6 = WKnight) and (by_white = IsWhite(x - 1, y - 2))) or
  ((x >= 1) and (y <= 5) and (cls[x - 1, y + 2] mod 6 = WKnight) and (by_white = IsWhite(x - 1, y + 2))) or
  
  ((x <= 5) and (y <= 6) and (cls[x + 2, y + 1] mod 6 = WKnight) and (by_white = IsWhite(x + 2, y + 1))) or
  ((x <= 5) and (y >= 1) and (cls[x + 2, y - 1] mod 6 = WKnight) and (by_white = IsWhite(x + 2, y - 1))) or
  ((x >= 2) and (y >= 1) and (cls[x - 2, y - 1] mod 6 = WKnight) and (by_white = IsWhite(x - 2, y - 1))) or
  ((x >= 2) and (y <= 6) and (cls[x - 2, y + 1] mod 6 = WKnight) and (by_white = IsWhite(x - 2, y + 1)));

function Board.UnderAttackByBishop(x, y: shortint; by_white: boolean): boolean;
begin
  var nx, ny: shortint;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx += 1;
    ny += 1;
    if (nx > 7) or (ny > 7) then break;
    if (cls[nx, ny] mod 6 = WBishop) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx += 1;
    ny -= 1;
    if (nx > 7) or (ny < 0) then break;
    if (cls[nx, ny] mod 6 = WBishop) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx -= 1;
    ny -= 1;
    if (nx < 0) or (ny < 0) then break;
    if (cls[nx, ny] mod 6 = WBishop) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx -= 1;
    ny += 1;
    if (nx < 0) or (ny > 7) then break;
    if (cls[nx, ny] mod 6 = WBishop) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
end;

function Board.UnderAttackByQueen(x, y: shortint; by_white: boolean): boolean;
begin
  
  for var nx := x - 1 downto 0 do
    if (cls[nx, y] mod 6 = WQueen) and (IsWhite(nx, y) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[nx, y] <> Empty then break;
  for var nx := x + 1 to 7 do
    if (cls[nx, y] mod 6 = WQueen) and (IsWhite(nx, y) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[nx, y] <> Empty then break;
  for var ny := y - 1 downto 0 do
    if (cls[x, ny] mod 6 = WQueen) and (IsWhite(x, ny) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[x, ny] <> Empty then break;
  for var ny := y + 1 to 7 do
    if (cls[x, ny] mod 6 = WQueen) and (IsWhite(x, ny) = by_white) then
    begin
      Result := true;
      exit;
    end else if cls[x, ny] <> Empty then break;
  
  
  
  var nx, ny: shortint;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx += 1;
    ny += 1;
    if (nx > 7) or (ny > 7) then break;
    if (cls[nx, ny] mod 6 = WQueen) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx += 1;
    ny -= 1;
    if (nx > 7) or (ny < 0) then break;
    if (cls[nx, ny] mod 6 = WQueen) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx -= 1;
    ny -= 1;
    if (nx < 0) or (ny < 0) then break;
    if (cls[nx, ny] mod 6 = WQueen) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx -= 1;
    ny += 1;
    if (nx < 0) or (ny > 7) then break;
    if (cls[nx, ny] mod 6 = WQueen) and (by_white = IsWhite(nx, ny)) then
    begin
      Result := true;
      exit;
    end else if cls[nx, ny] <> Empty then break;
  end;
  
end;

function Board.UnderAttackByKing(x, y: shortint; by_white: boolean) :=
((x >= 1) and (cls[x - 1, y + 0] mod 6 = WKing) and (by_white = IsWhite(x - 1, y + 0))) or
  ((x <= 6) and (cls[x + 1, y + 0] mod 6 = WKing) and (by_white = IsWhite(x + 1, y + 0))) or
  ((y >= 1) and (cls[x + 0, y - 1] mod 6 = WKing) and (by_white = IsWhite(x + 0, y - 1))) or
  ((y <= 6) and (cls[x + 0, y + 1] mod 6 = WKing) and (by_white = IsWhite(x + 0, y + 1))) or
  
  ((x <= 6) and (y <= 6) and (cls[x + 1, y + 1] mod 6 = WKing) and (by_white = IsWhite(x + 1, y + 1))) or
  ((x <= 6) and (y >= 1) and (cls[x + 1, y - 1] mod 6 = WKing) and (by_white = IsWhite(x + 1, y - 1))) or
  ((x >= 1) and (y >= 1) and (cls[x - 1, y - 1] mod 6 = WKing) and (by_white = IsWhite(x - 1, y - 1))) or
  ((x >= 1) and (y <= 6) and (cls[x - 1, y + 1] mod 6 = WKing) and (by_white = IsWhite(x - 1, y + 1)));



function Board.GetAllMovesForPawn(x, y: shortint): sequence of Move;
begin
  var black := IsBlack(x, y);
  
  if black then
  begin
    if y = 7 then
    begin
      yield new Promotion(x, 7, BRook);
      yield new Promotion(x, 7, BKnight);
      yield new Promotion(x, 7, BBishop);
      yield new Promotion(x, 7, BQueen);
      exit;
    end;
  end else
  begin
    if y = 0 then
    begin
      yield new Promotion(x, 0, WRook);
      yield new Promotion(x, 0, WKnight);
      yield new Promotion(x, 0, WBishop);
      yield new Promotion(x, 0, WQueen);
      exit;
    end;
  end;
  
  var ny := black ? y + 1 : y - 1;
  if cls[x, ny] = Empty then
  begin
    yield new SimpleMove(x, y, x, ny);
    if (black?y=1:y=6) and (cls[x, black ? y + 2 : y - 2] = Empty) then yield new SimpleMove(x, y, x, black ? y + 2 : y - 2);
  end;
  
  if (x >= 1) and (cls[x - 1, ny] <> Empty) and (black xor IsBlack(x - 1, ny)) then yield new SimpleMove(x, y, x - 1, ny);
  if (x <= 6) and (cls[x + 1, ny] <> Empty) and (black xor IsBlack(x + 1, ny)) then yield new SimpleMove(x, y, x + 1, ny);
  
  if
  (black ? (y = 4) : (y = 3)) and
    fmp.HasValue and
    (abs(fmp.Value - x) = 1)
    then
    yield new EnPassant(x, y, fmp.Value, ny);
  
end;

function Board.GetAllMovesForRook(x, y: shortint): sequence of Move;
begin
  var white := IsWhite(x, y);
  
  for var nx := x - 1 downto 0 do
  begin
    var occupied := cls[nx, y] <> Empty;
    if occupied and (white xor IsBlack(nx, y)) then break;
    yield new SimpleMove(x, y, nx, y);
    if occupied then break;
  end;
  for var nx := x + 1 to 7 do
  begin
    var occupied := cls[nx, y] <> Empty;
    if occupied and (white xor IsBlack(nx, y)) then break;
    yield new SimpleMove(x, y, nx, y);
    if occupied then break;
  end;
  for var ny := y - 1 downto 0 do
  begin
    var occupied := cls[x, ny] <> Empty;
    if occupied and (white xor IsBlack(x, ny)) then break;
    yield new SimpleMove(x, y, x, ny);
    if occupied then break;
  end;
  for var ny := y + 1 to 7 do
  begin
    var occupied := cls[x, ny] <> Empty;
    if occupied and (white xor IsBlack(x, ny)) then break;
    yield new SimpleMove(x, y, x, ny);
    if occupied then break;
  end;
end;

function Board.GetAllMovesForKnight(x, y: shortint): sequence of Move;
begin
  var white := IsWhite(x, y);
  
  if (x <= 6) and (y <= 5) and ((cls[x + 1, y + 2] = Empty) or (white = IsBlack(x + 1, y + 2))) then yield new SimpleMove(x, y, x + 1, y + 2);
  if (x <= 6) and (y >= 2) and ((cls[x + 1, y - 2] = Empty) or (white = IsBlack(x + 1, y - 2))) then yield new SimpleMove(x, y, x + 1, y - 2);
  if (x >= 1) and (y >= 2) and ((cls[x - 1, y - 2] = Empty) or (white = IsBlack(x - 1, y - 2))) then yield new SimpleMove(x, y, x - 1, y - 2);
  if (x >= 1) and (y <= 5) and ((cls[x - 1, y + 2] = Empty) or (white = IsBlack(x - 1, y + 2))) then yield new SimpleMove(x, y, x - 1, y + 2);
  
  if (x <= 5) and (y <= 6) and ((cls[x + 2, y + 1] = Empty) or (white = IsBlack(x + 2, y + 1))) then yield new SimpleMove(x, y, x + 2, y + 1);
  if (x <= 5) and (y >= 1) and ((cls[x + 2, y - 1] = Empty) or (white = IsBlack(x + 2, y - 1))) then yield new SimpleMove(x, y, x + 2, y - 1);
  if (x >= 2) and (y >= 1) and ((cls[x - 2, y - 1] = Empty) or (white = IsBlack(x - 2, y - 1))) then yield new SimpleMove(x, y, x - 2, y - 1);
  if (x >= 2) and (y <= 6) and ((cls[x - 2, y + 1] = Empty) or (white = IsBlack(x - 2, y + 1))) then yield new SimpleMove(x, y, x - 2, y + 1);
end;

function Board.GetAllMovesForBishop(x, y: shortint): sequence of Move;
begin
  var white := IsWhite(x, y);
  var nx, ny: shortint;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx += 1;
    ny += 1;
    if (nx > 7) or (ny > 7) then break;
    var occupied := cls[nx, ny] <> Empty;
    if occupied and (white xor IsBlack(nx, ny)) then break;
    yield new SimpleMove(x, y, nx, ny);
    if occupied then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx += 1;
    ny -= 1;
    if (nx > 7) or (ny < 0) then break;
    var occupied := cls[nx, ny] <> Empty;
    if occupied and (white xor IsBlack(nx, ny)) then break;
    yield new SimpleMove(x, y, nx, ny);
    if occupied then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx -= 1;
    ny -= 1;
    if (nx < 0) or (ny < 0) then break;
    var occupied := cls[nx, ny] <> Empty;
    if occupied and (white xor IsBlack(nx, ny)) then break;
    yield new SimpleMove(x, y, nx, ny);
    if occupied then break;
  end;
  
  nx := x;
  ny := y;
  while true do
  begin
    nx -= 1;
    ny += 1;
    if (nx < 0) or (ny > 7) then break;
    var occupied := cls[nx, ny] <> Empty;
    if occupied and (white xor IsBlack(nx, ny)) then break;
    yield new SimpleMove(x, y, nx, ny);
    if occupied then break;
  end;
  
end;

function Board.GetAllMovesForQueen(x, y: shortint): sequence of Move;
begin
  Result := GetAllMovesForRook(x, y) + GetAllMovesForBishop(x, y);
end;

function Board.GetAllMovesForKing(x, y: shortint): sequence of Move;
begin
  var black := IsBlack(x, y);
  
  if (x >= 1) and ((cls[x - 1, y + 0] = Empty) or (black = IsWhite(x - 1, y + 0))) then yield new SimpleMove(x, y, x - 1, y + 0);
  if (x <= 6) and ((cls[x + 1, y + 0] = Empty) or (black = IsWhite(x + 1, y + 0))) then yield new SimpleMove(x, y, x + 1, y + 0);
  if (y >= 1) and ((cls[x + 0, y - 1] = Empty) or (black = IsWhite(x + 0, y - 1))) then yield new SimpleMove(x, y, x + 0, y - 1);
  if (y <= 6) and ((cls[x + 0, y + 1] = Empty) or (black = IsWhite(x + 0, y + 1))) then yield new SimpleMove(x, y, x + 0, y + 1);
  
  if (x <= 6) and (y <= 6) and ((cls[x + 1, y + 1] = Empty) or (black = IsWhite(x + 1, y + 1))) then yield new SimpleMove(x, y, x + 1, y + 1);
  if (x <= 6) and (y >= 1) and ((cls[x + 1, y - 1] = Empty) or (black = IsWhite(x + 1, y - 1))) then yield new SimpleMove(x, y, x + 1, y - 1);
  if (x >= 1) and (y >= 1) and ((cls[x - 1, y - 1] = Empty) or (black = IsWhite(x - 1, y - 1))) then yield new SimpleMove(x, y, x - 1, y - 1);
  if (x >= 1) and (y <= 6) and ((cls[x - 1, y + 1] = Empty) or (black = IsWhite(x - 1, y + 1))) then yield new SimpleMove(x, y, x - 1, y + 1);
  
  if black then
  begin
    if not bko then exit;
    
    if
    blro and
      (cls[1, 0] = Empty) and
      (cls[2, 0] = Empty) and
      (cls[3, 0] = Empty) and
      
      (not UnderAttack(2, 0, true)) and
      (not UnderAttack(3, 0, true)) and
      (not UnderAttack(4, 0, true))
      then
      yield new Castling(false, true);
    
    if
    brro and
      (cls[6, 0] = Empty) and
      (cls[5, 0] = Empty) and
      
      (not UnderAttack(6, 0, true)) and
      (not UnderAttack(5, 0, true)) and
      (not UnderAttack(4, 0, true))
      then
      yield new Castling(false, false);
    
  end else
  begin
    if not wko then exit;
    
    if
    wlro and
      (cls[1, 7] = Empty) and
      (cls[2, 7] = Empty) and
      (cls[3, 7] = Empty) and
      
      (not UnderAttack(2, 7, false)) and
      (not UnderAttack(3, 7, false)) and
      (not UnderAttack(4, 7, false))
      then
      yield new Castling(true, true);
    
    if
    wrro and
      (cls[6, 7] = Empty) and
      (cls[5, 7] = Empty) and
      
      (not UnderAttack(6, 7, false)) and
      (not UnderAttack(5, 7, false)) and
      (not UnderAttack(4, 7, false))
      then
      yield new Castling(true, false);
    
  end;
end;

function Board.GetAllMoves: sequence of Move;
begin
  for var x := 0 to 7 do
    for var y := 0 to 7 do
      if (cls[x, y] <> Empty) and (IsWhite(x, y) = white_move) then
        foreach var m in GetAllMoves(x, y) do
        begin
          var temp := self.Copy;
          m.UseOn(temp, false);
          if not (white_move ? (temp.WKingUnderAttack) : (temp.BKingUnderAttack)) then
            yield m;
        end;
end;

function Move.IsSameSM(m:Move):boolean;
begin
  var sm1 := self as SimpleMove;
  if sm1 = nil then exit;
  var sm2 := m as SimpleMove;
  if sm2 = nil then exit;
  Result := 
    (sm1.fromX=sm2.fromX) and (sm1.toX=sm2.toX) and
    (sm1.fromY=sm2.fromY) and (sm1.toY=sm2.toY);
end;

function Move.IsPromotion:boolean := self is Promotion;



begin
  System.IO.File.Delete('Errors.txt');
  System.IO.File.Delete('Log.txt');
  System.IO.File.Delete('Log2.txt');
  System.IO.File.Delete('Log3.txt');
end.