unit BotData;

interface

uses BoardData;

type
  NN = sealed class
    
    private class function Sigmoid(x: real) := 1 / (1 + Exp(-x));
    
    public const inputsC =
      64*2+//eash cell * (color + value)
      0;
    
    public const l2C = inputsC;
    public const l3C = inputsC div 2;
    
    private const TotalConnections =
      inputsC*l2C+
      l2C*l3C+
      l3C*1;
    
    private const TotalConsts =
      l2C+
      l3C;
    
    private const TotalValues = TotalConnections+TotalConsts;
    
    
    public input_to_l2:array of array of real;
    public l2Consts:array of real;
    
    public l2_to_l3:array of array of real;
    public l3Consts:array of real;
    
    public l3_to_output:array of real;
    
    
    public function Calc(input:Board):real;
    begin
      
      var cl := new real[inputsC];
      for var x := 0 to 7 do
      for var y := 0 to 7 do
      begin
        var pt:integer;
        cl[(x+y*8)*2+0] := (System.Math.DivRem(input.cls[x,y],6,pt) = integer(input.white_move))?-1:1;
        cl[(x+y*8)*2+1] := pt;
      end;
      var nl := Copy(l2Consts);
      
      for var i1 := 0 to l2C-1 do
        for var i2 := 0 to inputsC-1 do
          nl[i1] += input_to_l2[i1][i2]*cl[i2];
      
      cl := nl;
      nl := Copy(l3Consts);
      
      for var i1 := 0 to l3C-1 do
        for var i2 := 0 to l2C-1 do
          nl[i1] += l2_to_l3[i1][i2]*cl[i2];
      
      for var i2 := 0 to l3C-1 do
        Result += l3_to_output[i2]*nl[i2];
      
    end;
    
    public procedure Save(bw:System.IO.BinaryWriter);
    begin
      
      bw.Write(word($0001));//version
      
      for var i1 := 0 to l2C-1 do
        for var i2 := 0 to inputsC-1 do
          bw.Write(input_to_l2[i1][i2]);
      
      for var i1 := 0 to l3C-1 do
        for var i2 := 0 to l2C-1 do
          bw.Write(l2_to_l3[i1][i2]);
      
      for var i2 := 0 to l3C-1 do
        bw.Write(l3_to_output[i2]);
      
      
      for var i1 := 0 to l2C-1 do
        bw.Write(l2Consts[i1]);
      
      for var i1 := 0 to l3C-1 do
        bw.Write(l3Consts[i1]);
      
    end;
    
    
    public constructor;
    begin
      
      SetLength(input_to_l2,l2C);
      for var i1 := 0 to l2C-1 do
      begin
        input_to_l2[i1] := new real[inputsC];
        for var i2 := 0 to inputsC-1 do
          input_to_l2[i1][i2] := Random*2-1;
      end;
      
      SetLength(l2_to_l3,l3C);
      for var i1 := 0 to l3C-1 do
      begin
        l2_to_l3[i1] := new real[l2C];
        for var i2 := 0 to l2C-1 do
          l2_to_l3[i1][i2] := Random*2-1;
      end;
      
      l3_to_output := new real[l3C];
      for var i2 := 0 to l3C-1 do
        l3_to_output[i2] := Random*2-1;
      
      
      l2Consts := new real[l2C];
      for var i1 := 0 to l2C-1 do
        l2Consts[i1] := Random*2-1;
      
      l3Consts := new real[l2C];
      for var i1 := 0 to l3C-1 do
        l3Consts[i1] := Random*2-1;
      
    end;
    
    public constructor(br:System.IO.BinaryReader);
    begin
      
      if br.ReadUInt16<>$0001 then raise new System.Exception('в данной версии BotData не поддреживаются нейронные сети с версией не равной $0001');//version
      
      SetLength(input_to_l2,l2C);
      for var i1 := 0 to l2C-1 do
      begin
        input_to_l2[i1] := new real[inputsC];
        for var i2 := 0 to inputsC-1 do
          input_to_l2[i1][i2] := br.ReadDouble;
      end;
      
      SetLength(l2_to_l3,l3C);
      for var i1 := 0 to l3C-1 do
      begin
        l2_to_l3[i1] := new real[l2C];
        for var i2 := 0 to l2C-1 do
          l2_to_l3[i1][i2] := br.ReadDouble;
      end;
      
      l3_to_output := new real[l3C];
      for var i2 := 0 to l3C-1 do
        l3_to_output[i2] := br.ReadDouble;
      
      
      l2Consts := new real[l2C];
      for var i1 := 0 to l2C-1 do
        l2Consts[i1] := br.ReadDouble;
      
      l3Consts := new real[l2C];
      for var i1 := 0 to l3C-1 do
        l3Consts[i1] := br.ReadDouble;
      
    end;
    
    public constructor(n1:NN);
    begin
      
      SetLength(input_to_l2,l2C);
      for var i1 := 0 to l2C-1 do
      begin
        input_to_l2[i1] := new real[inputsC];
        for var i2 := 0 to inputsC-1 do
          input_to_l2[i1][i2] := n1.input_to_l2[i1][i2] + Random*0.2-0.1;
      end;
      
      SetLength(l2_to_l3,l3C);
      for var i1 := 0 to l3C-1 do
      begin
        l2_to_l3[i1] := new real[l2C];
        for var i2 := 0 to l2C-1 do
          l2_to_l3[i1][i2] := n1.l2_to_l3[i1][i2] + Random*0.2-0.1;
      end;
      
      l3_to_output := new real[l3C];
      for var i2 := 0 to l3C-1 do
        l3_to_output[i2] := n1.l3_to_output[i2] + Random*0.2-0.1;
      
      
      l2Consts := new real[l2C];
      for var i1 := 0 to l2C-1 do
        l2Consts[i1] := n1.l2Consts[i1] + Random*0.2-0.1;
      
      l3Consts := new real[l2C];
      for var i1 := 0 to l3C-1 do
        l3Consts[i1] := n1.l3Consts[i1] + Random*0.2-0.1;
      
    end;
    
    public constructor(n1,n2:NN);
    begin
      
      SetLength(input_to_l2,l2C);
      for var i1 := 0 to l2C-1 do
      begin
        input_to_l2[i1] := new real[inputsC];
        for var i2 := 0 to inputsC-1 do
          input_to_l2[i1][i2] := (n1.input_to_l2[i1][i2]+n2.input_to_l2[i1][i2])/2 + Random*0.2-0.1;
      end;
      
      SetLength(l2_to_l3,l3C);
      for var i1 := 0 to l3C-1 do
      begin
        l2_to_l3[i1] := new real[l2C];
        for var i2 := 0 to l2C-1 do
          l2_to_l3[i1][i2] := (n1.l2_to_l3[i1][i2]+n2.l2_to_l3[i1][i2])/2 + Random*0.2-0.1;
      end;
      
      l3_to_output := new real[l3C];
      for var i2 := 0 to l3C-1 do
        l3_to_output[i2] := (n1.l3_to_output[i2]+n2.l3_to_output[i2])/2 + Random*0.2-0.1;
      
      
      l2Consts := new real[l2C];
      for var i1 := 0 to l2C-1 do
        l2Consts[i1] := (n1.l2Consts[i1]+n2.l2Consts[i1])/2 + Random*0.2-0.1;
      
      l3Consts := new real[l2C];
      for var i1 := 0 to l3C-1 do
        l3Consts[i1] := (n1.l3Consts[i1]+n2.l3Consts[i1])/2 + Random*0.2-0.1;
      
    end;
    
  end;
  Bot = sealed class
    
    private const max_bots = 20*(1+1+3);//=100; 20 first possible moves * (best bot + mutated best bot + 3*child of 2 random bots)
    private const max_move_search_lvl = 3;
    //private const max_bots = 1;
    
    public class bots := new List<Bot>(20*(1+1+3));
    
    public class CurrentBoards: array of Board;
    public class LastGEs:array of integer;
    public class mtg := 1;
    public class tgc := 0;
    
    public class CoresUsed := 1;
    
    public brain:NN;
    
    public last_score:integer;
    public fmhc:integer;
    
    private constructor;
    begin
      bots.Add(self);
      brain := new NN;
    end;
    
    private constructor(fname:string);
    begin
      bots.Add(self);
      var br := new System.IO.BinaryReader(System.IO.File.OpenRead(fname));
      brain := new NN(br);
      br.Close;
    end;
    
    private constructor(b1:Bot);
    begin
      bots.Add(self);
      brain := new NN(b1.brain);
    end;
    
    private constructor(b1,b2:Bot);
    begin
      bots.Add(self);
      brain := new NN(b1.brain,b2.brain);
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
        Result := brain.Calc(b) else
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
    
    public class procedure Init;
    begin
      
      loop max_bots do new Bot;
      
    end;
    
    public class procedure InitFrom(dir:string);
    begin
      
      foreach var bfn in System.IO.Directory.EnumerateFiles(dir+'\Bots') do
        new Bot(bfn);
      
    end;
    
    public class procedure NextGen;
    begin
      
      Tournament;
      
      var nbots := new List<bot>(max_bots);
      
      foreach var kvp in bots.ToLookup(b->b.fmhc) do
      begin
        var max_score := kvp.First.last_score;
        foreach var b:Bot in kvp do
          if b.last_score > max_score then
            max_score := b.last_score;
        var c := 0;
        foreach var b:Bot in kvp do
          if b.last_score = max_score then
          begin
            c += 1;
            nbots.Add(b);
            nbots.Add(new Bot(b));
            if c = 2 then break;
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