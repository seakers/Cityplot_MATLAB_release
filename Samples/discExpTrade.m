addpath('..') % Adds Cityplot codes. Assuming use default folder layout and are in running from default folder. Adjust if running from somewhere else or installed elsewhere.

%% parameters 
denLen=5; % N. Knerr, D. Selva "Cityplot..." Journal of Mechanical Design uses 10, although this takes a couple minutes to enumerate and test.

%% currently in paper
w1=denLen.^(-([1:denLen]-1)/3);
w2=denLen.^(-(denLen-[1:denLen])/3);
w=[w1',w2'];

altClrMap=flipud(colormap('cool'));

%% generate and calculate designs.
dens=reshape(str2num(reshape(dec2bin(0:(2^denLen-1)),denLen*2^denLen,1)),2^denLen,denLen);

mets=[dens*w,denLen-sum(dens,2)];

isP=paretofront(mets);
pDens=dens(isP,:);
pMets=mets(isP,:);

criteriaLbls={'weight1 sum: ', 'weight2 sum: ', 'numberOfOnes: '};

%% simplest cityplot call. 
% solves the above problem as minimization so that smaller skyscrapers are preferred.
% not necessary, but prevent overwriting an existing figure.
cityplot3d(squareform(pdist(real(pDens))), pMets);

%% plot cityplot--taxicab distance
% notice the -pMets. this makes larger skyscrapers preferred.
% uses sammon mapping instead of classical multidimensional scaling
% also inputs labels for selecting designs with data cursor.
% uses alternative color map for roads.
dist=squareform(pdist(real(pDens),'cityblock'));
cityplot3d(figure(), dist,-pMets,'DesignLabels',pDens, 'CriteriaLabels', criteriaLbls,'MdscaleOptArgs',{'Criterion','sammon'}, 'RoadColors', altClrMap);

%% plot cityplot--weight decisions by weighting of 1st objective
% notice the -pMets. this makes larger skyscrapers preferred.
% computes distances by weighting importance in difference in design decisions by the weighing vector for the 1st objective.
compIdx=nchoosek(1:size(pDens,1),2);
weightedDist_T=real(xor(pDens(compIdx(:,1),:),pDens(compIdx(:,2),:))*(w1'));
dist2_T=zeros(size(pDens,1));
dist2_T(sub2ind(size(dist2_T),compIdx(:,1),compIdx(:,2)))=weightedDist_T;
dist2_T=dist2_T+dist2_T';

ax_h=figure();
% customRoadLim=ceil((176/2)^2); % N. Knerr, D. Selva "Cityplot..." Journal of Mechanical Design uses this value
customRoadLim=ceil((26/2)^2);
cityplot3d(ax_h,dist2_T,-pMets,'DesignLabels',pDens,'CriteriaLabels', criteriaLbls, 'MdscaleOptArgs',{'Criterion','sammon'}, 'RoadLimit', customRoadLim, 'RoadColors', altClrMap);