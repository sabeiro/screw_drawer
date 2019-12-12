import numpy as np
 
def Metroplis_algorithm(N, m, dr):
    ''' A Markov chain is constructed, using the
    Metropolis algorithm, that is comprised of
    samples of our probability density: psi(x,y).
 
    N - number of random moves to try
    m - will return a sample when i%m == 0
        in the loop over N
    dr - maximum move size (if uniform),
         controls the acceptance ratio '''
 
    # we'll want to return the average
    # acceptance ratio
    a_total = 0
 
    # sample locations will be stored in a list
    samples = []
 
    # get the starting configuration
    # and sample probability distribution
    # we'll start at r=(0,0)
    r_prime = np.zeros(2)
    p_prime = psi(r_prime[0], r_prime[1])
 
    for i in range(N):
        # propose a random move: r'-> r
        r = r_prime + np.random.uniform(-dr,dr,
                                        size=2)
        p = psi(r[0], r[1])
 
        # calculate the acceptance ratio
        # for the proposed move
        a = min(1, p/p_prime)
        a_total += a
 
        # check for acceptance
        p_prime, r_prime = check_move(p_prime, p,
                                      r_prime, r)
 
        if i%m == 0:
            samples.append(r_prime)
 
    return np.array(samples), a_total/N*100.0
 
def check_move(p_prime, p, r_prime, r):
    ''' The move will be accepted or rejected
        based on the ratio of p/p_prime and a
        random number. '''
 
    if p/p_prime >= 1:
        # accept the move
        return p, r
 
    else:
        rand = np.random.uniform(0, 1)
        if p/p_prime + rand >= 1:
            # accept the move
            return p, r
        else:
            # reject the move
            return p_prime, r_prime

def Metroplis_algorithm_walkers(N, m, walkers, dr):
    ''' A Markov chain is constructed, using the
    Metropolis algorithm, that is comprised of
    samples of our probability density: psi(x,y).
 
    N - number of random moves to try
    m - will return a samples when i%m == 0
        in the loop over N
    walkers - number of unique Markov chains
    dr - maximum move size,
         controls the acceptance ratio '''
 
    # we'll want to return the average
    # acceptance ratio
    a_total = 0
 
    # sample locations will be stored in a list
    samples = []
 
    # get the starting configuration
    # and sample probability distribution
    # we'll start at a randomly
    # selected position for each walker
    r_prime = [np.random.uniform(-10, 15, size=2) for w in range(walkers)]
    p_prime = [psi(r_prime[w][0], r_prime[w][1])
               for w in range(walkers)]
 
    # initialize lists
    r = [np.zeros(2) for w in range(walkers)]
    p = [np.zeros(1) for w in range(walkers)]
 
    for i in range(N):
        for w in range(walkers):
            # propose a random move: r'-> r
            r[w] = r_prime[w] + np.random.uniform(-dr,dr,
                                                  size=2)
            p[w] = psi(r[w][0], r[w][1])
 
            # calculate the acceptance ratio
            # for the proposed move
            a = min(1, p[w]/p_prime[w])
            # update the total
            a_total += a
 
            # check for acceptance
            p_prime[w], r_prime[w] = check_move(p_prime[w], p[w],
                                                r_prime[w], r[w])
 
            if i%m == 0:
                samples.append(r_prime[w])
 
    return np.array(samples), a_total/N/walkers*100.0
 
def check_move(p_prime, p, r_prime, r):
    ''' The move will be accepted or rejected
    based on the ratio of p/p_prime and a
    random number. '''
 
    if p/p_prime >= 1:
        # accept the move
        return p, r
 
    else:
        rand = np.random.uniform(0, 1)
        if p/p_prime + rand >= 1:
            # accept the move
            return p, r
        else:
            # reject the move
            return p_prime, r_prime

        
import matplotlib.mlab as mlab

def psi(x, y):
    ''' Our probability density function is the addition
        of two 2D Gaussians with different shape. '''
    g1 = mlab.bivariate_normal(x, y, 2.0, 2.0, -5, -5, 0)
    g2 = mlab.bivariate_normal(x, y, 0.5, 5.0, 10, 10, 0)
    return g1 + g2

N, m, dr = 50000, 10, 3.5
samples, a = Metroplis_algorithm(N, m, dr)

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
 
fig = plt.figure(figsize=(14,14))
ax = fig.gca(projection='3d')
# ax = fig.add_subplot(111, projection='3d')
x1, x2 = -15, 15
y1, y2 = -15, 30
# set up a meshgrid - like labeling (x,y) coordinates
# for each vertex on a piece of graph paper
dx = 0.1
pad = 5
x = np.arange(x1, x2, dx)
y = np.arange(y1, y2, dx)
X, Y = np.meshgrid(x, y)
# define Z as the value of the probability
# distribution q at each 'vertex'
# Z becomes a 2D Numpy array
Z = psi(X, Y)
# plot
ax.plot_wireframe(X,Y,Z, rstride=5, cstride=7,
                  color='r', alpha=0.7)
ax.scatter(samples[:, 0], samples[:, 1], color='b', s=0.2)
# make it pretty (as found in Axes3D.contour documentation)
# cset = ax.contour(X, Y, Z, zdir='z', offset=-100, cmap=cm.coolwarm)
cset = ax.contour(X, Y, Z, zdir='y', offset=y2, cmap=cm.coolwarm)
cset = ax.contour(X, Y, Z, zdir='x', offset=x1, cmap=cm.coolwarm)
# define the limits
ax.set_xlabel('x', labelpad=15, fontsize=15)
ax.set_xlim(x1, x2)
ax.set_ylabel('y', labelpad=15, fontsize=15)
ax.set_ylim(y1, y2)
ax.set_zlabel('psi(x,y)', labelpad=15, fontsize=15)
ax.set_zlim(0, 0.06)
# ax.view_init(elev=20, azim=-45)
#plt.savefig('pretty_plot_metropolis_sampling.png', bbox_inches='tight', dpi=144)
plt.show()
import matplotlib.pyplot as plt
def plot_samples(samples, psi, limits=[]):
    ''' Plot the results of our Monte Carlo
    sampling along with the underlying
    probability distribution psi. '''
 
    # set up a meshgrid - like labeling (x,y)
    # coordinates for each vertex on a piece
    # of graph paper
    dx = 0.1
    pad = 5
    if limits:
        xlow, xhigh = limits[0], limits[1]
        ylow, yhigh = limits[2], limits[3]
    else:
        xlow = np.min(samples)-pad
        xhigh = np.max(samples)+pad
        ylow = np.min(samples)-pad
        yhigh = np.max(samples)+pad
 
    x = np.arange(xlow, xhigh, dx)
    y = np.arange(ylow, yhigh, dx)
    X, Y = np.meshgrid(x, y)
 
    # define Z as the value of the probability
    # distribution psi at each 'vertex'
    # Z becomes a Numpy array
    Z = psi(X, Y)
 
    # must be feeding in numpy arrays below
    plt.scatter(samples[:, 0], samples[:, 1],
                alpha=0.5, s=1)
    CS = plt.contour(X, Y, Z, 10)
    plt.clabel(CS, inline=1, fontsize=10)
 
    plt.xlim(xlow, xhigh)
    plt.ylim(ylow, yhigh)
    plt.xlabel('x', fontsize=20)
    plt.ylabel('y', fontsize=20)
    plt.tick_params(axis='both', which='major', labelsize=15)
    plt.show()


plot_samples(samples, psi, limits=[])
