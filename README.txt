Cityplot: a technique to visualize high dimensional design spaces.

A set of designs is defined by row vectors x in a matrix X. Each design has criteria values y which are row vectors in a matrix Y. 

Essentially simply performs multidimensional scaling on the designs (X) and then plots bar graphs at each design with the criteria values.

At a minimum requires only the distances between designs (see pdist and squareform in the MATLAB documentation) and the criteria values. For optional arguments to easy interpretation and to control the plotting procedure see the function documentation (help functionname),

For quick-start it is recommended to go to the Samples sub-folder and run the examples. discExpTrade is more detailed and easier to fully understand.

Users are recommended to stick to the Samples folder and cityplot3d. Other functions are subject to change and included for gaining even more control over plotting.

Included in this package:
Primary folder :: contains all plotting codes needed for general use. Add to MATLAB path to install the cityplot.
	>> cityplot3d :: the primary method and interface for plotting cityplot. Encapsulates usage of all other functions <<
	cityplotDataCursor :: Callback function used when users use the data cursor
	distToTargetConn :: helper function that filters distance values so will have as close to a desired number of remaining elements without going over
	drawBox3d :: helper function that draws cubic patches aligned with the axis in a 3d plot.
	figurePlotAxes :: helper function to extract plotting axes from figures
	hackLegend :: ugly hack that allows plotting legends with the correct colors
	linearSaturate :: helper function that is linear between two input bounds and uses the bounds when either bound is exceeded. Needed to avoid funny rounding errors due to MATLAB using floating point.
	nodesWithBarGraph3d :: plots cities at given locations and plots buildings at each location
	plotInGroundPlane :: plots roads in the ground plane of the cityplot with given distances and between given locations
	plotRoads3d :: wraps finding the roads to plot, plotting roads with plotInGroundPlane, legend plotting and legend string generation.
	regularizeLbls :: helper function that converts multiple data types (e.g. numerics) into string cell arrays to allow easier processing elsewhere.
Samples :: example function calls to clarify the method and function usage. Not needed to run cityplot.
	continuous_inPaperV5_0 :: Data file for contiToy6Obj.
	contiToy6obj :: loads a larger precomputed dataset and makes a few cityplots.
	discExpTrade :: a simple toy problem which enumerates all possible {0,1} vectors of a given length, calculates 3 objectives where the 1st and 2nd are given by multiplying by exponentially increasing/decreasing weights and taking the sum. 3rd objective is the number of 1's to make the set of vectors which achieve a favorable minimization (pareto-optimal) for atleast one objective at a given level for the other objectives and demonstrates several cityplot possibilities
	paretofront :: helper function which computes the pareto front of a set of designs.
.hg :: folder for version control.