double H2(int * hkl)
{
    double h2 = pow(hkl[0], 2), k2 = pow(hkl[1], 2), l2 = pow(hkl[2], 2);
    double num = h2 * k2 + h2 * l2 + k2 * l2;
    double den = pow((h2 + k2 + l2), 2);
    return num / den;
}

double burgers(double a, int * hkl)
{
    return a * sqrt((pow(hkl[0], 2.) + pow(hkl[1], 2.) + pow(hkl[2], 2.)) / 2.;
}

double Chkl(double Ch00, double q, int * hkl)
{
    return Ch00 * (1 - q * H2(hkl));
}

int main()
{
    //variables del programa
    FILE *fp_out;
    int i, j, k, nlines;
    double degree = 180. / M_PI, radian = M_PI / 360., 
    double delta, delta_min, delta_max, delta_step;
    double q, q_min, q_max, q_step,
    double Ch00, Ch00_min, Ch00_max, Ch00_step;
    double m, h, cov[2][2], chisq, chisq_min = 100, R, R_max = 0;
    double best_R_val[4], best_chisq_val[4];

    //datos de la estructura cristalina
    char name[] = "FCC";
    int npeaks = 7, index[9][3] = {{1, 1, 1}, {2, 0, 0}, {2, 2, 0}, {3, 1, 1}, {2, 2, 2}, {4, 0, 0}, {3, 3, 1}, {4, 2, 0}, {4, 2, 2}};
    double a = 1., b = burgers(a, 1, 1, 0); //parametro de red y magnitud del vector de burgers
    double vH2[9], vWC[9] = {sqrt(3) / 4., 1., sqrt(2) / 2., (3 * sqrt(11)) / 22., sqrt(3) / 4., 1.0, 0.0, 0.0, 0.0};
    for (i = 0; i < 9; i++)
        vH2[i] = H2(index[i]);
    crystal_data fcc = {name, a, b, index, vH2, vWC};

    //datos del difractograma
    double theta[npeaks] = {1.742, 2.013, 2.850, 3.342, 3.489, 4.025, 4.391}, x[npeaks], y[npeaks];
    double FWHM[npeaks];//cargo los fwhm (deberia restar el ancho instrumental)
    double FWHM_err[npeaks];//cargo los errores de los fwhm (deberia restar el ancho instrumental)
    double breadth[npeaks];//cargo los breatdh (idem anterrior)
    for (i = 0; i < npeaks; i++)
        theta[i] = theta[i] * radian; //paso a radianes
    double alpha[nlines], beta[nlines];
    //leo las figuras de polos
/*
    for(i = 0; i < nlines; i++)
    {
        for(j = 0; j < npeaks; j++)
        {
            //leo 
            //n
            //theta[j]
            //theta[j] *= radian; //paso a radianes
            //dostheta
            //alpha[i], beta[i]
            //FWHM[i][j] FWHM_err[i][j]
            //breatdh[i][j], breadth_err[i][j]
        }
    }
*/
    for(j = 0; j < nlines; j++)
    {
        for(delta = delta_min; delta < delta_max; delta += delta_step)
        {
            for(q = q_min; q < q_max; q += q_step)
            {
                for(Ch00 = Ch00_min; Ch00 < Ch00_max; Ch00 += Ch00_step)
                {
                    for (i = 0; i < npeaks; i++)
                    {
                        x[i] = 2. * sin(theta[i]) / lambda * Chkl(Ch00, q, index[i]);
                        y[i] = FWHM[i] * cos(theta[i]) / lambda - delta * vWC[i];
                    }
                    gsl_fit_linear(x, 1, y, 1, npeaks, &h,  &m, &cov[0][0], &cov[0][1], &cov[1][1], &chisq); //fiteo sin peso
                    gsl_fit_wlinear(x, 1, FWHM_err, 1, y, 1, npeaks, &h,  &m, &cov[0][0], &cov[0][1], &cov[1][1], &chisq); //fiteo con peso
                    R = gsl_stats_correlation(x, 1, y, 2, npeaks);
                    if(fabs(R) > R_max && h > 0 && m > 0)
                    {
                        R_max = R;
                        best_R_val[0] = h;
                        best_R_val[1] = m;
                        best_R_val[2] = R;
                        best_R_val[3] = chisq;
                    }
                    if(chisq < chisq_min && h > 0 && m > 0)
                    {
                        chisq_min = chisq;
                        best_chisq_val[0] = h;
                        best_chisq_val[1] = m;
                        best_chisq_val[2] = R;
                        best_chisq_val[3] = chisq;
                    }
                }
            }
        }
        //imprimo los resultados
    }
    return 0;
}

