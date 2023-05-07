set title "Memory usage"
set xlabel "time"
set ylabel "Memory usage"
set ter png size 800,600
set output "gnuPlotMemory.png"
set datafile separator ","
set yrange [0:100000000]
plot 'OutputMemory.csv' u 1 title 'JavaMem' w lp lt 7 lc 0, 'OutputMemory.csv' u 2 title 'ActualMem' w lp lt 7 lc 3
