function [lbls]=regularizeLbls(inLbls,targetSize)
if(isempty(inLbls))
    lbls=arrayfun(@(x) ' ', 1:targetSize,'UniformOutput',false);
elseif(ischar(inLbls))
    lbls=mat2cell(inLbls,ones(size(inLbls,1),1),size(inLbls,2));
elseif(isnumeric(inLbls))
    lbls=regularizeLbls(num2str(inLbls),targetSize); % now is char.
elseif(islogical(inLbls))
    lbls=regularizeLbls(num2str(real(inLbls)),targetSize);
elseif(iscell(inLbls))
    lbls=inLbls;
    for indx=1:numel(inLbls)
        if(isempty(inLbls{indx}))
            lbls{indx}=' ';
        elseif(isnumeric(inLbls{indx}) || islogical(inLbls{indx}))
            lbls{indx}=num2str(inLbls{indx});
        else % assume string or good enough
            lbls{indx}=inLbls{indx};
        end
    end
else
    error('cannot parse input labels with regularize Lbls');
end