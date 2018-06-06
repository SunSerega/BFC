uses BotData, BoardData, NEAT_NNData;

begin
  var cb := new Bot(2);
  while true do
  begin
    cb := new Bot(cb);
    Bot.bots.Clear;
    writeln(cb.brain.Calc(Board.GetStartBoard,Random(2)<>0));
    writeln(cb.brain);
    writeln;
  end;
end.