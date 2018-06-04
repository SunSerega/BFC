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

procedure Init;

procedure DrawBoard(b: Board; dx, dy: integer);

implementation

var
  cX := 0;
  cY := 0;

function GetColorFromCTId(b: Board; CTId: (integer, integer, byte)): System.ConsoleColor;
begin
  if CTId = nil then
    Result := TempBGColor else
    case CTId[2] of
      Move.sm: Result := (b.cls[CTId[0], CTId[1]] = Empty) ? System.ConsoleColor.Green : System.ConsoleColor.Red;
      Move.ep: Result := System.ConsoleColor.Red;
      Move.crm: Result := System.ConsoleColor.Magenta;
      Move.pm: Result := System.ConsoleColor.Yellow;
    end;
end;

procedure DrawBoard(b: Board; dx, dy: integer);
begin
  var s := #9608 * 10;
  var ColoredTiles: List<(integer, integer, byte)>;
  if (b.cls[cX, cY] <> Empty) and (b.white_move = b.IsWhite(cX, cY)) then
  begin
    var temp: Board;
    var wcp: ()->boolean := ()->not temp.WKingUnderAttack;
    var bcp: ()->boolean := ()->not temp.BKingUnderAttack;
    var check_proc: ()->boolean := b.white_move ? wcp : bcp;
    ColoredTiles := b.GetAllMoves(cX, cY).Where(m -> begin
      
      temp := b.Copy;
      m.UseOn(temp, false);
      Result := check_proc;
      
    end).SelectMany(m -> m.GetAllColoredTiles).ToList
  end else
    ColoredTiles := new List<(integer, integer, byte)>;
  
  System.Console.SetCursorPosition(dx, dy);
  System.Console.ForegroundColor := FrameColor;
  System.Console.Write(s);
  for var y := 0 to 7 do
  begin
    System.Console.SetCursorPosition(dx, dy+y + 1);
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
  System.Console.SetCursorPosition(dx, dy+9);
  System.Console.ForegroundColor := FrameColor;
  System.Console.Write(s);
end;

function GetKeyState(nVirtKey: byte): byte;external 'User32.dll' name 'GetKeyState';

var
  last_tick_pressed := false;

procedure CurrsorControl :=
while true do
  if last_tick_pressed then
  begin
    last_tick_pressed :=
      (GetKeyState($25) shr 7 = 1) or
      (GetKeyState($26) shr 7 = 1) or
      (GetKeyState($27) shr 7 = 1) or
      (GetKeyState($28) shr 7 = 1) or
      
      (GetKeyState($41) shr 7 = 1) or
      (GetKeyState($57) shr 7 = 1) or
      (GetKeyState($44) shr 7 = 1) or
      (GetKeyState($53) shr 7 = 1);
    
    Sleep(1);
  end else
  begin
    Log((cX, cY));
    
    if (GetKeyState($25) shr 7 = 1) or (GetKeyState($41) shr 7 = 1) then cX -= 1;
    if (GetKeyState($26) shr 7 = 1) or (GetKeyState($57) shr 7 = 1) then cY -= 1;
    if (GetKeyState($27) shr 7 = 1) or (GetKeyState($44) shr 7 = 1) then cX += 1;
    if (GetKeyState($28) shr 7 = 1) or (GetKeyState($53) shr 7 = 1) then cY += 1;
    
    if cX < 0 then cX := 0;
    if cY < 0 then cY := 0;
    if cX > 7 then cX := 7;
    if cY > 7 then cY := 7;
    
    last_tick_pressed :=
      (GetKeyState($25) shr 7 = 1) or
      (GetKeyState($26) shr 7 = 1) or
      (GetKeyState($27) shr 7 = 1) or
      (GetKeyState($28) shr 7 = 1) or
      
      (GetKeyState($41) shr 7 = 1) or
      (GetKeyState($57) shr 7 = 1) or
      (GetKeyState($44) shr 7 = 1) or
      (GetKeyState($53) shr 7 = 1);
    
    Sleep(1);
  end;

procedure Init;
begin
  System.Console.CursorVisible := false;
  System.Console.BackgroundColor := System.ConsoleColor.Gray;
  System.Console.Clear;
  (new System.Threading.Thread(CurrsorControl)).Start;
end;

end.