#! /bin/octave -qf
#Constants
PhiFlory = 6.02;#[ngs]
kB = 1.3806e-23;#[J/K]
T = 300;#[K]
kBT = kB*T;#[J]
NAvogadro = 6.22e23;
Joule_Mol = 1./kBT/NAvogadro;#[J/Mol]
pN = 1./kBT*1e-12*1e-6;
#Values
Thick.kN70 = 3.25;#[DL]
Thick.POPC = 3.5;#[nm]
Diff.DOPC = 12e6;#[nm^2/s]
Diff.kN70 = 0.0522/4.;#[DL^2/st]
#Comparison
Bend.Marta = 0.9e-19;#[J]
Bend.Marta/kBT
Bend.kN70 = 13.9;#[kBT]
#Conversion
Conv.Length = Thick.POPC/Thick.kN70;#[nm/DL]
Conv.Time = Diff.kN70/Diff.DOPC*(Conv.Length)^-2*1e9;#[ns/st]
Conv.Force = Bend.Marta/Conv.Length*1e9*1e12;#[nN/kB/DL]
Conv
Compr.Marta = 100e-3;#[J/m^2]
Compr.Marta*kBT*1e12/Conv.Length
Compr.kN70 = 0.0307;#[kBT/DL^2]




