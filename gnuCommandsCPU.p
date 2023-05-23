set title "CPU usage"
set xlabel "Time (Seconds)"
set ylabel "CPU usage (Percent)"
set ter png size 1920,1080
set output "gnuPlotCPU.png"
set datafile separator ","
set yrange [0:100]
plot 'OutputCPU.csv' u 3:1 title 'CPU system load' w lp lt 7 lc 0, 'OutputCPU.csv' u 3:2 title 'CPU JVM load' w lp lt 7 lc 3
