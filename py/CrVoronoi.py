import numpy as np
import matplotlib.pyplot as plt
import scipy.interpolate
#from scipy.spatial import Voronoi, voronoi_plot_2d
#from pyhull.delaunay import DelaunayTri
from pyhull.voronoi import VoronoiTess
# Generate data:
points = 10 * np.random.random((3,20))
print points
vor = VoronoiTess(points)
#vor = Voronoi(points)
voronoi_plot_2d(vor)
plt.show()

#plt.savefig("out.svg", transparent = True)
