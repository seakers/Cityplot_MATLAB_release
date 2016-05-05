function [h, plotting,nCriteria,pltOpts,dataCursorHandle]=cityplot3d(h,dist, varargin)
%cityplot3d create cityplot of input distances with input objectives.
%  Average distances are preserved as much as possible while reducing to a 2d
%  ground plane with euclidean distance and the criteria are plotting as a
%  bar graphs ("skyscrapers") at each complete design ("cities"). See Nathan
%  Knerr, Daniel Selva, "Cityplot: Visualization of High-Dimensional Design
%  Spaces with Multiple Criteria" Journal of Mechanical Design (in review)
%  for more information.
%
%   cityplot3d(dist, criteria) :: makes a cityplot with default settings. dist
%      is symetric strictly positive NxN matrix of distances between designs
%      in the original space (equivalently, the dissimilarity matrix between 
%      objects to plot); N is the number of designs. criteria is a NxP matrix where each row is a
%      the criteria upon which one migt judge designs; P is the number of
%      criteria.
%
%   (optional) outputs:
%       plotting :: 2-d locations for cities in the 2-d reduced space
%       nCriteria :: NxP matrix of normalized criteria used for plotting skyscraper heights.
%       pltOpts :: assorted default values used in plot creation. Subject
%                  to change. Current values are: pltOpts.buildingHeight,
%                  pltOpts.campos. which are value used for BuildingHeight
%                  option and camera position respectively. 
%       dataCursorHandle :: a handle to the data cursor object used when
%                  clicking on a design in the cityplot.
%
%   cityplot(h, __) plots onto the axes or figure handle h
%
%   cityplot(dist, criteria, option1command, option1value, ...) :: uses
%   options from the following list:
%      'UseClassic', {true (default) | false} : uses classical multidimensional scaling
%      'DesignLabels', cellArrayOfStrings with N cells : labels used when
%         called with 'spew' or when clicking designs with the data cursor.
%         Default just uses dist/criteria index.
%      'CriteriaLabels' : labels used for labelling criteria when clicking
%         designs with the data cursor. Default just numbers criteria.
%      'MdscaleOptArgs', cellArrayOfOptions : will use mdscale unless
%         UseClassic is manually set to true. Will feed mdscale all options
%         specified by cellArrayOfOptions as if were inputting into the
%         argument list of mdscale. See help mdscale for options to put into
%         cellArrayOfOptions.
%      'BuildingHeight', realNumber : specifies the maximum height of
%         bars (skyscrapers) in the graph. defaults to a convienent
%         percentage of the ground plane occupied by cities.
%      'BuildingProp', cellArrayOfOptions : specifies patch properties to
%         use when rendering buildings. See doc patch properties for
%         options to put into cellArrayOfOptions
%      'BuildingColors', colors to cycle between when plotting buildings
%         (criteria). Input as a colormap. Will use the colors in sequence
%         by row until run out of colors in the colormap and then will
%         cycle again from the top.
%      'LegendCap', number : maximum number of buckets to use in creating
%         the legend. Inputting <=0 will use a colorbar instead.
%      'RoadLimit', number : limit on the number of roads to draw. Will
%         come as close as possible to the input number without going over.
%         Difference will be due to duplicate distance values. Default is
%         based on the expected number of edges needed to create a single
%         connected component in a random graph.
%      'RoadColors', colormap : colors to use when plotting roads, as a
%         colormap
%      'Spew', spewOptions : adds additional data to points on the
%         cityplot. Tends to make things extremely crowded (the plot looks
%         like "spew"). Spew Options should be given as a cell array or strings 
%         or a single string. If multiple strings are input via cell array
%         will concatenate all spew options and spew all input options.
%         Options are:
%            'DesignLabels' : labels each city/design on the cityplot
%                 ground plane.
%            'CriteriaValues' : labels each city/design with the criteria
%                 labels and values.
%
%   for examples see included sample problems folder.

%% possible improvements
% -> find a way to fix the orientation and scaling of the plotted points so to help make things easy to replicate.
% -> rescale plotting instead of capping building height such that the z axis always goes 0->1 and becomes intuitive.
% -> Define behavior for NaN and inf. (Maybe NaN should just be ignored completely for normalization and drawing buildings?)

%% input parsing and validation.
p=inputParser;
addRequired(p,'dist',@isnumeric)
addRequired(p,'criteria',@isnumeric)
addParameter(p,'DesignLabels',arrayfun(@(num) ['design #',num2str(num)], 1:size(dist,1),'UniformOutput',false))
addParameter(p,'CriteriaLabels',[]);
addParameter(p,'Spew',[]);
addParameter(p,'LegendCap', 16, @isnumeric);
addParameter(p,'RoadColors', get(0, 'DefaultFigureColormap'))
addParameter(p,'BuildingColors', 'brgkcym')
addParameter(p,'RoadLimit', [], @(x) isnumeric(x) && isequal(fix(x), x));

% mdscale and cmdscale poke through
addParameter(p,'UseClassic',true);
addParameter(p,'MdscaleOptArgs',[]);

% skyscraper defaults and patch properties poke through
addParameter(p,'BuildingHeight',[]);
addParameter(p,'BuildingProp',[]);

% handle h manually.
if(isempty(h))
    error('1st argument to cityplot3d is empty')
end

if(all(size(h)==[1,1]) && all(isgraphics(h(:)))) % can't handle multiple figure handles (handle is just a selection) and distance are really uninteresting if 1x1
    % must be passed in DesignLabels but not handle.
    switch nargin
        case {0,1}
            error('insufficent number of arguments to cityplot3d');
        case 2
            error('insufficent number of arguments to use cityplot3d with a figure handle call');
        otherwise
            effArgList={dist,varargin{:}};
    end
    defFig=false;
else
    switch nargin
        case {0,1}
            error('insufficent number of arguments to cityplot3d');
        case 2
            effArgList={h,dist};
        otherwise
            effArgList={h,dist,varargin{:}};
    end
    
    h=gcf();
    defFig=true;
end
axHandle=figurePlotAxes(h);
if(numel(axHandle)>=2)
    error('ambiguous axis handle to plot onto');
end
parse(p,effArgList{:});

if(any(strcmp(p.UsingDefaults,'CriteriaLabels')))
    criteriaLabelsIn=arrayfun(@(num) ['criteria #',num2str(num),': '], 1:size(p.Results.criteria,2),'UniformOutput',false);
else
    criteriaLabelsIn=p.Results.CriteriaLabels;
end

%% normalization
nCriteria=p.Results.criteria-repmat(min(p.Results.criteria,[],1),size(p.Results.criteria,1),1);
nCriteria=nCriteria./repmat(max(nCriteria,[],1),size(nCriteria,1),1);

%% get the city locations with mdscale
set(axHandle,'Visible','off'); %don't render to save time.
if(~isempty(axHandle))
    holdState=ishold(axHandle);
    hold(axHandle,'on');
else % assume new figure or otherwise lacking axis. Set for figure and create axes.
    holdState='off';
    if(~defFig)
        figure(h)
    end
    axHandle=axes();
    hold on
end

if(any(strcmp(p.UsingDefaults,'UseClassic')))
    if(any(strcmp(p.UsingDefaults,'MdscaleOptArgs'))) %default to classic.
        plotting=cmdscale(p.Results.dist,2);
    else %default to mdscale if given arguments
        plotting=mdscale(p.Results.dist,2,p.Results.MdscaleOptArgs{:});
    end
else
    if(p.Results.UseClassic)
        plotting=cmdscale(p.Results.dist,2); % use classic if directly called for
    else
        if(any(strcmp(p.UsingDefaults,'MdscaleOptArgs'))) %use mdscale with defaults if directly told not to use cmdscale.
            plotting=mdscale(p.Results.dist,2);
        else %pass through args if given.
            plotting=mdscale(p.Results.dist,2,p.Results.MdscaleOptArgs{:});
        end
    end
end

%% Build Roads
if(any(strcmp(p.UsingDefaults, 'RoadLimit')))
    plotRoads3d(axHandle, p.Results.dist, plotting, 'legendCap', 16, 'lineColors', p.Results.RoadColors);
else
    plotRoads3d(axHandle, p.Results.dist, plotting, 'legendCap', p.Results.LegendCap, 'targetConn', p.Results.RoadLimit, 'lineColors', p.Results.RoadColors);
end

%% Build Skyscrapers
if(any(strcmp(p.UsingDefaults,'BuildingHeight')))
    BuildingHeight=range(plotting(:,2))/10;
else
    BuildingHeight=p.Results.BuildingHeight;
end

pltOpts.BuildingHeight=BuildingHeight;

if(any(strcmp(p.UsingDefaults,'BuildingProp')))
    nodesWithBarGraph3d(axHandle,plotting,nCriteria,BuildingHeight, 'colorCycle', p.Results.BuildingColors);
else
    nodesWithBarGraph3d(axHandle,plotting,nCriteria,BuildingHeight,'BuildingProp',p.Results.BuildingProp, 'colorCycle', p.Results.BuildingColors);
end

%% set default view
pltOpts.campos=[7.2964  -17.4457    8.8248];
campos(pltOpts.campos);
% view([18,85]);

%% standardize labels and set up data cursor
archLbls=regularizeLbls(p.Results.DesignLabels,size(plotting,1));
CriteriaLabels=regularizeLbls(criteriaLabelsIn,size(p.Results.criteria,2));

if(length(CriteriaLabels)~=size(p.Results.criteria,2))
    error(['labels dimension mismatch with criteria: num labels: ', num2str(length(CriteriaLabels)), ', num criteria: ', num2str(size(p.Results.criteria,2)),'. also be sure have a different criteria value across a different column (dim 2) in criteria']);
end

dataCursorHandle = datacursormode;
set(dataCursorHandle,'DisplayStyle','window');
set(dataCursorHandle,'UpdateFcn',{@cityplotDataCursor,[plotting,zeros(size(plotting,1),1)],archLbls,CriteriaLabels,p.Results.criteria});

%% spew. ew.
if(~any(strcmp(p.UsingDefaults, 'Spew')))
    spewOptions=ismember({'DesignLabels','CriteriaValues'},p.Results.Spew); % scalable way to check spew options
    spewCell=cell(size(archLbls));

    if(spewOptions(1))
        spewCell=cellfun(@(old, new) [old,new], spewCell, archLbls,'UniformOutput',false);
    end
    if(spewOptions(2))
        if(any(spewOptions(1:1))) % if have already had a spew option, add a seperator character.
            spewCell=cellfun(@(old) [old, ' | '], spewCell,'UniformOutput',false);
        end
        for i=1:size(spewCell,1) % add all criteria and corresponding labels as a line
            for j=1:(size(p.Results.criteria,2)-1)
                spewCell{i}=[spewCell{i}, CriteriaLabels{j}, num2str(p.Results.criteria(i,j)), ','];
            end
            spewCell{i}=[spewCell{i}, CriteriaLabels{j+1}, num2str(p.Results.criteria(i,j+1))]; % omits ending seperator.
        end
    end

    %node spew.
    xrange=range(plotting(:,1));
    yrange=range(plotting(:,2));

    rectWidthX=xrange/60;
    rectWidthY=yrange/60;
    for(i=1:size(plotting,1))
        text(plotting(i,1)+rectWidthX,plotting(i,2)-rectWidthY*1.5,0,spewCell{i});
    end
end

%% reset plot properties.
set(axHandle,'Visible','on');
if(holdState)
    hold(axHandle,'on')
else
    hold(axHandle,'off')
end

return