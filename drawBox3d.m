% posVect dimVect is a set of column vectors [[x;y;z] ,[x;y;z], ...]
% representing position and length respetively of the box.
% for varargin, see patch properties except position.
function drawBox3d(posVect,dimVect,varargin)
% drawBox3d draws rectangular prisms growing from the ground plane in the 
%   current figure.
% 
% drawBox3d(posVect, dimVect) plots prisms at locations [posVect(i,:), 0]
%    for each i. each prism is given with dimensions dimVect and the prism
%    grows in the positive direction from [posVect(i,:), 0] in each
%    dimension.
% 
% drawBox3d(posVect, dimVect, opt1str, opt1val,...) passes the arguments to
%    for altering the patch properties of the drawn prisms. see fill3 for
%    all options and doc patch properties for the common ones.
%
    if(numel(posVect)~=3 || numel(dimVect)~=3)
        if(size(posVect,2)~=size(dimVect,2))
            error('dimensions and positions must match up for drawing multiple rectangles');
        end
        if((size(posVect,1)~=3 || size(dimVect,1)~=3))
            error('3d plot requires 3d columns as input');
        end
    elseif(size(posVect,1)~=3)
            drawBox3d(posVect',dimVect,varargin{:});
    elseif(size(dimVect,1)~=3)
            drawBox3d(posVect,dimVect',varargin{:});
    else
        for i=1:size(posVect,2)
            endOpts=repmat(posVect(:,i),1,2)+[zeros(3,1),dimVect(:,i)];
            [xi,yi,zi]=meshgrid(endOpts(1,:),endOpts(2,:), endOpts(3,:));

            hold on
            fill3(pOrd(xi(:,:,1)),pOrd(yi(:,:,1)),pOrd(zi(:,:,1)),'k',varargin{:}); % black is the standards-recognized universal standard box color. Approved by the American association of box drawers.
            fill3(pOrd(xi(:,:,2)),pOrd(yi(:,:,2)),pOrd(zi(:,:,2)),'k',varargin{:}); % use 'FaceColor', 'somethingElse' to get different colored boxes
            fill3(pOrd(xi(:,1,:)),pOrd(yi(:,1,:)),pOrd(zi(:,1,:)),'k',varargin{:});
            fill3(pOrd(xi(:,2,:)),pOrd(yi(:,2,:)),pOrd(zi(:,2,:)),'k',varargin{:});
            fill3(pOrd(xi(1,:,:)),pOrd(yi(1,:,:)),pOrd(zi(1,:,:)),'k',varargin{:});
            fill3(pOrd(xi(2,:,:)),pOrd(yi(2,:,:)),pOrd(zi(2,:,:)),'k',varargin{:});
        end
    end
return

function vect=pOrd(mat)
    vect=squeeze(mat([1,2,4,3]));
return
