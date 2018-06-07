unit GData;

interface

uses BoardData;

const
  FrameColor = System.ConsoleColor.Black;
  WPC = System.ConsoleColor.White;
  BPC = System.ConsoleColor.Black;
  CurrsorColor = System.ConsoleColor.Cyan;
  BackgroundColor1 = System.ConsoleColor.Gray;
  BackgroundColor2 = System.ConsoleColor.DarkGray;
  TempBGColor = System.ConsoleColor.DarkRed;

var
  cX := 0;
  cY := 0;
  
  cmix := 0;
  cmax := 7;
  cmiy := 0;
  cmay := 7;
  
  RCT:=new List<(integer, integer, byte)>;

function GetKeyState(nVirtKey: byte): byte;

procedure Init;

procedure Display(w, row: integer; s: string);

procedure DrawBoard(b: Board; dx, dy: integer);

implementation

procedure Display(w, row: integer; s: string);
begin
  System.Console.BackgroundColor := BackgroundColor1;
  System.Console.ForegroundColor := System.ConsoleColor.Black;
  System.Console.SetCursorPosition(10, row);
  
  System.Console.Write(s);
  System.Console.Write(' ' * (w - s.Length));
end;

function GetColorFromCTId(b: Board; CTId: (integer, integer, byte)): System.ConsoleColor;
begin
  if CTId = nil then
    Result := TempBGColor else
    case CTId[2] of
      Move.sm: Result := (b.cls[CTId[0], CTId[1]] = Empty) ? System.ConsoleColor.Green : System.ConsoleColor.Red;
      Move.ep: Result := System.ConsoleColor.Red;
      Move.crm: Result := System.ConsoleColor.Magenta;
      Move.pm: Result := System.ConsoleColor.Magenta;
    end;
end;

procedure DrawBoard(b: Board; dx, dy: integer);
begin
  var s := #9608 * 10;
  var ColoredTiles: List<(integer, integer, byte)>;
  if RCT.Count <> 0 then
    ColoredTiles := RCT else
  if (b.cls[cX, cY] <> Empty) and (b.white_move = b.IsWhite(cX, cY)) then
    ColoredTiles := b.GetAllMoves(cX, cY).OnlyAllowed(b.Copy).SelectMany(m -> m.GetAllColoredTiles).ToList else
    ColoredTiles := new List<(integer, integer, byte)>;
  
  System.Console.SetCursorPosition(dx, dy);
  System.Console.ForegroundColor := FrameColor;
  System.Console.Write(s);
  for var y := 0 to 7 do
  begin
    System.Console.SetCursorPosition(dx, dy + y + 1);
    System.Console.ForegroundColor := FrameColor;
    System.Console.Write(#9608);
    for var x := 0 to 7 do
    begin
      var c := ((x = cX) and (y = cY)) ?
      CurrsorColor :
      GetColorFromCTId(b, ColoredTiles.FirstOrDefault(t -> (t[0] = x) and (t[1] = y)));
      System.Console.BackgroundColor := (c = TempBGColor) ? (((x + y) mod 2 = 0) ? BackgroundColor1 : BackgroundColor2) : c;
      
      if b.cls[x, y] = -1 then
        System.Console.Write(' ') else
      begin
        System.Console.ForegroundColor := 
        (b.cls[x, y] div 6 = 0) ? WPC : BPC;
        case b.cls[x, y] mod 6 of
          $0: System.Console.Write('K');
          $1: System.Console.Write('Q');
          $2: System.Console.Write('B');
          $3: System.Console.Write('N');
          $4: System.Console.Write('R');
          $5: System.Console.Write('P');
        end;
      end;
    end;
    System.Console.ForegroundColor := FrameColor;
    System.Console.Write(#9608);
  end;
  System.Console.SetCursorPosition(dx, dy + 9);
  System.Console.ForegroundColor := FrameColor;
  System.Console.Write(s);
end;

function GetKeyState(nVirtKey: byte): byte;external 'User32.dll' name 'GetKeyState';

var
  last_tick_hpressed := false;
  last_tick_vpressed := false;

procedure CurrsorControl :=
while true do
begin
  if not last_tick_hpressed then
  begin
    
    if (GetKeyState($25) shr 7 = 1) or (GetKeyState($41) shr 7 = 1) then cX -= 1;
    if (GetKeyState($27) shr 7 = 1) or (GetKeyState($44) shr 7 = 1) then cX += 1;
    
    if cX < cmix then cX := cmix;
    if cX > cmax then cX := cmax;
    
  end;
  if not last_tick_vpressed then
  begin
    
    if (GetKeyState($26) shr 7 = 1) or (GetKeyState($57) shr 7 = 1) then cY -= 1;
    if (GetKeyState($28) shr 7 = 1) or (GetKeyState($53) shr 7 = 1) then cY += 1;
    
    if cY < cmiy then cY := cmiy;
    if cY > cmay then cY := cmay;
    
  end;
  
  last_tick_hpressed :=
    (GetKeyState($25) shr 7 = 1) or
    (GetKeyState($27) shr 7 = 1) or
    
    (GetKeyState($41) shr 7 = 1) or
    (GetKeyState($44) shr 7 = 1);
  last_tick_vpressed :=
    (GetKeyState($26) shr 7 = 1) or
    (GetKeyState($28) shr 7 = 1) or
    
    (GetKeyState($57) shr 7 = 1) or
    (GetKeyState($53) shr 7 = 1);
  
  Sleep(5);
end;

procedure Init;
begin
  System.Console.CursorVisible := false;
  System.Console.BackgroundColor := System.ConsoleColor.Gray;
  System.Console.Clear;
  (new System.Threading.Thread(CurrsorControl)).Start;
end;

end.