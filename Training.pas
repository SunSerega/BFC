uses BoardData, GData, BotData;

const
  evolv_dir_name = 'Evolution Records';

var
  current_dir: string;
  current_gen_id: integer;

procedure CreateNewEvolvRecord;
begin
  while true do
  try
    System.Console.Clear;
    writeln('Enter record name:');
    current_dir := evolv_dir_name + '\' + ReadlnString;
    current_gen_id := 0;
    System.IO.Directory.CreateDirectory(current_dir);
    Bot.Init(2);
    System.IO.Directory.CreateDirectory(current_dir + '\Gen ' + current_gen_id + '\Bots');
    Bot.bots.ForEach(procedure(b, i)-> b.Save(current_dir + '\Gen ' + current_gen_id + '\Bots\bot ' + i + '.bin'));
    exit;
  except
    if System.IO.Directory.Exists(current_dir) then
      System.IO.Directory.Delete(current_dir);
  end;
end;

procedure LoadEvolvRecord(name:string);
begin
  current_dir := name;
  current_gen_id := 
    System.IO.Directory.EnumerateDirectories(current_dir)
    .Select(s->StrToInt(s.Split(' ').Last))
    .OrderByDescending(i->i)
    .First;
  Bot.InitFrom(name+'\Gen '+current_gen_id);
end;

procedure LoadSettings;
begin
  var f:TextFile;
  Reset(f,'Training Settings.txt');
  
  Bot.CoresUsed := f.ReadInteger; f.Readln;
  
  f.Close;
end;

procedure Init;
begin
  
  System.IO.Directory.CreateDirectory(evolv_dir_name);
  var existing := System.IO.Directory.GetDirectories(evolv_dir_name);
  if existing.Length = 0 then
    CreateNewEvolvRecord else
  while true do
  try
    System.Console.Clear;
    writeln('-1: Create New Evolv Record;');
    for var i := 0 to existing.Length-1 do
      writeln($'{i}: Load "{existing[i].Split(''\'').Last}";');
    var ch := ReadlnInteger;
    if ch = -1 then
      CreateNewEvolvRecord else
      LoadEvolvRecord(existing[ch]);
    exit;
  except
    existing := System.IO.Directory.GetDirectories(evolv_dir_name);
  end;
  
end;

begin
  
  try
  
  LoadSettings;
  Init;
  
  (new System.Threading.Thread(()->while true do
    try
      
      Bot.NextGen;
      
      var current_gen_dir := current_dir + '\Gen ' + current_gen_id;
      System.IO.Directory.CreateDirectory(current_gen_dir + '\Best Bots');
      Bot.best_of_gen.ForEach(procedure(b, i)-> b.Save(current_gen_dir + '\Best Bots\bot ' + i + '.bin'));
      
      current_gen_id += 1;
      
      current_gen_dir := current_dir + '\Gen ' + current_gen_id;
      System.IO.Directory.CreateDirectory(current_gen_dir + '\Bots');
      
      Bot.bots.ForEach(procedure(b, i)-> b.Save(current_gen_dir + '\Bots\bot ' + i + '.bin'));
      
    except
      on e: Exception do SaveError(e);
    end)).Start;
  
  GData.Init;
  while Bot.CurrentBoards = nil do Sleep(10);
  
  var w := Max(10,current_dir.Split('\').Last.Length);
  System.Console.SetWindowSize(10+w, 9*Bot.CoresUsed+1);
  System.Console.SetBufferSize(10+w, 9*Bot.CoresUsed+1);
  
  while true do
  begin
    
    System.Console.BackgroundColor := BackgroundColor1;
    
    
    
    Display(w,0,string.Format('{0,6:N2}%',Bot.tgc/Bot.mtg*100));
    Display(w,1,current_dir.Split('\').Last);
    Display(w,2,'Gen #'+current_gen_id.ToString);
    
    
    
    for var i := 0 to Bot.CurrentBoards.Length-1 do
    begin
    
    DrawBoard(Bot.CurrentBoards[i],0,i*9);
    
    if Bot.LastGEs[i] = -2 then continue;
    
    System.Console.SetCursorPosition(10, i*9+8);
    case Bot.LastGEs[i] of
      -1: Display(w,i*9+8,'Black won');
      +0: Display(w,i*9+8,'Draw');
      +1: Display(w,i*9+8,'White won');
    end;
    
    end;
    
    
    Sleep(100);
  end;
  
  except
    on e:Exception do SaveError(e);
  end;
end.