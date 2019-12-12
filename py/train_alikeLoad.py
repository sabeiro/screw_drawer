#%pylab inline
import os
import gzip
import sys
import numpy as np
import pandas as pd
import csv

trL = pd.DataFrame()

seed = 128
rng = np.random.RandomState(seed)

dSet = pd.read_csv(os.environ['LAV_DIR']+"/log/sociodemo.csv.gz", compression='gzip',header=0, sep=',', quotechar='"')
print '-----------splitting and removing tails------------------'

##----------------------------feature selection---------------------------
##dSet_y = dSet['gender'].map(str)# + ' ' + dSet['age_range'].map(str)
dSet_y = dSet.ix[:,range(1,3)]
dSet_x = dSet.ix[:,range(3,dSet.shape[1])]
del dSet
# rank_x = dSet_x.rank()
# corr_x = dSet_x.corr('kendall')

Nmin, Nmax = 25,75
dSum_r = dSet_x.sum(axis=1).fillna(0)
lim_r = np.percentile(dSum_r,[Nmin,Nmax])
rowSel = dSum_r[(dSum_r > lim_r[0]) & (dSum_r < lim_r[1])]
dSet_x = dSet_x.iloc[rowSel.index]
dSet_y = dSet_y.iloc[rowSel.index]
dSum_c = dSet_x.sum(axis=0).fillna(0)
lim_c = np.percentile(dSum_c,[Nmin,Nmax])
colSel = dSum_c[(dSum_c > lim_c[0])]
dSet_x = pd.DataFrame(dSet_x,columns=colSel.index)
##df.iloc[rows][cols]
N = dSet_y.shape[0]
print dSet_x.shape

print '-------------write----------------------'

# with gzip.open(os.environ['LAV_DIR']+"/log/socio_y.csv.gz","w") as f :
#     csv_w = csv.writer(f)
#     for row in dSet_y :
#         csv_w.writerow(row)

dSet_x.to_csv(os.environ['LAV_DIR']+"log/socio_x.csv.gz",compression='gzip',sep=',',quotechar='"')
dSet_y.to_csv(os.environ['LAV_DIR']+"log/socio_y.csv.gz",compression='gzip',sep=',',quotechar='"')

##dSet_y.to_csv(os.environ['LAV_DIR']+"/log/socio_y.csv")
