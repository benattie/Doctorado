#include <stdlib.h>
#include <stdio.h>

void read_file(FILE * fit_fp, double * H_ini, double * eta_ini,
                double * I0_ini, double * t0_ini, double * shift_H_ini, double * shift_eta_ini, double * bg_int_ini)
{
    char buf[500];
    while(fgets(buf, 500, fit_fp) != NULL)
    {
        printf("%s\n", buf);
    }
}

int main()
{
    FILE * fit_fp;
    double a, b, c, d, e, f, g;
    fit_fp = fopen("fit_data.tmp", "r");
    read_file(fit_fp, &a, &b, &c, &d, &e, &f, &g);
    return 0;
}
