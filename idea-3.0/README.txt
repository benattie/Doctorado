Version 3.0 de IDEA al 31-05-2014
Sugerencias y preguntas a benatti@ifir-conicet.gov.ar
Este programa toma los datos de un experimento de transmisión de un sincrotrón en el formato de salida que da el programa FIT2D.
Los parámetros de entrada se especifican en el archivo para_fit2d.dat. El nombre de los archivos de entrada es de la forma nombre_####.extension
Ejemplo:
-----------Inicio de para_fit2d.dat. Esta línea no va en el archivo--------------
-----------Las lineas que empiezan con % son comentarios y tampoco van en el archivo----------
1.PathForOutput     : /ruta/a/los/archivos/de/salida/
%Numero de muestras a estudiar. Por el momento sólo se puede analizar una muestra por vez.
2.NrOfSamples(1)    : 1

Input Data - 1
3.InputFilePath     : /ruta/a/los/archivos/spr/
4.InputFileName     : nombre_
5.FileExtension     : extension
6.IndexNr Start     : #archivo_inicial
7.Start Angle       : angulo que representa archivo_inicial
8.IndexNr End       : #archivo_final
9.End Angle         : angulo que representa archivo_final
10.DeltaIndexNr     : #salto_entre_archivos
11.Delta Angle      : angulo que representa el salto_entre_archivos
12.Start Gamma      : porción inicial del anillo de Debye a estudiar
13.End Gamma        : porción final del anillo de Debye a etudiar
14.Delta Gamma      : ancho de la porcion de anillo que se va a analizar cada vez
15.Distance         : distancia entre la muestra y el detector
16.Pixel value      : distancia/pixel de la placa fotográfica
17.Treshold         : Picos con intensidad_raw < que Treshold se les asigna intensidad nula y no se los ajusta
18.MinusToZero(y/n) : Pasar las intensidad_raw < 0 a 0 
19.LogFileCorrection: n

Peak Positions
I. NrOfPeaks        : Numero de picos a analizar del difractograma
II. Peak Positions
(Theta Peak-L Peak-R BG-L BG-R):
1.742 583 713 400 935
2.013 713 854 500 965
2.850 1025 1130 965 1178
3.342 1215 1298 1190 1450
3.489 1298 1375 1190 1450
4.025 1505 1559 1450 1600
4.391 1650 1685 1620 1700
---------------Fin del para_fit2d.dat. Esta línea tampoco va---------------------------------
Los datos de los picos se ingresan escribiendo la posición del centro (\theta_{bragg}), los píxel en que se considera que inicia y termina el pico y píxel que determinal el nivel de background alrededor de ese pico.
La lectura de datos no es muy robusta, así que se debe respetar al pie de la letra el formato del archivo.
Se acompaña un Makefile con las reglas para compilar el código. Para compilar simplemente hacer:
make spr2txt
Para que el programa corra adecuadamente se requiere la biblioteca científica del proyecto GNU (GSL) en su versión 1.16 o superior.

Una vez ejecutado el programa devuelve un archivo por cada pico ingresado en para_fit2d.dat. En archivo está en columnas separadas por espcios siguendo el siguiente encabezado:
#    2theta theta  alpha  beta     raw_int fit_int  error   H        error   eta      error   B        error   H_corr   error   eta_corr error   B_corr   error

Siendo \alpha y \beta el ángulo polar y azimutal, respectivamente de la figura de polos. raw_int es una intensidad calculada sumando la intensidad de los píxel a izquierda y derecha del pico, restando el respectivo background.
Luego siguen los valores del ajuste de la pseudo-voigt que se ajustó a cada pico:

pV(x, 2\theta, fit_int, H, eta) = fit_int * [eta * L(x, 2\theta, H) + (1 - eta) * G(x, 2\theta, H)]

siendo L y G una función lorentziana y una gaussiana, respectivamente. Todas las funciones están normalizadas de modo que su integral sea 1. Con los valores de H y eta se calcula el ancho integral B del pico, a partir de [referencia]:

equation

El usuario debe proveer además un archvio con las semillas de los parámetros a ser ajustados, entre los que están los parámetros de pV y los puntos de background. Este archivo debe llamarse fit_ini.dat.
Finalmente se debe proveer el archio con los datos de los anchos instrumentales del equipo (IRF.dat). Se acompañan ejemplos de cada archivo.
Del par (H, eta) se obtiene (H_{gauss}, H_{lorentz}) a partir de las expresiones [referencia]:

equations

El ancho instrumental se modela con la ley de Cagliotti, suponiendo una componente gaussiana y una componente lorenzina:
(H_ins)^2 = UG * tg(x)^2 + VG * tg(x) + WG + IG / cos(x)  (Gauss)
H_ins = UL * tg(x)^2 + VL * tg(x) + WL + IL / cos(x)  (Lorentz)

(H_corr)^2 = H^2 - (H_ins)^2 (Gauss)
H_corr = H^2 - H_ins (Lorentz)

Los datos corregidos se utilizan para calcular nuevos valores de H, eta y B empleando las expresiones [referencia]:

equations

Si no se dispone de la información del ancho instrumental del pico se puede colocar 0 en cada uno de los valores de IRF.dat.
---------------------------------------------------------------------------------------------------------------------------------------------
Iformación adicional
El programa acepta un parámetro opcional que es el valor del treshold. Para ingresarlo correr el programa (se supone que se está en la línea de comandos):
./spr2txt.exe treshold (linux)
sprt2txt.exe treshold (windows)

De ingresarse así se sobreescribe lo que se ingresó en el para_fit2d.dat. Esto puede ser útil para determinar cuál es el nivel óptimo de treshold sin tener que modificar el archvivo para_fit2d.dat cada vez.
