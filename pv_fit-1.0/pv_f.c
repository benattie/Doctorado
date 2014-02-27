//x = vector de parametros
//data = vector de data experimental
//f = vector diferencia

//DEFINICION DE FUNCIONES
float bin2theta(int bin, float pixel, float dist);

struct data {
    size_t n;
    gsl_vector * ttheta;
    gsl_vector * y;
    gsl_vector * sigma;
};

int pv_f (const gsl_vector * x, void *data, gsl_vector * f)
{
    size_t n = ((struct data *)data)->n;
    double *y = ((struct data *)data)->y;
    double *sigma = ((struct data *) data)->sigma;

    size_t i, j = 0;
    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double eta;
    double I0[numrings];
    double t0[numrings];
    double shift_H[numrings];
    double shift_eta[numrings];
    double bg_left[numrings];
    double bg_right[numrings];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j);
    j++;
    eta = gsl_vector_get (x, j);
    j++;
    for(i = 0; i < numrings; i++)
    {
        I0[i] = gsl_vector_get(x, j);   j++;
        t0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j);  j++;        
        shift_eta[i] = gsl_vector_get(x, j);    j++;
        bg_left[i] = gsl_vector_get(x, j);  j++;
        bg_right[i] = gsl_vector_get(x, j); j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++)
    {
      /* Model Yi = A * exp(-lambda * i) + b */
        //double t = bin2theta(i, 100e-6, 1081e-3);
        double Yi = pseudo_voigt(H, eta, 
                I0, t0, shift_H, shift_eta,
                 bg_left, bg_right,
                  gsl_vector_get(ttheta, i)); //tengo que definir la pseudo-voigt (aca la evaluo)

        gsl_vector_set (f, i, (Yi - gsl_vector_get(y, i)) / gsl_vector_get(sigma, i);
    }

    return GSL_SUCCESS;
}

//FUNCIONES
float bin2theta(int bin, float pixel, float dist)
{
    //math.atan(float(bin) * 100e-6 / 1081e-3) * 180. / math.pi
    return math.atan(float(bin) * pixel / dist) * 180. / math.pi
}

