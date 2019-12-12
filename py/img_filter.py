from scipy import signal as sg

fIdentity = np.matrix([[0.,0.,0.],[0.,1.,0.],[0.,0.,0.]])
fEdge1 = np.matrix([[1.,0.,-1.],[0.,0.,0.],[-1.,0.,1.]])
fEdge2 = np.matrix([[0.,1.,0.],[1.,4.,1.],[0.,1.,0.]])
fEdge3 = np.matrix([[-1.,-1.,-1.],[-1.,8.,-1.],[-1.,-1.,-1.]])
fSharpen = np.matrix([[0.,-1.,0.],[-1.,5.,-1.],[0.,-1.,0.]])
fBlur = np.matrix([[1.,1.,1.],[1.,1.,1.],[1.,1.,1.]])/9.
fGaussBlur = np.matrix([[1.,2.,1.],[2.,4.,2.],[1.,2.,1.]])/16.
fHalf = np.matrix([[1.,1.],[1.,1.]])/4.



