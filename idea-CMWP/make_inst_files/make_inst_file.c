//./make_int_file.exe lambda theta0 I0 eta H 
#include "pseudo_voigt.h"
#include "array_alloc.h"

int main(int argc, char ** argv)
{
  if(argc != 5)
  {
    printf("Numero incorrecto de argumentos\n");
    printf("Para ejecutar ingrese:\n./make_inst_file lambda theta0 eta H\n");
    exit(1);
  }
  printf("------------------------------------------------------------\n");
  printf("Programa para generar los puntos de los archivos instrumentales como son requeridos por el programa CMWP\n");
  printf("Se supone que el pico se ajusto con una funcion pseudo-voigt\n");
  printf("Para ejecutar ingrese:\n./make_inst_file lambda theta0 eta H\n");
  printf("------------------------------------------------------------\n");
  //tomo los parametros de la linea de commandos
  FILE *fp = fopen(argv[2], "w");
  double lambda = atof(argv[1]);
  double theta0 = atof(argv[2]);
  double eta = atof(argv[3]);
  double H = atof(argv[4]);
  //parametros del programa
  int N = 250;
  double radian = M_PI / 180.;
  double range = 5 * H, step = range / N, K0 = 2 * sin(theta0 * radian) / lambda, K, I_max, theta;
  I_max = pseudo_voigt_n(0., 0., eta, H);
  fprintf(fp, "#Lineas informativas\n#Eliminar los comentarios para usar el CMWP!!!\n");
  fprintf(fp, "#\\Delta K I/I0\n");
  for(theta = theta0 - range; theta < theta0 + range; theta += step)
  {
    K = 2 * sin(theta * radian) / lambda;
    fprintf(fp, "%.5lf %.5lf\n", K - K0, pseudo_voigt_n(theta, theta0, eta, H) / I_max);
  }
  fclose(fp);
  printf("done!");
  return 0;
}
