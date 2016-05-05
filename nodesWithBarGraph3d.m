function handle=nodesWithBarGraph3d(handle, plotting, metrics, heightLim,varargin)
% nodesWithBarGraph3d plots cities and the associated buildings.
%
% nodesWithBarGraph3d(plotting, metrics, heightLim) plots the cities with
%   locations given as rows in plotting with corresponding values for
%   criteria (metrics) and limits buildings to have height heightLim.
%   plotting should be an Nx2 matrix and metrics should be NxP where P is the
%   number of criteria. heightLim should be either a scalar or a vector
%   with length P corresponding to the limits in the height of each
%   criteria.
%
% nodesWithBarGraph3d(h, ___) plots on the input figure or axes handle.
% 
% h=nodesWithBarGraph3d(___) returns the handle used for plotting.
% 
% nodesWithBarGraph3d(___, option1Str, option1Val, ...) inputs options
%   'colorCycle', colors : is a vector of color characters (see help plot) or a
%      colormap (Cx3 matrix) which determines the colors used for plotting
%      each building which represents a given criteria. default: [brgkcy]'
%      if C<P will wrap around and reuse the first color for the buildings. 
%      Colors are used in the order listed in metrics.
%   'BuildingProp', cellArrayOfOptions : specifies patch properties to use 
%      when rendering buildings. See doc patch properties for options to 
%      put into cellArrayOfOptions

%% parse inputs and error checking.
p=inputParser();
addRequired(p,'plotting',@isnumeric);
addRequired(p,'metrics', @isnumeric);
addRequired(p,'heightLim', @isnumeric);
addParameter(p,'colorCycle',['brgkcy']');
addParameter(p,'buildingProp',cell(0));

switch nargin
    case {0,1,2}
        error('too few input arguments to nodesWithBarGraph3d')
    case 3
        parse(p, handle, plotting, metrics);
        handle=gcf();
    case {4,6,8}
        parse(p, plotting, metrics, heightLim, varargin{:});
    case {5,7}
        parse(p, handle, plotting, metrics, heightLim, varargin{:});
        handle=gcf();
    otherwise
        error('too many input arguments to nodes WithBarGraph3d')
end

plotting=p.Results.plotting;
metrics=p.Results.metrics;
heightLim=p.Results.heightLim;

[m,n]=size(heightLim);
if(m==1 && n==1)
    heightLim=ones(1,size(metrics,2))*heightLim;
elseif(n==1)
    if(m==size(metrics,2))
        heightLim=heightLim';
    else
        error('height limit must be a vector or scalar corresponding to metrics');
    end
elseif(m~=1) % neither is 1
    error('height limit must be a vector or scalar corresponding to metrics');
elseif(n~=size(metrics,2))
    error('height limit must be a vector or scalar corresponding to metrics');
else
    error('how''d we get here?!?!');
end

%% set bar graph parameters and find heights
xrange=range(plotting(:,1));
yrange=range(plotting(:,2));

rectWidthX=xrange/90;
rectWidthY=yrange/90;
n_met=metrics./repmat(max(metrics,[],1),size(metrics,1),1); % shrink all metrics uniformly by largest to insure will get same height.
rectHeight=n_met.*repmat(heightLim,size(metrics,1),1); % scale all buildings so tallest is at height limit for each objective.

%% plot nodes and bar graphs.
ax_hndl=figurePlotAxes(handle);
nancnt=0;
for(i=1:size(plotting,1))
    switch numel(ax_hndl)
        case 0
            plot3(plotting(i,1),plotting(i,2),0,'MarkerFaceColor',zeros(1,3),'Marker','o'); %city marker
        case 1
            plot3(ax_hndl, plotting(i,1),plotting(i,2),0,'MarkerFaceColor',zeros(1,3),'Marker','o'); %city marker
        otherwise
            error('multiple axes to plot detected. Not supported');
    end
	
	for(metI=1:size(metrics,2)) % skyscrapers
		if(~isnan(rectHeight(i,metI)))
            adjust=rectWidthX*(metI-1);
            barPos=[plotting(i,1)+adjust,plotting(i,2),0];
            barDim=[rectWidthX,rectWidthY,rectHeight(i,metI)];
            if(any(size(p.Results.colorCycle)==1))
                thisColor=p.Results.colorCycle(mod(metI-1,length(p.Results.colorCycle))+1);
            else
                thisColor=p.Results.colorCycle(mod(metI-1,length(p.Results.colorCycle))+1,:);
            end
            drawBox3d(barPos,barDim,'FaceColor',thisColor,p.Results.buildingProp{:});
        else
            nancnt=nancnt+1;
        end
	end
end

if(nancnt>0)
    warning(['encountered ',num2str(nancnt), ' NaNs in plot']);
end
return