unit NNData;

interface

uses BoardData;

type
  UnsupportedNNVesionException = class(Exception)
    constructor(t:word) := inherited create('This version of program can''t load NN type #'+t.ToString);
  end;
  
  NN = abstract class
    
    protected class function Sigmoid(x: real) := 2 / (1 + Exp(-x)) - 1;
    
    public const inputsC =
      64*2+//eash cell * (color + value)
      0;
    
    
    protected class function GetILFB(input:Board; white:boolean):array of real;
    begin
      Result := new real[inputsC];
      for var x := 0 to 7 do
      for var y := 0 to 7 do
      begin
        var pt:integer;
        var i := white?(  (x+y*8)*2  ):(  (63-x-y*8)*2  );
        Result[i+0] := (System.Math.DivRem(input.cls[x,y],6,pt) = integer(white))?-1:1;
        Result[i+1] := pt;
      end;
    end;
    
    public function Calc(input:Board; white:boolean):real; abstract;
    
    public function Mutate: NN; abstract;
    
    public function Mutate(n2:NN): NN; abstract;
    
    public class function Load(t:word; br:System.IO.BinaryReader):NN;
    
    public procedure Save(bw:System.IO.BinaryWriter); abstract;
    
  end;

implementation

uses SNNData, NEAT_NNData;

class function NN.Load(t:word; br:System.IO.BinaryReader):NN;
begin
  case t of
  1: Result := new SNN(br);
  2: Result := new NEAT_NN(br);
  else raise new UnsupportedNNVesionException(t);
  end;
end;


end.