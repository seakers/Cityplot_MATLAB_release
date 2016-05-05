function [pSet]=paretoFront(costs)
%finds the pareto front of an input set of criteria (costs)
%
%for a multi-criteria optimization problem of the form min(f(x)) a point x is "dominated" if there is another point x' 
%  such that f_i(x')<f_i(x) for all costs f_i. The pareto front is then the set of points which are not dominated
%
%more colloquially, the pareto front is the set of points for which improving any given single "cost" requires 
%  increasing the cost in one or more other "costs"
%
%costs :: a set of criteria/utiliies to compute pareto rankings of. Each component (i.e. cost, nominal utility) goes 
%  down columns and points go across rows. the costs are assumed to be desired to be all minimized. Multiply columns 
%  by -1 before calling this function to maximize
%returns :: a column vector of logical indicies indicating if the given point is in the pareto front
    numArch=size(costs,1);
    pSet=true(numArch,1);
    for(i=1:size(costs,1))
        pSet(i)=all(any(repmat(costs(i,:),numArch-1,1)<costs([1:i-1,i+1:numArch],:),2)); % faster with a kronecker product and crafty indexing, but I'm more memory constrained than anything.
    end
return
