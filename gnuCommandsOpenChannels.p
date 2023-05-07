set title "Open channels"
set xlabel "time"
set ylabel "Amount of open channels"
set ter png size 800,600
set output "gnuPlotOpenChannels.png"
set yrange [0:1000]
plot 'OutputOpenChannels.csv' w lp lt 7 lc 0
