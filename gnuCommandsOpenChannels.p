set title "Open channels"
set xlabel "Time (Seconds)"
set ylabel "Amount of open channels"
set ter png size 800,600
set output "gnuPlotOpenChannels.png"
set datafile separator ","
set yrange [0:300]
plot 'OutputOpenChannels.csv' u 2:1 title 'Open channels' w lp lt 7 lc 0
