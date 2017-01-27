# gridMooringData

Matlab toolbox for gridding and analyzing mooring data. Originally written by Zhongxiang Zhao to work with McLane Profiler moorings. Further developments and generalizations, as well as git version control, implemented by Olavo Badaro Marques. Others have also contributed along the way.

This toolbox has three main utilities:

* You can load all the data from a mooring.
* Grid the data in a common depth-time grid.
* Compute quantities of interest when studying internal waves from mooring data (e.g. normal mode decomposition).

For the first two of the above, your first need to copy the template “template_allinstruments.m” to the mooring directory and modify it according to the mooring you are processing. This script contains the serial number of all instruments on the mooring and their nominal depths (both should be obtained from the mooring diagram). The second step is to copy “templateMooringWorksheet.m” and follow the instructions on the header. It should take you only a minute to make the changes you need and then you are all set!

A few important remarks to bear in mind:

* The data MUST be saved following standards of the Multiscale Ocean Dynamics (MOD) group.