#!/bin/bash
make clean && make CLFLAGS="-DASRC_UPSAMPLING=250 -DASRC_ORDER=4" || exit 1
if true
then
    xsim  bin/app_example_asrc.xe > s0
fi

tail -48 s0 > s0_

cat s0 > 100ppm
cnt=0
while [ $cnt -lt 200 ]
do
  cat s0_ >> 100ppm
  cnt=$(($cnt + 1))
done

cat 100ppm > 50ppm
cnt=0
while [ $cnt -lt 600 ]
do
  cat s0_ >> 50ppm
  cnt=$(($cnt + 1))
done

cat s0_ > 0ppm
cnt=0
while [ $cnt -lt 208 ]
do
  cat s0_ >> 0ppm
  cnt=$(($cnt + 1))
done
~/fft/FFT\ computations/a.out < 100ppm > energy100ppmdel
~/fft/FFT\ computations/a.out < 50ppm > energy50ppmdel
~/fft/FFT\ computations/a.out < 0ppm > energy0ppm
rm s0_

samples100ppm=`cat 100ppm| wc -l`
samples50ppm=`cat 50ppm|wc -l`
samples0ppm=`cat 0ppm | wc -l`

ppm100ppm=$((1000000/$samples100ppm))
ppm50ppm=$((1000000/$samples50ppm))

base=1kHz-4-250-slow

gnuplot << EOF
set xrange [10:24000]
set yrange [-120:0]
set logscale x
set terminal pdf
set output "${base}.pdf"
plot "energy0ppm" u (\$1*48000/${samples0ppm}):3 w l title "1 kHz sine", "energy50ppmdel" u (\$1*48000/${samples50ppm}):3 w l title "${ppm50ppm} ppm slow", "energy100ppmdel" u (\$1*48000/${samples100ppm}):3 w l title "${ppm100ppm} ppm slow"
set terminal png
set output "${base}.png"
replot
EOF
