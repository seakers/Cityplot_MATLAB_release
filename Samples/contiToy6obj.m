addpath('..') % Adds Cityplot codes. Assuming use default folder layout and are in running from default folder. Adjust if running from somewhere else or installed elsewhere.

%% define objective function
indx=1:5;
[iX,iY]=meshgrid(indx,indx);

dpMat=iX.^iY;
f=@(x) [sum(sum((dpMat+.5).*((repmat(x,5,1)./iX).^iY-1),2).^2,1);
        (x(1)-1)^2+dot(indx(2:end),(2*x(2:end).^2-x(1:(end-1))).^2);
        sum(100*(x(2:end)-x(1:(end-1)).^2).^2+(x(1:(end-1))-1).^2);
        100*norm(x+3*ones(1,5),1)^4;
        100*norm(x+[-1,-1,0,1,1])^4;
        dot(2.5*indx-2.5,abs(x))];

load('continuous_inPaperV5_0.mat') % loads precomputed results of a genetic algorithm for the design tradespace sample.

divisor=3.25;
altClrMap=hsv2rgb([linspace(0,2/3,64)',ones(64,2)]);

%% make cityplot, min.
figure();
cityplot3d(squareform(pdist(pArchs)),vals,'DesignLabels',pArchs, 'RoadLimit', ceil((targetNum/divisor)^2), 'RoadColors', altClrMap); % -vals makes into a maximization so want big cities with skyscrapers
view(1.353421485022669e+02, 68.585957777759063) % N. Knerr, D. Selva "Cityplot..." Journal of Mechanical Design uses these angles, though you are free to modify them with the cursor.

%% make cityplot
% plots the cityplot but instead multiplies design criteria by -1 so that larger skyscrapers are objectives that a design does well on.
figure(); 
cityplot3d(squareform(pdist(pArchs)),-vals,'DesignLabels',pArchs, 'RoadLimit', ceil((targetNum/divisor)^2), 'RoadColors', altClrMap); % -vals makes into a maximization so want big cities with skyscrapers
view(1.473421485022669e+02, 70.585957777759063)