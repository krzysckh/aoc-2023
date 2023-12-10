set terminal png size 1920,1080 enhanced font "monospace,15"
set output "p2.png"

plot 'poly.dat' using 1:2 with lines title "pipes", \
     'gnd.dat' using 1:2 with points title "gnd"
