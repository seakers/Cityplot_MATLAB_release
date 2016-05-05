function [handle]=plotRoads3d(handle, distances, plotLocs, varargin)
% plotRoads3d plots the roads for a cityplot with roads colored to
% correspond to the distances and includes options and color labels.
%
% plotRoads3d(distances, plotLocs) plots the roads with colors determined
%    to be proportional to distances and plotLocs determining endpoints.
%    distances should be an NxN symmetric nonegative matrix representing the original
%    distances before reducing dimension. 0 entries are treated as points being fully
%    disconnected and asimilar. plotLocs is Nx2 matrix of the locations of
%    nodes connected by edges in distances (indicies in distances correspond to locations in plotLocs).
%    Rows are coordinate locations.
%    Observe the number of distances plotted is capped (see options).
%
% plotRoads3d(h, ___) plots on the input figure or axes handle.
%
% h=plotRoads3d(___) returns the handle used for plotting.
%
% plotRoads3d(__, option1Str, option1val, ...) gives options as follows:
%    'legendCap', lCap (default is 0) : if the input lCap is >0 will
%       draw a legend instead of a colorbar and bin distances into up to
%       lCap bins (if have fewer than lCap distances, each distance value is
%       given it's own entry in the legend). If input distances are integer
%       will display legend entries as integers.
%    'lineColors', colormap : a colormap to use for plotting edges by
%       length.
%    'targetConn', targetVal : To avoid excess crowding, plotRoads3d will
%       only plot up to targetConn edges. This is found by comparing the
%       list of distances and cutting off the maximum distance that will be
%       plotted such that the plotted distances are as close to the input
%       targetVal as possible without going over. If targetConn is not exceeded,
%       will plot all edges given in input distances. targetVal=inf will plot
%       all edges given by distances. default value is N*log(N) where N is
%       the number of locations that can have roads connecting them. This
%       default is based on the expected number of edges needed to create a
%       single connected component in a random graph.
%

%% input parsing and checking
defClrMap=get(0, 'DefaultFigureColormap');

p=inputParser();
addRequired(p, 'distances')
addRequired(p, 'plotLocs')
addParameter(p, 'lineColors', defClrMap);
addParameter(p, 'legendCap', 0);
addParameter(p, 'targetConn', ceil(size(plotLocs,1)*log(size(plotLocs,1))), @isnumeric);

switch nargin
    case 1
        error('too few inputs to plotInGroundPlane');
    case {2, 4, 6, 8}
        parse(p,handle,distances);
        handle=gcf();
    case {3, 5, 7, 9}
        parse(p,distances, plotLocs, varargin{:});
    otherwise
        error('too many inputs to plotInGroundPlane');
end
if(~(all(size(handle)==[1,1]) && isgraphics(handle)))
    if(isempty(handle))
        error('empty figure handle to plotRoads 3d');
    else
        error('figure handle is not a valid handle')
    end
end

%% filter distances to plot
filterDist=distToTargetConn(distances, p.Results.targetConn);
if(isempty(filterDist))
    warning('targetConn too small, failed to include any distances')
else
    %% find if want to use a color map or bin into groups and give as legend
    if(p.Results.legendCap>0) % will group, bin and use roads
        uDist=unique(filterDist(:,3));
        
        if(size(uDist,1)>p.Results.legendCap)
            upper=max(filterDist(:,3));
            binBndry=linspace(min(filterDist(:,3)), upper+3*eps(upper), p.Results.legendCap);
            
            if(isequal(fix(filterDist),filterDist)) % for integer distances round to integer values for legend
                legendStr=[num2str(floor(binBndry(1:end-1))','%i'),repmat('-',length(binBndry)-1,1),num2str(floor(binBndry(2:end))','%i')];
            else
                legendStr=[num2str(binBndry(1:end-1)','%4.2g'),repmat('-',length(binBndry)-1,1),num2str(binBndry(2:end)','%4.2g')];
            end
        else % no need to bin
            if(size(uDist,1)==1)
                uDist=uDist';
            end
            legendStr=num2str(uDist);
        end
        
        colorsUsed=min(p.Results.legendCap, size(uDist,1));
        if(size(p.Results.lineColors,1)>colorsUsed)
            lineColorsToUse=interp1(linspace(0,1,size(p.Results.lineColors,1)), p.Results.lineColors,linspace(0,1,colorsUsed), 'linear'); % downscale linecolors
        else
            lineColorsToUse=p.Results.lineColors;
        end
        
        interp='previous';
        hackLegend(handle, p.Results.plotLocs, uDist, lineColorsToUse); % overrrides first several lines so can present legend correctly later.
    else % do as continuous mapping with linear interpolation.
        lineColorsToUse=p.Results.lineColors;
        interp='linear';
    end
    
    %% plotting and labeling.
    [~, sortIndx]=sort(filterDist(:,3),'descend');
    handle=plotInGroundPlane(handle, p.Results.plotLocs, filterDist(sortIndx,:), lineColorsToUse, 'interpMethod', interp);
    
    if(p.Results.legendCap>0)
%         legend(legendStr, 'Location', 'EastOutside');
        legend(legendStr, 'Location', 'East');
    else
        colorbar();
    end
end