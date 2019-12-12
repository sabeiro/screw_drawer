import numpy as np
import matplotlib.pyplot as plt
import scipy.interpolate
import pylab
fig = pylab.figure()

# Generate data:
#x = np.arange(-5.0, 5.0, 1.)
#y = np.arange(-5.0, 5.0, 1.)
#z = 10 * np.random.random((1,10))
x, y, z = 10 * np.random.random((3,20))

# Set up a regular grid of interpolation points
#xi, yi = np.linspace(x.min(), x.max(), 100), np.linspace(y.min(), y.max(), 100)
xi, yi = np.linspace(0., 10., 100), np.linspace(0., 10., 100)
xi, yi = np.meshgrid(xi, yi)

# Interpolate
rbf = scipy.interpolate.Rbf(x, y, z, function='cubic')
#rbf = scipy.interpolate.interp2d(x, y, z, kind='cubic')
zi = rbf(xi, yi)

plt.imshow(zi, vmin=z.min(), vmax=z.max(), origin='lower',
           extent=[x.min(), x.max(), y.min(), y.max()])
plt.scatter(x, y, c=z)
#plt.colorbar()
plt.savefig("out.svg", transparent = True)
#plt.show()
#pylab.axis('off')
#fig.set_size_inches(4,3) 
#fig.set_dpi(40)
exit
