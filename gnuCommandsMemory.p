set title "Memory usage"
set xlabel "Time (Seconds)"
set ylabel "Memory usage (Bytes)"
set ter png size 1920,1080
set output "gnuPlotMemory.png"
set datafile separator ","
set yrange [0:100000000]
plot 'OutputMemory.csv' u 3:1 title 'JVM allocated memory' w lp lt 7 lc 0, 'OutputMemory.csv' u 3:2 title 'Physical allocated memory' w lp lt 7 lc 3
