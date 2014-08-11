# para graficar datos dados por columnas
import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("file")

# graficar un solo set de datos
plt.plot(d[:,0], d[:,1], 'ro')

# graficar varios sets de datos
plt.plot(d[:,0], d[:,1], 'ro', d[:,0], d[:,2], 'bo', d[:,0], d[:,3], 'go')

#mostrar la grafica
plt.show()

# esperar cierto tiempo
import time
time.sleep(5) # espera 5 segundos


# cerrar la grafica
plt.close()


# array vacio
a = np.empty((0,0))

# array de ceros
a = np.zeros((2,3))
