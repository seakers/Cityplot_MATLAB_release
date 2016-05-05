function [filterDist]=distToTargetConn(distances, targetConn)
% distToTargetConn filters distances such that the number of distances will
%    be as close as possible to targetConn without going over.
%
% filterDist=distToTargetConn(distances, targetConn) outputs a E x 3
%    matrix where E' is <= targetConn. the 1st and 2nd columns correspond
%    to endpoint edges (or subscript indicies in a full distance matrix)
%    and the 3rd column is the distance values. input distances is an NxN
%    nonnegative symmetric matrix which represents distances between locations.
%    targetConn is simply a cap on the number of edges the filterDist will have. 
%    Observe that if there are a large number of duplicate distances when
%    targetConn is "crossed" then none of the duplicate distance edges will
%    make it to filterDist. If E<targetConn will then have
%    filterDist=distances if distances are unique and E>=targetConn then E' = targetConn
%
p=inputParser();
addRequired(p, 'distances', @isnumeric);
addOptional(p, 'targetConn', ceil(size(distances,1)*log(size(distances,1))), @(x) isnumeric(x) && isequal(fix(x),x));

parse(p,distances, targetConn);

dist=p.Results.distances;
relevant=triu(dist,1)>0;
relevantDist=dist(relevant);

[sortRDist]=sort(relevantDist,'ascend');

maxDist=sortRDist(min(length(sortRDist),p.Results.targetConn+1));

filter=dist<maxDist;
andFilter=filter & relevant;

indx=1:numel(dist);
[indx1,indx2]=ind2sub(size(dist),indx(andFilter(:)));
distLine=dist(:);
filterDist=[indx1',indx2',distLine(andFilter(:))];