set title "CPU usage"
set xlabel "time"
set ylabel "CPU usage"
set ter png size 800,600
set output "gnuPlotCPU.png"
set yrange [0:100]
plot 'OutputCPU.csv' w lp lt 7 lc 0
