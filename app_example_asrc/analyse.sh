#!/bin/bash

if true
then

for i in 0 1 2 3 4 
do

case $i in
0)
  ASRC_UPSAMPLING=256
  ASRC_ORDER=4;;
1)
  ASRC_UPSAMPLING=128
  ASRC_ORDER=4;;
2)
  ASRC_UPSAMPLING=128
  ASRC_ORDER=8;;
3)
  ASRC_UPSAMPLING=64
  ASRC_ORDER=8;;
4)
  ASRC_UPSAMPLING=64
  ASRC_ORDER=16;;
esac

echo "-DASRC_UPSAMPLING=$ASRC_UPSAMPLING -DASRC_ORDER=$ASRC_ORDER"

make clean
make CLFLAGS="-DASRC_UPSAMPLING=$ASRC_UPSAMPLING -DASRC_ORDER=$ASRC_ORDER" || exit 1
if true
then
    xsim  bin/app_example_asrc.xe > s0
fi

tail -48 s0 > s0_

#less s0_
#less s0

cat s0 > 100ppm
cnt=0
while [ $cnt -lt 200 ]
do
  cat s0_ >> 100ppm
  cnt=$(($cnt + 1))
done

cat s0_ > 0ppm
cnt=0
while [ $cnt -lt 208 ]
do
  cat s0_ >> 0ppm
  cnt=$(($cnt + 1))
done

samples100ppm=`cat 100ppm| wc -l`
samples0ppm=`cat 0ppm | wc -l`


~/fft/FFT\ computations/a.out < 100ppm | awk '{print $1 * 48000/'"${samples100ppm}"', $2, $3;}' > energy100ppmdel$i
~/fft/FFT\ computations/a.out < 0ppm   | awk '{print $1 * 48000/'"${samples0ppm}"', $2, $3;}'    > energy0ppm$i

rm s0_
rm 100ppm 0ppm

done
fi

base=100ppm

gnuplot << EOF
set xrange [10:24000]
set yrange [-120:0]
set logscale x
set terminal pdf
set output "${base}-1K.pdf"
plot "energy0ppm0" u 1:3 w l title "1 kHz sine", "energy100ppmdel1" u 1:3 w l title "100 ppm off order 4,128",  "energy100ppmdel3" u 1:3 w l title "100 ppm off order 8,64"
set terminal png
set output "${base}-1K.png"
replot
set terminal pdf
set output "${base}-2K.pdf"
plot "energy0ppm0" u 1:3 w l title "1 kHz sine", "energy100ppmdel0" u 1:3 w l title "100 ppm off order 4,256", "energy100ppmdel2" u 1:3 w l title "100 ppm off order 8,128", "energy100ppmdel4" u 1:3 w l title "100 ppm off order 16,64"
set terminal png
set output "${base}-2K.png"
replot
EOF

