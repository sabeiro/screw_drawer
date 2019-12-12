# -*- coding: utf-8 -*-

import numpy
from numpy import arange, sqrt, sin
import os
import sys
import bz2

from enthought.mayavi import mlab
from enthought.mayavi.sources.array_source import ArraySource
from enthought.mayavi.modules.surface import Surface
from enthought.mayavi.modules.iso_surface import IsoSurface
from enthought.mayavi.modules.outline import Outline
#from enthought.mayavi.modules.labels.Labels import Labels
#from enthought.mayavi.modules.orientation_axes.OrientationAxes import Axes
#from enthought.mayavi.modules.grid_plane.GridPlane import Grid

from numpy import array
try:
    engine = mayavi.engine
except NameError:
    from enthought.mayavi.api import Engine
    engine = Engine()
    engine.start()
if len(engine.scenes) == 0:
    engine.new_scene()

picno = 75600
inname = "DensProf" + "%09d" % picno + ".dat"
#inname = "data.dat"

command = "ElPoly " + inname + " --rzd"
os.system(command)

inname = "data.dat"

#field = open("out.dat.0")
field = open(inname)

nx = 100
ny = 100
nz = 60

# Import Array

# electrostatics information
data = numpy.loadtxt(field)

row1 = data[:,3]


# Adjust the shape of the data
plotdata = row1.reshape((nx,ny))


src1 = ArraySource(transpose_input_array=True)
src1.name = u'Daten'
src1.scalar_data = plotdata
mayavi.add_source(src1)

# ------------------------------------------- 
#array_source = engine.scenes[0].children[0]
#engine.add_filter(<enthought.mayavi.modules.iso_surface.IsoSurface object at 0xa1a8059c>, array_source)
# ------------------------------------------- 
#from enthought.mayavi.tools.show import show
#show()

iso_surface = IsoSurface()
array_source = engine.scenes[0].children[0]
engine.add_filter(iso_surface, array_source)

iso_surface = engine.scenes[0].children[0].children[0].children[0]
iso_surface.actor.property.specular_color = (0.0, 0.0, 0.0)
iso_surface.actor.property.diffuse_color = (0.0, 0.0, 0.0)
iso_surface.actor.property.ambient_color = (0.0, 0.0, 0.0)
iso_surface.actor.property.color = (0.0, 0.0, 0.0)

# m_grid = Grid() 
# array_source = engine.scenes[0].children[0]
# engine.add_filter(m_grid, array_source)

# grid_plane = engine.scenes[0].children[0].children[0].children[1]
# grid_plane.actor.property.representation = 'points'

# m_labels = Labels() 
# array_source = engine.scenes[0].children[0]
# engine.add_filter(m_labels, array_source)

# m_axes = Axes() 
# array_source = engine.scenes[0].children[0]
# engine.add_filter(m_axes, array_source)

# axes = engine.scenes[0].children[0].children[0].children[3]
# axes.axes.ranges = array([ 0.,  0.,  0.,  0.,  0.,  0.])
# axes.axes.position2 = array([ 0.5,  0.5])
# axes.axes.bounds = array([  0.,  99.,   0.,  99.,   0.,   0.])
# axes.axes.position = array([ 0.,  0.])
# axes.axes.number_of_labels = 8
# axes.axes.x_label = 'R'
# axes.axes.y_label = 'Z'
# axes.axes.ranges = array([ 0.,  1., 0.,  1., 0.,  0.])


scene = engine.scenes[0]
scene.scene.background = (1.0, 1.0, 1.0)
scene.scene.foreground = (.0, .0, .0)
scene.scene.camera.position = [24.6796569824219, 53.048135757446389, 145.58793636666158]
scene.scene.camera.focal_point = [24.6796569824219, 53.048135757446389, 1.0476915424168098e-16]
scene.scene.camera.view_angle = 30.0
scene.scene.camera.view_up = [0.0, 1.0, 0.0]
scene.scene.camera.clipping_range = [144.13205700299497, 147.7717554121615]
scene.scene.camera.compute_view_plane_normal()
scene.scene.render()

#module_manager = engine.scenes[0].children[0].children[0]
#module_manager.children[1:2] = []
#engine.add_filter(<enthought.mayavi.modules.contour_grid_plane.ContourGridPlane object at 0xa14241ac>, array_source)
#module_manager.children[1:2] = []
#module_manager.vector_lut_manager.label_text_property.shadow_offset = array([ 1, -1])
#module_manager.vector_lut_manager.label_text_property.color = (0.0, 0.0, 0.0)

surface = engine.scenes[0].children[0].children[0].children[0]
surface.contour.auto_contours = True
surface.contour.number_of_contours = 10
surface.contour.contours[0:1] = [2.5]
surface.contour.minimum_contour = 0.3
#surface.contour.maximum_contour = 4.5
surface.actor.property.line_width = 3
#surface.actor.actor.origin = array([ 0.,  0.,  0.])
#surface.actor.actor.scale = array([ 1.,  1.,  1.])
#surface.actor.actor.orientation = array([ 0., -0.,  0.])
#surface.actor.actor.reference_count = 3
#surface.actor.actor.position = array([ 0.,  0.,  0.])
#surface.actor.actor.visibility = False

picname = "Image" + "%09d" % picno + ".jpg"

scene.scene.save(picname)

# # first picture taken, now check for higher names
picno = picno + 200
inname = "DensProf" + "%09d" % picno + ".dat"

while (os.path.isfile(inname)):
  #  field = open(inname)

  command = "ElPoly " + inname + " --rzd"
  os.system(command)
  
  inname = "data.dat"

  field = open(inname)

  data = numpy.loadtxt(field)

  row1 = data[:,3]

  # Adjust the shape of the data
  plotdata = row1.reshape((nx,ny))

  src1.scalar_data = plotdata

  picname = "Image" + "%09d" % picno + ".jpg"
  scene.scene.save(picname)

  picno = picno + 200
  inname = "DensProf" + "%09d" % picno + ".dat"
  print "elaborating ", inname

#sys.exit()
