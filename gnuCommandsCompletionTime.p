set title "Completion Time"
set xlabel "Invocation number"
set ylabel "Time (Miliseconds)"
set ter png size 800,600
set output "gnuPlotCompletionTime.png"
set datafile separator ","
set yrange [0:1000]
plot 'OutputCompletionTime.csv' u 2:1 title 'Completion Time' w lt 7 lc 0
