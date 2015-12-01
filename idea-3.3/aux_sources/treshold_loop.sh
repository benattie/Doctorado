# Script para correr el programa idea utilizando un umbra minimo diferente.
# Modo de uso:
#               sh treshold_loop.sh
# Correr en el directorio en que se encuentre la variosn de idea que se quiera correr.
for i in {50..0..-10}
do
  echo "Haciendo corrida con valor de umbral $i"
  mkdir out
  ./idea-3.2.exe $i
  mv out out_$i
done
