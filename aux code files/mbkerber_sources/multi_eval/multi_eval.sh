#!/bin/bash
a=0.2
b=0.9
c=0.5
d=70
e=0.001
epsilon=1.09
st_pr=4.0
#hex
a1=1.0
a2=1.0
for i in $1
do
    for a in 1.5 3.5
    do
        # for a2 in 1.7 2.5
        # do
            for b in 1.0 2.5
            do
                for c in 0.7 1.5
                do
                    for d in 50 90
                    do
                        for e in 0.005 0.1
                        do
                            # for epsilon in 1.0 3.0
                            # do
                                #now source a file with fixed data ie sf or eps from an independent run to overload any changed values
                                if [[ -e $i.fit.ini.fix ]];then
                                    source $i.fit.ini.fix
                                fi
                                #hex
                                # echo -e "init_a1=$a1\ninit_a2=$a2\ninit_b=$b\ninit_c=$c\ninit_d="$d"\ninit_e="$e"\ninit_epsilon=$epsilon\nst_pr=$st_pr \
                                # \na1_scale=1.0\na2_scale=1.0\nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0">$i.dat.fit.ini
                                # \na1_fixed=n\na2_fixed=n\nb_fixed=n\nc_fixed=n\nd_fixed=n\ne_fixed=n \
                                #cub
                                echo -e "init_a=$a\ninit_b=$b\ninit_c=$c\ninit_d="$d"\ninit_e="$e"\ninit_epsilon=$epsilon\nst_pr=$st_pr \
                                \na_fixed=n\nepsilon_fixed=y\na_scale=1.0 \nb_scale=1.0\nc_scale=1.0\nd_scale=1.0\ne_scale=1.0">$i.dat.fit.ini
                                ./evaluate $i auto
                                # killall gnuplot_x11
                            # done
                        done
                    done
                done
            done
        # done
    done
done
