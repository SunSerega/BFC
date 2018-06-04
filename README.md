# EN:

# about:
My take on bot playing chess. Nothing spectacular, just training myself to train AI.

Btw, it is't final version... like at all.

# how to use:
To launch - download `Training Settings.txt` and one of the `Training.exe`'s (`Non debug` is faster, but if something gone wrong - it's harder to gues what exactly). Then enter value's `Training.exe` would ask and watch. In `Training Settings.txt` you can chose how many processor cores program can use for chess simulations. But then you need to restart. Allso you can change `BotData.Bot` private consts, but then you need to recompile with [PascalABC.Net](http://pascalabc.net/ssyilki-dlya-skachivaniya).

# how it work's:
There is `BotData.Bot.max_bots` bots at the start. Then every bot play 2 times as white and 2 times as black. Every win = +1 score, lose = -1 score. Then they divided into groups, by which first move as white they made. Bot's with not hightest (in group) score die. Then every alive creates mutated copy of itself. Then, while there is less then `BotData.Bot.max_bots` - 2 random bots taken to reproduse (they can be the same bot). Before every tournament bot's are saved. You can close program at any time and then load back last save, evolution will continue from last bot's saving point.

# how move is chosen:
Every bot looks on `BotData.Bot.max_move_search_lvl` move's ahead. Every move asigned a value. If it is a wining move then value is `+infinity`, if losing move then `-infinity`. Else bot uses it's brain on board (after move) to determin how good it is. Then bot choses best move.

-------------------------------------

# RU:

# краткое описание:
Моя версия бота играющего в шахматы. Ничего особенного, просто тренируюсь тренировать ИИ.

Кстати, это не последняя версия... Типо вще.

# как использовать:
Чтоб запустить - скачайте `Training Settings.txt` и один из `Training.exe`-файлов (`Non debug` работает быстрее, но если что то идёт не так - сложнее понять что именно). Далее введите значения, которые `Training.exe` запросит и смотрите. В `Training Settings.txt` вы можете выбрать, сколько ядер процессора программа может использовать для симуляции игр в шахматы. Так же вы можете изменить приватные константы в `BotData.Bot`, но тогда надо будет всё перекомпилировать с [PascalABC.Net](http://pascalabc.net/ssyilki-dlya-skachivaniya).

# как работает:
В начале создаётся `BotData.Bot.max_bots` ботов. Потом, каждый бот играет 2 раза за белых и 2 раза за чёрных. Каждая победа = +1 очков, проигрыш = -1 очков. Потом их разделяют на группы по первому ходу, который они сделали за белых. Боты с не наибольшим числом очков (в группе) умирают. Потом каждый живой создаёт мутировавшую копию себя. Потом, пока ботов меньше `BotData.Bot.max_bots` - 2 рандомных бота выбираются для оплодотворения (это может быть один и тот же бот). Перед каждым Before every турниром боты сохраняются. Вы можете закрыть программу в любой момент, а затем загрузить последнее сохранение, эволюция продолжится с последнего сохранения ботов.

# как выбирается ход:
Каждый бот смотрит на `BotData.Bot.max_move_search_lvl` ходов вперёд. Каждому ходу присваивается значение. Если ход победный то значение `+бесконечность`, если проигрышный to `-бесконечность`. В противном случае бот использует мозг на доске (после хода), чтоб определить на сколько это хорошее положение. И потому бот выбирает лучший ход.
