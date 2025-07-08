close all
x = histfit(a.FixCount(a.GazeBlock == 1),20,'negative binomial');
delete(x(1))
x(2).Color = [.61 .77 .61];
hold on
y = histfit(a.FixCount(a.GazeBlock == 2),20,'negative binomial');
delete(y(1))
y(2).Color = [.12 .47 .12];
set(gcf,'Color','white')
box off
yticks([])


figure
x = histfit(round(a.MeanFixDur(a.GazeBlock == 1)),20,'negative binomial');
delete(x(1))
x(2).Color = [.77 .77 .77];
hold on
y = histfit(round(a.MeanFixDur(a.GazeBlock == 2)),20,'negative binomial');
delete(y(1))
y(2).Color = [.12 .47 .12];
set(gcf,'Color','white')
box off
