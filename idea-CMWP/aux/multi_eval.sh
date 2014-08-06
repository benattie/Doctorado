#!/bin/bash


a=0.2
b=0.9
c=0.5
d=70
e=0.001
epsilon=1.00
st_pr=4.0
for i in $1; do
    for a in 0.8 1.6 2.4; do
        for b in 3.8 4.2 4.4; do
            for c in 0.3 0.6; do
                for d in 100 500 1000; do
                    for e in 0.1 1 2; do
                        #cub
                        echo -e "a_fixed=n\nb_fixed=n\nc_fixed=y\nd_fixed=n\ne_fixed=y\nepsilon_fixed=y\n \
                        init_a=$a\ninit_b=$b\ninit_c=$c\ninit_d="$d"\ninit_e="$e"\ninit_epsilon=$epsilon\n \
                        a_scale=1.0 \nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0">$i.fit.ini
                        ./evaluate $i auto
                        # killall gnuplot_x11
                    done
                done
            done
        done
    done
done
