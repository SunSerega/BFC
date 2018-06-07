unit BotData;

interface

uses BoardData, NNData;
uses SNNData, NEAT_NNData;

type
  Bot = sealed class
    
    private const max_bots = 20*(1+1+3);//=100; 20 first possible moves * (best bot + mutated best bot + 3*child of 2 random bots)
    private const max_move_search_lvl = 3;
    
    //private const max_bots = 1;
    //private const max_move_search_lvl = 2;
    
    public class bots := new List<Bot>(20*(1+1+3));
    
    public class CurrentBoards: array of Board;
    public class LastGEs:array of integer;
    public class mtg := 1;
    public class tgc := 0;
    public class best_of_gen:=new List<Bot>;
    
    public class CoresUsed := 1;
    
    public brain:NN;
    
    public last_score:integer;
    public fmhc:integer;
    
    public constructor(t:word);
    begin
      bots.Add(self);
      case t of
        1: brain := new SNN;
        2: brain := new NEAT_NN;
        else raise new UnsupportedNNVesionException(t);
      end;
    end;
    
    public constructor(fname:string);
    begin
      bots.Add(self);
      var br := new System.IO.BinaryReader(System.IO.File.OpenRead(fname));
      brain := NN.Load(br.ReadUInt16,br);
      br.BaseStream.Close;
    end;
    
    public constructor(b1:Bot);
    begin
      bots.Add(self);
      brain := b1.brain.Mutate;
    end;
    
    public constructor(b1,b2:Bot);
    begin
      bots.Add(self);
      brain := b1.brain.Mutate(b2.brain);
    end;
    
    
    public procedure Save(fname:string);
    begin
      var bw := new System.IO.BinaryWriter(System.IO.File.Create(fname));
      brain.Save(bw);
      bw.Flush;
      bw.Close;
    end;
    
    public function AssignValue(b:Board; m:Move; white:boolean; lvl:integer := 1):real;
    begin
      try
        m.UseOn(b, true);
      except
        on e: BoardData.MateGE do begin Result := (e.white_win=white)?real.PositiveInfinity:real.NegativeInfinity; exit end;
        on BoardData.DrawGE do begin Result := real.NaN; exit end;
      end;
      if lvl = max_move_search_lvl then
        Result := brain.Calc(b,white) else
      if lvl mod 2 = 1 then
      begin
        
        var best_score:=real.NegativeInfinity;
        foreach var nm in b.GetAllMoves do
        begin
          
          var score := AssignValue(b.Copy,nm, white,lvl+1);
          if real.IsInfinity(score) then//может быть только +бесконечность, потому что наш ход
          begin
            Result := real.PositiveInfinity;
            exit;
          end;
          
          if score > best_score then
            best_score := score;
          
        end;
        
        Result := best_score;
        
      end else
      begin
        
        var best_score:=real.PositiveInfinity;
        foreach var nm in b.GetAllMoves do
        begin
          
          var score := AssignValue(b.Copy,nm, white,lvl+1);
          if real.IsInfinity(score) then//может быть только -бесконечность, потому что ход противника
          begin
            Result := real.NegativeInfinity;
            exit;
          end;
          
          if score < best_score then
            best_score := score;
          
        end;
        
        Result := best_score;
        
      end;
    end;
    
    public function DecideMove(b:Board; white:boolean): Move;
    begin
      var best_score := real.NegativeInfinity;
      var best_move:Move;
      
      var e := b.GetAllMoves.GetEnumerator;
      e.MoveNext;
      best_move := e.Current;
      best_score := AssignValue(b.Copy,best_move, white);
      if real.IsPositiveInfinity(best_score) then
      begin
        Result := best_move;
        exit;
      end;
      
      while e.MoveNext do
      begin
        var move := e.Current;
        var score := AssignValue(b.Copy,move, white);
        if real.IsPositiveInfinity(score) then
        begin
          Result := move;
          exit;
        end;
        if score > best_score then
        begin
          best_move := move;
          best_score := score;
        end;
      end;
      
      Result := best_move;
    end;
    
    public class function PlayOneGame(b1,b2:Bot; game_id:integer):integer;
    begin
      var b := Board.GetStartBoard;
      CurrentBoards[game_id] := b;
      
      try
        var llm1,llm2,lm1,lm2,m1,m2:Move;
        m1 := b1.DecideMove(b,true);
        b1.fmhc := m1.getHashCode;
        m1.UseOn(b,true);
        b2.DecideMove(b,false).UseOn(b,true);
      loop 500 div 2-2 do
      begin
        
        m1 := b1.DecideMove(b,true);
        m1.UseOn(b,true);
        m2 := b2.DecideMove(b,false);
        m2.UseOn(b,true);
        
        if m1.IsSameSM(llm1) and m2.IsSameSM(llm2) then
        begin
          Result := 0;
          exit;
        end;
        
        llm1 := lm1;
        llm2 := lm2;
        lm1 := m1;
        lm2 := m2;
        
      end;
      except
        on e: BoardData.MateGE do begin Result := e.white_win?1:-1; exit end;
        on BoardData.DrawGE do begin Result := 0; exit end;
      end;
      Result := 0;
    end;
    
    public class procedure Tournament;
    begin
      tgc := 0;
      mtg := bots.Count*2;
      var cu := CoresUsed;
      LastGEs := ArrFill(cu,-2);
      CurrentBoards:=ArrFill(cu,Board.GetStartBoard);
      
      var tpaw := new Dictionary<Bot,byte>;
      var tpab := new Dictionary<Bot,byte>;
      foreach var b in bots do
      begin
        b.last_score := 0;
        tpaw.Add(b,2);
        tpab.Add(b,2);
      end;
      
      var game_proc := PlayOneGame;
      var multi_game_proc:integer->() := game_id->while true do
      begin
        
        var b1,b2:Bot;
        lock tpaw do
        begin
          if tpaw.Count = 0 then exit;
          b1 := tpaw.ElementAt(Random(tpaw.Count)).Key;
          b2 := tpab.ElementAt(Random(tpab.Count)).Key;
          
          tpaw[b1] -= 1;
          if tpaw[b1] = 0 then
            tpaw.Remove(b1);
          
          tpab[b2] -= 1;
          if tpab[b2] = 0 then
            tpab.Remove(b2);
        end;
        
        var score := game_proc(b1,b2, game_id);
        Bot.LastGEs[game_id] := score;
        b1.last_score += score;
        b2.last_score -= score;
        Bot.tgc += 1;
        
      end;
      
      var extra_threads := new List<System.Threading.Thread>(cu);
      for var id := 0 to cu-1 do
      begin
        var thr:System.Threading.Thread;
        var nid := id;
        thr := new System.Threading.Thread(()->try
          
          multi_game_proc(nid);
          extra_threads.Remove(thr);
          
        except
          on e:Exception do SaveError(e);
        end);
        extra_threads.Add(thr);
        thr.Start;
      end;
      
      while extra_threads.Count > 0 do
        Sleep(100);
      
    end;
    
    public class procedure Init(nn_t:word);
    begin
      
      loop max_bots do new Bot(nn_t);
      
    end;
    
    public class procedure InitFrom(dir:string);
    begin
      
      foreach var bfn in System.IO.Directory.EnumerateFiles(dir+'\Bots') do
        new Bot(bfn);
      
    end;
    
    public class procedure LoadFrom(dir:string);
    begin
      
      foreach var bfn in System.IO.Directory.EnumerateFiles(dir+'\Best Bots') do
        new Bot(bfn);
      
    end;
    
    public class procedure NextGen;
    begin
      
      Tournament;
      
      best_of_gen.Clear;
      var bog_score := integer.MinValue;
      var nbots := new List<bot>(max_bots);
      
      foreach var kvp in bots.ToLookup(b->b.fmhc) do
      begin
        var max_score := kvp.First.last_score;
        foreach var b:Bot in kvp do
          if b.last_score > max_score then
            max_score := b.last_score;
        var c := 0;
        var at_bog:boolean;
        if max_score > bog_score then
        begin
          best_of_gen.Clear;
          at_bog := true;
        end else
        if max_score = bog_score then
          at_bog := true;
        foreach var b:Bot in kvp do
          if b.last_score = max_score then
          begin
            c += 1;
            if c < 3 then
            begin
              nbots.Add(b);
              nbots.Add(new Bot(b));
            end;
            if at_bog then
              best_of_gen.Add(b);
          end;
      end;
      
      bots := nbots;
      loop max_bots - bots.Count do
        new Bot(
          bots[Random(bots.Count)],
          bots[Random(bots.Count)]
        );
      
    end;
    
  end;

implementation

end. 