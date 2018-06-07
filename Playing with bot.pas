uses BoardData, GData, BotData;

const
  evolv_dir_name = 'Evolution Records';

var
  current_dir: string;
  current_gen_id: integer;

procedure LoadEvolvRecord(name:string);
begin
  current_dir := name;
  var ids :=
    System.IO.Directory.EnumerateDirectories(current_dir)
    .Where(s->System.IO.Directory.Exists(s+'\Best Bots'))
    .Select(s->System.Convert.ToInt32(s.Split(' ').Last))
    .OrderByDescending(i->i);
  if not ids.Any then
  begin
    writeln('No evolv data. Run "Training.exe" first.');
    readln;
    System.Environment.Exit(0);
  end;
  current_gen_id := ids.First;
  Bot.LoadFrom(name+'\Gen '+current_gen_id);
end;

procedure Init;
begin
  
  System.IO.Directory.CreateDirectory(evolv_dir_name);
  var existing := System.IO.Directory.GetDirectories(evolv_dir_name);
  if existing.Length = 0 then
  begin
    writeln('No evolv data. Run "Training.exe" first.');
    readln;
    System.Environment.Exit(0);
  end;
  if existing.Length=1 then
  begin
    LoadEvolvRecord(existing[0]);
    exit;
  end;
  while true do
  try
    System.Console.Clear;
    for var i := 0 to existing.Length-1 do
      writeln($'{i}: Load "{existing[i].Split(''\'').Last}";');
    var ch := ReadlnInteger;
    LoadEvolvRecord(existing[ch]);
    exit;
  except
    existing := System.IO.Directory.GetDirectories(evolv_dir_name);
  end;
  
end;

var
  CC2Allowed := false;
  w:integer;
  
  bt:Bot;
  bd:Board;
  
  psw:boolean;
  prom_avail := false;
  playing := false;

procedure CC2 := try
  
  var ep := false;
  var mca:=new List<Move>;
  
  while true do
  begin
    
    while not CC2Allowed do Sleep(100);
    
    if prom_avail and ((cX < 2)or(cX>5)) then
    if cY = -1 then
      cY += 1 else
    if CY = 8 then
      cY -= 1;
    
    var nep := GetKeyState($0D) shr 7 = 1;
    
    if (not ep) and nep then
    if mca.Count = 0 then
    begin
      
      if (bd.cls[cX,cY] <> Empty) and (bd.IsWhite(cX,cY)=psw) then
      begin
        mca := bd.GetAllMoves(cX,cY).OnlyAllowed(bd.Copy).ToList;
        prom_avail := mca.Any(m->m.IsPromotion);
        if prom_avail then
          if psw then
            GData.cmiy := -1 else
            GData.cmay := 8;
        RCT := mca.SelectMany(m -> m.GetAllColoredTiles).ToList
      end;
      
    end else
      foreach var m in mca do
        if m.IsEndPos(cX,cY) then
        try
          CC2Allowed := false;
          mca.Clear;
          if prom_avail then
            if psw then
              GData.cmiy := 0 else
              GData.cmay := 7;
          prom_avail := false;
          RCT.Clear;
          m.UseOn(bd,true);
          break;
    except
      on e: MateGE do
      begin
        Display(w,8,e.white_win?'White won!':'Black won!');
        while GetKeyState($0D) shr 7 = 1 do System.Threading.Thread.Yield;
        while GetKeyState($0D) shr 7 = 0 do System.Threading.Thread.Yield;
        playing := false;
        break;
      end;
      on DrawGE do
      begin
        Display(w,8,'Draw!');
        while GetKeyState($0D) shr 7 = 1 do System.Threading.Thread.Yield;
        while GetKeyState($0D) shr 7 = 0 do System.Threading.Thread.Yield;
        playing := false;
        break;
      end;
    end;
    
    ep := nep;
    
  end;
  
except
  on e:Exception do SaveError(e);
end;

begin
  
  try
  
  Init;
  GData.Init;
  
  w := Max(17,current_dir.Split('\').Last.Length);
  System.Console.SetWindowSize(10+w, 10);
  System.Console.SetBufferSize(10+w, 10);
  
  (new System.Threading.Thread(CC2)).Start;
  
  while true do for var i := 0 to Bot.bots.Count-1 do
  begin
    
    bt := Bot.bots[i];
    bd := Board.GetStartBoard;
    
    System.Console.SetCursorPosition(0,0);
    System.Console.BackgroundColor := System.ConsoleColor.Black;
    System.Console.ForegroundColor := System.ConsoleColor.Gray;
    while true do
    begin
      System.Console.Clear;
      writeln('Chose side:');
      writeln('0: Any;');
      writeln('1: White;');
      writeln('2: Black;');
      var s := ReadlnString;
      if s.Length <> 1 then continue;
      case s[1] of
        '0':psw := Random(2)<>0;
        '1':psw := true;
        '2':psw := false;
        else continue;
      end;
      break;
    end;
  System.Console.BackgroundColor := System.ConsoleColor.Gray;
  System.Console.Clear;
    
    playing := true;
    while playing do
    
    if bd.white_move = psw then
    begin
    
    CC2Allowed := true;
    
    
    
    Display(w,0,current_dir.Split('\').Last);
    Display(w,1,'Gen #'+current_gen_id.ToString);
    Display(w,2,'You play as '+(psw?'white':'black'));
    
    DrawBoard(bd,0,0);
    
    if prom_avail then
    begin
      
      System.Console.SetCursorPosition(3,psw?0:9);//ToDo Currsor Drawing
      System.Console.ForegroundColor := psw?WPC:BPC;
      var s := 'RNBQ';
      if (cY <> -1) and (cY <> 8) then
      begin
        System.Console.BackgroundColor := System.ConsoleColor.Magenta;
        System.Console.Write(s);
      end else
        for var x := 2 to 5 do
        begin
          System.Console.BackgroundColor := x=cX?
            GData.CurrsorColor:
            System.ConsoleColor.Magenta;
          System.Console.Write(s[x-1]);
        end;
      
    end;
    
    Sleep(100);
    
    end else
    try
      DrawBoard(bd,0,0);
      bt.DecideMove(bd,not psw).UseOn(bd,true);
    except
      on e: MateGE do
      begin
        Display(w,8,e.white_win?'White won!':'Black won!');
        while GetKeyState($0D) shr 7 = 1 do System.Threading.Thread.Yield;
        while GetKeyState($0D) shr 7 = 0 do System.Threading.Thread.Yield;
        playing := false;
      end;
      on DrawGE do
      begin
        Display(w,8,'Draw!');
        while GetKeyState($0D) shr 7 = 1 do System.Threading.Thread.Yield;
        while GetKeyState($0D) shr 7 = 0 do System.Threading.Thread.Yield;
        playing := false;
      end;
    end;
    
  end;
  
  except
    on e:Exception do SaveError(e);
  end;
end.