#!/bin/bash

for k in c s
do
        
    case $k in
        c)
            F=-DTEST_CONTINUOUS;;
        s)
            F=;;
    esac
    if false
    then
    for i in 0 1 2 3 4 5
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
            5)
                ASRC_UPSAMPLING=256
                ASRC_ORDER=8;;
        esac
        
        make clean
        make CLFLAGS="$F -DASRC_UPSAMPLING=$ASRC_UPSAMPLING -DASRC_ORDER=$ASRC_ORDER" || exit 1
        if true
        then
            xsim  bin/app_example_asrc.xe > s0
        fi

        cp s0 100ppm$i$k

        samples100ppm=`cat s0| wc -l`

        ~/fft/FFT\ computations/a.out < s0 | awk '{print $1 * 48000/'"${samples100ppm}"', $2, $3;}' > energy100ppmdel$i$k

    done
fi

    for i in 0 1 2 3 4 5
    do
        awk '
{
  if ($1 < 20000) {
    if ($2 > max) {
      sum += max*max; max = $2;
    } else {
      sum += $2*$2;
    }
  }
}
END {
  printf "%.2f %%", 100*sqrt(sum)/max
}' < energy100ppmdel$i$k > thd$i$k
    done

    base=100ppm
    thd0=`cat thd0$k`
    thd1=`cat thd1$k`
    thd2=`cat thd2$k`
    thd3=`cat thd3$k`
    thd4=`cat thd4$k`
    thd5=`cat thd5$k`

    gnuplot << EOF
set xrange [10:24000]
set yrange [-120:0]
set logscale x
set terminal pdf
set output "${base}-256-${k}.pdf"
plot -90 w l title "-90 dB", "energy100ppmdel0$k" u 1:3 w l title "order 4 upsample 256, thd ${thd0}",  "energy100ppmdel5$k" u 1:3 w l title "order 8 upsample 256, thd ${thd5}"
set terminal png
set output "${base}-256-${k}.png"
replot
set terminal pdf
set output "${base}-128-${k}.pdf"
plot -90 w l title "-90 dB", "energy100ppmdel1$k" u 1:3 w l title "order 4 upsample 128, thd ${thd1}",  "energy100ppmdel2$k" u 1:3 w l title "order 8 upsample 128, thd ${thd2}"
set terminal png
set output "${base}-128-${k}.png"
replot
set terminal pdf
set output "${base}-64-${k}.pdf"
plot -90 w l title "-90 dB", "energy100ppmdel3$k" u 1:3 w l title "order 8 upsample 64, thd ${thd3}", "energy100ppmdel4$k" u 1:3 w l title "order 16 upsample 64, thd ${thd4}"
set terminal png
set output "${base}-64-${k}.png"
replot
EOF

done