import numpy


def read_ini(fname):
    fp = open(fname, 'r')
    lines = fp.readlines()
    fp.close()
    i = 0

    # Read path to OUTPUT folder
    opt = "Path2OUT: "
    buf = lines[i].split(opt, 1)
    out_path = buf[1]
    out_path = out_path.replace('\n', '')
    i = i + 1

    # Read path to IDEA
    opt = "Path2IDEA: "
    buf = lines[i].split(opt, 1)
    idea_path = buf[1]
    idea_path = idea_path.replace('\n', '')
    i = i + 1

    # Read path to IDEA-CMWP
    opt = "Path2CMWP: "
    buf = lines[i].split(opt, 1)
    cmwp_path = buf[1]
    cmwp_path = cmwp_path.replace('\n', '')
    i = i + 1

    # Read root of input files
    opt = "InputFile: "
    buf = lines[i].split(opt, 1)
    filename = buf[1]
    filename = filename.replace('\n', '')
    i = i + 1

    # Read the wavelength
    opt = "Wavelength (nm): "
    buf = lines[i].split(opt, 1)
    wavelength = float(buf[1])
    i = i + 1

    # Read the constrast factor Ch00
    opt = "Ch00: "
    buf = lines[i].split(opt, 1)
    Ch00 = float(buf[1])
    i = i + 1

    # Read the number of peaks
    opt = "Number of peaks: "
    buf = lines[i].split(opt, 1)
    npeaks = int(buf[1])
    i = i + 1

    peaks_hkl = numpy.zeros((npeaks, 4))
    i = i + 1
    for j in range(0, npeaks):
        buf = lines[i + j]
        buf = ' '.join(buf.split())
        buf = buf.split(" ")
        peaks_hkl[j] = map(int, buf[0:4])

    output = (out_path, idea_path, cmwp_path, filename, wavelength, Ch00,
              npeaks, peaks_hkl)
    return output


def calc_H2(h, k, l):
    num = float(h**2 * k**2 + h**2 * l**2 + k**2 * l**2)
    den = float((h**2 + k**2 + l**2)**2)
    return num / den
