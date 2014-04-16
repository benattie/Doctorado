#include "pseudo_voigt.h"
#include "array_alloc.h"
int main()
{
    IRF ins;
    ins.U = 0.0;
    ins.V = 0.0;
    ins.W = 0.002;
    ins.IG = 0.0;
    ins.X = 0.0;
    ins.Y = 0.0;
    ins.Z = 0.000;
    double * H = vector_double_alloc(1);
    double * eta = vector_double_alloc(1);
    *H = 0.020;
    *eta = 0.40;
    double theta = 1.41;
    ins_correction(H, eta, ins, theta);
    return 0;
}
