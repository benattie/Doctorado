Here I present a set of python, C, matlab and bash code that I've been creating during my PhD in physics, in the branch of material science.
Currently in the process of translating all the help files in english. Right now, only this file and the INSTALL file.

bin/: A folder created for storing the executables files. It's empty in the repository because I don't upload compiled code.

idea-3.3/: A program for processing data from Synchrotron X-Ray Diffraction experiments. The software fits a pseudo-voigt to each pattern and then export data so it can be presented in a pole figure.

idea-CMWP/: More or less the same as idea-3.3, but using the CMWP routine for the fitting (not included)

idea-wa/: A prototype of a software for performing the Warren-Averbach method to each peak of an X-Ray pattern. It's not finished because I ended working with the CMWP routine, which is a more advanced approach of the same method.

idea-wh/: Uses the output of idea-3.3 create Williamson-Hall plots from the data. It estimates the best parameters and creates generalized pole figures from Williamson-Hall's crystalyte size and dislocation density. Currently outdated and replaced for idea-CMWP.

make-WH/: This program takes the output from idea-CMWP and creates Williamson-Hall plots from it. This is done in order to check that the fit done by idea-CMWP was good.

sources/: Some auxiliary sources from early stages of the development. In the python folder there's a program that is used for preprocessing the data and in the Matlab folder there are scripts for working with the output of idea.
