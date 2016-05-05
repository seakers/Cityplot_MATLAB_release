function [handle]=hackLegend(handle,plotLocs, distances, lineColors)
% hackLegend a hack for getting the legend properly labeled on the cityplot
% 
% simply plots some isolated length 0 "lines" in the ground plane somewhere discrete.
% Should be called before any other plotting is done so that the plotted
% "lines" can be labeled by the legend instead of things added later which
% may not be in a nice order for the legend.
% 
% h=hackLegend(__) : gives the handle used in hacking points around
% hackLegend(h,__) : plots the "lines" on the input figure or axes handle.
% distances : not used. Retained for future possible use
% lineColors : colors that will be used by the legend in the future. Should
% be ordered according to order want to appear in legend. valid inputs
% would pass the 'color' option for plot3.
somewhereDiscrete=plotLocs(1,:);
for i=1:size(lineColors,1)
    plot3(figurePlotAxes(handle),somewhereDiscrete(1), somewhereDiscrete(2), 0, 'Color',lineColors(i,:));
end