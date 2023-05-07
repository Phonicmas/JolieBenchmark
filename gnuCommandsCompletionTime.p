set title "Completion Time"
set xlabel "time"
set ylabel "invocation"
set ter png size 800,600
set output "gnuPlotCompletionTime.png"
set yrange [0:100]
plot 'OutputCompletionTime.csv' w lp lt 7 lc 0
