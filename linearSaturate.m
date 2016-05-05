function [saturated]=linearSaturate(mat, lb, ub)
saturated=mat;
saturated(saturated<lb)=lb;
saturated(saturated>ub)=ub;