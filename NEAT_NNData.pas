unit NEAT_NNData;

interface
  
uses BoardData, NNData;

type
  NEAT_Node = record
    
    public id:single;
    
    public c:real;
    public cns:array of real;
    
    public function ToString:string; override := $'NEAT_Node(id = {id}, c = {c}, cns.Length = {cns.Length})';
    
  end;
  
  NEAT_NN = sealed class(NN)
    
    public nds:array of NEAT_Node;
    
    public function Calc(input:Board; white:boolean):real; override;
    begin
      
      var nvs:=new real[inputsC+nds.Length];
      GetILFB(input,white).CopyTo(nvs,0);
      
      for var i1 := 0 to nds.Length-1 do
      begin
        var vi := i1 + inputsC;
        nvs[vi] := nds[i1].c;
        for var i2 := 0 to nds[i1].cns.Length-1 do
          nvs[vi] += nds[i1].cns[i2]*nvs[i2];
        //nvs[vi] := Sigmoid(nvs[vi]);
      end;
      
      Result := nvs[nvs.Length-1];
      
    end;
    
    public function Mutate: NN; override;
    begin
      var res := new NEAT_NN(false);
      
      var nc := self.nds.Length;
      var cr_nodes:IEnumerator<single>;
      begin
        var l := new List<single>;
        while Random(2) <> 0 do l.Add(Random);
        nc += l.Count;
        l.Sort;
        cr_nodes := l.GetEnumerator;
      end;
      var licn := cr_nodes.MoveNext;
      
      var rm_nodes := new HashSet<single>;
      while Random(2) <> 0 do rm_nodes.Add(nds[Random(nds.Length)].id);
      rm_nodes.Remove(2);
      nc -= rm_nodes.Count;
      
      res.nds := new NEAT_Node[nc];
      var shift_table := new integer[nc];
      
      var shift := 0;
      
      for var i1 := 0 to nc - 1 do
      begin
        
        while (rm_nodes.Count <> 0) and rm_nodes.Remove(self.nds[i1+shift].id) do
          shift += 1;
        
        if licn and (single(cr_nodes.Current) < self.nds[i1+shift].id) then
        begin
          
          shift -= 1;
          
          res.nds[i1].c := Random*2-1;
          res.nds[i1].id := cr_nodes.Current;
          res.nds[i1].cns := new real[inputsC+i1];
          for var i2 := 0 to res.nds[i1].cns.Length-1 do
            res.nds[i1].cns[i2] := Random*2-1;
          
          licn := cr_nodes.MoveNext;
          
          shift_table[i1] := integer.MinValue;
          
        end else
        begin
          
          res.nds[i1].c := self.nds[i1+shift].c + Random*0.2-0.1;
          res.nds[i1].id := self.nds[i1+shift].id;
          res.nds[i1].cns := new real[inputsC+i1];
          for var i2 := 0 to inputsC-1 do
            res.nds[i1].cns[i2] := self.nds[i1+shift].cns[i2];
          for var i2 := inputsC to res.nds[i1].cns.Length-1 do
            if shift_table[i2-inputsC] = integer.MinValue then
              res.nds[i1].cns[i2] := Random*2-1 else
              res.nds[i1].cns[i2] := self.nds[i1+shift].cns[i2+shift_table[i2-inputsC]]+Random*0.2+0.1;
          
          shift_table[i1] := shift;
          
        end;
        
      end;
      
      Result := res;
    end;
    
    public function Mutate(_n2:NN): NN; override;
    begin
      var res := new NEAT_NN(false);
      var n2 := _n2 as NEAT_NN;
      
      res := self;//ToDo костыль...
      
      Result := res.Mutate;
    end;
    
    public constructor;
    begin
      
      nds := new NEAT_Node[1];
      nds[0].cns := new real[inputsC];
      for var i1 := 0 to inputsC-1 do
        nds[0].cns[i1] := Random*2-1;
      nds[0].id := 2;
      
    end;
    
    private constructor(b:boolean) := exit;
    
    public constructor(br:System.IO.BinaryReader);
    begin
      
      nds := new NEAT_Node[br.ReadInt32];
      for var i1 := 0 to nds.Length-1 do
      begin
        nds[i1].id := br.ReadSingle;
        nds[i1].c := br.ReadDouble;
        nds[i1].cns := new real[inputsC+i1];
        for var i2 := 0 to nds[i1].cns.Length-1 do
          nds[i1].cns[i2] := br.ReadDouble;
      end;
      
    end;
    
    public procedure Save(bw:System.IO.BinaryWriter); override;
    begin
      
      bw.Write(word(2));//version
      
      bw.Write(integer(nds.Length));
      for var i1 := 0 to nds.Length-1 do
      begin
        bw.Write(single(nds[i1].id));
        bw.Write(real(nds[i1].c));
        for var i2 := 0 to nds[i1].cns.Length-1 do
          bw.Write(real(nds[i1].cns[i2]));
      end;
      
    end;
    
    public function ToString:string; override := 'NEAT_NN('+nds.Length.ToString+':'+#10+#9+nds.JoinIntoString(#10+#9)+#10+')';
    
  end;

implementation

begin

end.