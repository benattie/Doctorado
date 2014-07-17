from math import pi, sin, cos, acos
# definicion de FUNCIONES


def winkel_al(th, om, ga):
    rad = pi / 180
    chi = 0.0
    phi = 0.0

    omr = om * rad
    gar = ga * rad
    thr = th * rad
    phir = phi * rad
    chir = chi * rad

    # the multiplication of matrix G and s

    COSAL = (((-1*cos(omr)*sin(phir)) - (sin(omr)*cos(phir)*cos(chir)))*(-1*sin(thr))) + ((-1*sin(omr)*sin(phir)) + (cos(omr)*cos(phir)*cos(chir))) * (cos(thr)*cos(gar))

    al = (acos(COSAL))/rad

    return (al)


def winkel_be(thb, omb, gab, alb):
    rad_be = pi / 180
    chi_be = 0.0
    phi_be = 0.0

    thbr = thb * rad_be
    ombr = omb * rad_be
    gabr = gab * rad_be
    albr = alb * rad_be
    chibr = chi_be * rad_be
    phibr = phi_be * rad_be

    # the multiplication of matrix G and s

    SINALCOSBE = (cos(ombr) * (-1 * sin(thbr))) + (((sin(ombr) * cos(phibr)) +
                                                    (cos(ombr) * sin(phibr) *
                                                     cos(chibr))) *
                                                   (cos(thbr) * cos(gabr)))
    COSBE = SINALCOSBE / sin(albr)
    SINALSINBE = cos(thbr) * sin(gabr)
    SINBE = SINALSINBE / sin(albr)

    if (COSBE > 1.0):
        be = 0.0
        COSBE = 1
    if (COSBE < -1):
        be = 180.0
        COSBE = -1

    if (SINBE < 0):
        be = 360.0 - (acos(COSBE) / rad_be)
    else:
        be = acos(COSBE) / rad_be

    if ((omb == 0) & (be > 270.0)):
        be = 360 - be

    if ((omb == 0) & (be <= 80.0)):
        be = 360 - be

    return (be)
