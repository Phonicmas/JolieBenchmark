set title "Completion Time"
set xlabel "Invocation number"
set ylabel "Time (Miliseconds)"
set ter png size 800,600
set output "gnuPlotCompletionTime.png"
set yrange [0:1000]
plot 'OutputCompletionTime.csv' w lp lt 7 lc 0 u 2:1
