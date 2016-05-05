function handle=plotInGroundPlane(handle, plotLocs, distances, lineColors, varargin)
% plotInGroundPlane plots the roads for a cityplot with roads colored to
% correspond to the distances
%
% plotInGroundPlane(distances, plotLocs) plots the roads with colors determined
%    to be proportional to distances and plotLocs determining endpoints.
%    distances should be an Ex3 matrix where the 1st two columns are
%    indicies of endpoints corresponding positions which
%    are numbered in the 1st index of plotLocs. The 3rd column should be the
%    distance between inputs. All edges given as such in distances are plotted.
%    plotLocs is Nx2 matrix of the locations of nodes connected by edges in
%    distances. Rows are coordinate locations.
% plotInGroundPlane(distances, plotLocs, lineColors) uses the colormap
%    lineColors as to plot the distances. Default is the
%    DefaultFigureColorMap.
% plotInGroundPlane(distances, plotLocs, lineColors, 'interpMethod', str)
%    uses the input interpolation method for interoplating between
%    lineColors values when finding distanecs. options are {'linear'
%    (default), 'nearest', 'next', 'previous', 'pchip', 'cubic', 'v5cubic',
%    'spline'}. See help interp1 for more information on each option.
%
% plotInGroundPlane(h, ___) plots on the input figure or axes handle.
% 
% h=plotInGroundPlane(___) returns the handle used for plotting.
%
% plotRoads3d(__, option1Str, option1val, ...) gives options as follows:
%    
%

%% input parsing and checking
p=inputParser();

addRequired(p,'plotLocs', @(in) isnumeric(in));
addRequired(p,'distances', @(in) isnumeric(in) && size(in,2)==3);
addOptional(p,'lineColors',get(0,'DefaultFigureColorMap'));
addParameter(p,'interpMethod','linear', @(x) any(validatestring(x, {'linear','nearest','next','previous','pchip','cubic','v5cubic','spline'})));

if(~exist('varargin','var'))
    varargin=cell(0);
end

switch nargin
    case 1
        error('too few inputs to plotInGroundPlane');
    case 2
        parse(p,handle,plotLocs);
        handle=figurePlotAxes(gcf());
    case {3,5} % one optional.
        if(all(size(handle)==[1,1]) && isgraphics(handle))
            parse(p,plotLocs, distances, varargin{:});
        else
            parse(p,handle,plotLocs, distances, varargin{:})
            handle=figurePlotAxes(gcf());
        end
    case 4
        if(all(size(handle)==[1,1]) && isgraphics(handle))
            parse(p,plotLocs,distances,lineColors);
        else
            parse(p,handle,plotLocs,distances,lineColors)
        end
    case 6
        parse(p,plotLocs,distances, lineColors, varargin{:});
    otherwise
        error('too many inputs to plotInGroundPlane');
end
if(~(all(size(handle)==[1,1]) && isgraphics(handle)))
    error('figure handle is not a figure handle')
end

%% plot edges edge-by-edge
dist=p.Results.distances;
pointLocs=p.Results.plotLocs;
if(any(isnan(dist(:,3))))
    error('found NaN distances')
end

if(min(dist(:,3))==max(dist(:,3)))
    colorToUse=repmat(p.Results.lineColors(1,:),size(dist,1),1);
else
    colorToUse=interp1(linspace(min(dist(:,3)), max(dist(:,3)),size(p.Results.lineColors,1)), p.Results.lineColors, dist(:,3), p.Results.interpMethod);
end
for(i=1:size(dist,1))
    indx1=dist(i,1);
    indx2=dist(i,2);
    pt1=pointLocs(indx1,:);
    pt2=pointLocs(indx2,:);
    
    plot3(handle,[pt1(1); pt2(1)], [pt1(2); pt2(2)], zeros(2,1), 'Color', linearSaturate(colorToUse(i,:), 0, 1));
end
return