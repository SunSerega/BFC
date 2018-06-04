uses BoardData, GData;

function BFS(params a: array of string): Board;
begin
  Result := new Board;
  for var y := 0 to 7 do
    for var x := 0 to 7 do
      case a[y][x + 1] of
        '-': Result.cls[x, y] := -1;
        
        'P': Result.cls[x, y] := $B;
        'R': Result.cls[x, y] := $A;
        'N': Result.cls[x, y] := $9;
        'B': Result.cls[x, y] := $8;
        'Q': Result.cls[x, y] := $7;
        'K': Result.cls[x, y] := $6;
        
        'p': Result.cls[x, y] := $5;
        'r': Result.cls[x, y] := $4;
        'n': Result.cls[x, y] := $3;
        'b': Result.cls[x, y] := $2;
        'q': Result.cls[x, y] := $1;
        'k': Result.cls[x, y] := $0;
      end;
end;

begin
  var b := BFS(
    '---R-K-R',
    '----P---',
    '-P----PP',
    '--p--B-n',
    'r-pp--Np',
    '-----p-b',
    '---n-B--',
    '----k---');
  b.white_move := true;
  b := Board.GetStartBoard;
  DrawBoard(b);
  Log(b.GetAllMoves.Count.ToString);
  readln;
end.