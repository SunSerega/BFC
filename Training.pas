uses BoardData, GData, BotData;

//ATTENTION вернуть макс ботов к 100

//ToDo сейчас делает пустую папку и вроде ещё перезаписывает то что было, если загружать сохранение
//ToDo добавить версию нейронной сети, чтоб можно было потом другие виды добавить

procedure DeleteWholeDir(dir_name: string);
begin
  foreach var ud in System.IO.Directory.EnumerateDirectories(dir_name) do
    DeleteWholeDir(ud);
  foreach var f in System.IO.Directory.EnumerateFiles(dir_name) do
    System.IO.File.Delete(f);
  System.IO.Directory.Delete(dir_name);
end;

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
  current_gen_id := StrToInt(System.IO.Directory.EnumerateDirectories(current_dir).Last.Split(' ').Last);
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
  
  while Bot.CurrentBoards = nil do Sleep(10);
  GData.Init;
  var w := Max(10,current_dir.Split('\').Last.Length);
  
  System.Console.SetWindowSize(10+w, 9*Bot.CoresUsed+1);
  System.Console.SetBufferSize(10+w, 9*Bot.CoresUsed+1);
  
  System.Console.SetCursorPosition(10, 2);
  System.Console.Write(current_dir.Split('\').Last);
  
  while true do
  begin
    
    System.Console.BackgroundColor := BackgroundColor1;
    
    
    
    System.Console.SetCursorPosition(10, 0);
    System.Console.Write(' ' * w);
    System.Console.SetCursorPosition(10, 1);
    System.Console.Write(' ' * w);
    System.Console.SetCursorPosition(10, 2);
    System.Console.Write(' ' * w);
    
    
    
    System.Console.SetCursorPosition(10, 0);
    System.Console.Write(string.Format('{0,6:N2}%',Bot.tgc/Bot.mtg*100));
    
    System.Console.SetCursorPosition(10, 1);
    System.Console.Write(current_dir.Split('\').Last);
    
    System.Console.SetCursorPosition(10, 2);
    System.Console.Write($'Gen #{current_gen_id}');
    
    
    
    for var i := 0 to Bot.CurrentBoards.Length-1 do
    begin
    
    DrawBoard(Bot.CurrentBoards[i],0,i*9);
    
    if Bot.LastGEs[i] = -2 then continue;
    
    System.Console.SetCursorPosition(10, i*9+8);
    System.Console.Write(' ' * w);
    
    
    
    System.Console.SetCursorPosition(10, i*9+8);
    case Bot.LastGEs[i] of
      -1: System.Console.Write('Black won');
      +0: System.Console.Write('Draw');
      +1: System.Console.Write('White won');
    end;
    
    end;
    
    
    Sleep(100);
  end;
  
  except
    on e:Exception do SaveError(e);
  end;
end.