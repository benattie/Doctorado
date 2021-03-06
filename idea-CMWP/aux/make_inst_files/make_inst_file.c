//./make_int_file.exe lambda theta0 I0 eta H 
#include "pseudo_voigt.h"
#include "array_alloc.h"

int main(int argc, char ** argv)
{
  if(argc != 5)
  {
    printf("Numero incorrecto de argumentos\n");
    printf("Para ejecutar ingrese:\n./make_inst_file lambda theta0 H eta\n");
    exit(1);
  }
  printf("------------------------------------------------------------\n");
  printf("Programa para generar los puntos de los archivos instrumentales como son requeridos por el programa CMWP\n");
  printf("Se supone que el pico se ajusto con una funcion pseudo-voigt\n");
  printf("Para ejecutar ingrese:\n./make_inst_file lambda theta0 H eta\n");
  printf("------------------------------------------------------------\n");
  //tomo los parametros de la linea de commandos
  FILE *fp = fopen(argv[2], "w");//el nombre del archivo es la posicion en theta del centro del pico
  double lambda = atof(argv[1]);
  double theta0 = atof(argv[2]);
  double H = atof(argv[3]);
  double eta = atof(argv[4]);
  //parametros del programa
  int N = 100;
  double radian = M_PI / 180.;
  double range = 2 * H, step = range / N, K0 = 2 * sin(theta0 * radian) / lambda;
  double K, I_max, theta;
  I_max = pseudo_voigt_n(0., 0., eta, H);
  printf("Generando archivo instrumental en theta = %s\n", argv[2]);
  fprintf(fp, "#Lineas informativas\n#Eliminar los comentarios para usar el CMWP!!!\n");
  fprintf(fp, "#\\Delta K I/I0\n");
  for(theta = theta0 - range; theta < theta0 + range; theta += step)
  {
    K = 2 * sin(theta * radian) / lambda;
    //fprintf(fp, "%.5lf %.5lf\n", K - K0, pseudo_voigt_n(theta, theta0, eta, H) / I_max);
    
    fprintf(fp, "%.5lf %.5lf\n", K - K0, pseudo_voigt_n(K, K0, eta, H) / I_max);
  }
  fclose(fp);
  printf("done!\n");
  return 0;
}
