Programas que me permiten:

1. [setup.py] Convertir un script de python (pyemb.py) a un archivo pyemb.exe que ejecuta el script de python tomando los argumentos que hagn falta.
	para eso hay que correr:
	python setup py2exe
	notar que el nombre del script aparece en en archivo setup.py

2. Codigo de C que corre el ejecutable creado (en realidad cualquier ejecutable) tomando los argumentos que hagan falta
	se compila y se corre como siempre
	gcc -o pye.exe pye.c
	pye.exe