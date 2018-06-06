unit SNNData;

interface

uses BoardData, NNData;

type
  SNN = sealed class(NN)
    
    public const l2C = inputsC;
    public const l3C = inputsC div 2;
    
    
    public input_to_l2:array of array of real;
    public l2Consts:array of real;
    
    public l2_to_l3:array of array of real;
    public l3Consts:array of real;
    
    public l3_to_output:array of real;
    
    
    public function Calc(input:Board; white:boolean):real; override;
    begin
      
      var cl := GetILFB(input,white);
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
    
    public function Mutate: NN; override;
    begin
      var res := new SNN(false);
      
      SetLength(res.input_to_l2,l2C);
      for var i1 := 0 to l2C-1 do
      begin
        res.input_to_l2[i1] := new real[inputsC];
        for var i2 := 0 to inputsC-1 do
          res.input_to_l2[i1][i2] := self.input_to_l2[i1][i2] + Random*0.2-0.1;
      end;
      
      SetLength(res.l2_to_l3,l3C);
      for var i1 := 0 to l3C-1 do
      begin
        res.l2_to_l3[i1] := new real[l2C];
        for var i2 := 0 to l2C-1 do
          res.l2_to_l3[i1][i2] := self.l2_to_l3[i1][i2] + Random*0.2-0.1;
      end;
      
      res.l3_to_output := new real[l3C];
      for var i2 := 0 to l3C-1 do
        res.l3_to_output[i2] := self.l3_to_output[i2] + Random*0.2-0.1;
      
      
      res.l2Consts := new real[l2C];
      for var i1 := 0 to l2C-1 do
        res.l2Consts[i1] := self.l2Consts[i1] + Random*0.2-0.1;
      
      res.l3Consts := new real[l2C];
      for var i1 := 0 to l3C-1 do
        res.l3Consts[i1] := self.l3Consts[i1] + Random*0.2-0.1;
      
      Result := res;
    end;
    
    public function Mutate(n2:NN): NN; override;
    begin
      var res := new SNN(false);
      var _n2 := n2 as SNN;
      
      SetLength(res.input_to_l2,l2C);
      for var i1 := 0 to l2C-1 do
      begin
        res.input_to_l2[i1] := new real[inputsC];
        for var i2 := 0 to inputsC-1 do
          res.input_to_l2[i1][i2] := (self.input_to_l2[i1][i2]+_n2.input_to_l2[i1][i2])/2 + Random*0.2-0.1;
      end;
      
      SetLength(res.l2_to_l3,l3C);
      for var i1 := 0 to l3C-1 do
      begin
        res.l2_to_l3[i1] := new real[l2C];
        for var i2 := 0 to l2C-1 do
          res.l2_to_l3[i1][i2] := (self.l2_to_l3[i1][i2]+_n2.l2_to_l3[i1][i2])/2 + Random*0.2-0.1;
      end;
      
      res.l3_to_output := new real[l3C];
      for var i2 := 0 to l3C-1 do
        res.l3_to_output[i2] := (self.l3_to_output[i2]+_n2.l3_to_output[i2])/2 + Random*0.2-0.1;
      
      
      res.l2Consts := new real[l2C];
      for var i1 := 0 to l2C-1 do
        res.l2Consts[i1] := (self.l2Consts[i1]+_n2.l2Consts[i1])/2 + Random*0.2-0.1;
      
      res.l3Consts := new real[l2C];
      for var i1 := 0 to l3C-1 do
        res.l3Consts[i1] := (self.l3Consts[i1]+_n2.l3Consts[i1])/2 + Random*0.2-0.1;
      
      Result := res;
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
    
    private constructor(b:boolean) := exit;
    
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
    
    public procedure Save(bw:System.IO.BinaryWriter); override;
    begin
      
      bw.Write(word(1));//version
      
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
    
  end;
  
implementation

begin

end.