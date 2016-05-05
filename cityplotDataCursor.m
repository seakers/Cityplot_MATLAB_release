function output_txt=cityplotDataCursor(~,event_obj, plotting, archLbls, metLbls, metrics)
% cityplotDataCursor function to be used with the data cursor callback to
%   display infromation on cities in the cityplot.
% 
% output_txt=cityplotDataCursor(~, event_obj, plotting archLbls, metLbls, metrics)
%   outputs a cell array of lines of text where the 1st line is the
%   archLbl, the 2nd is a seperator and subsequent lines are labels (metLbls) and
%   values for objectives (metrics). plotting is the locations of designs
%   in the cityplot which is necessary for detecting the clicked design.
%   see MATLAB data cursor about 1st 2 arguments.
%

pos=get(event_obj,'Position');

[~,archI]=min(sum((plotting-repmat(pos,size(plotting,1),1)).^2,2));

output_txt=cell(size(metrics,2)+2,1);
output_txt{1}=archLbls{archI};
output_txt{2}=repmat('-', 1, ceil(length(output_txt{1})*1.2));
for(i=1:size(metrics,2))
    output_txt{i+2}=[metLbls{i},num2str(metrics(archI,i))];
end
return