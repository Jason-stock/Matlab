function [v1] = rangeV(v0,vmin,vmax)
v1 = min(v0, vmax);
v1 = max(v1, vmin);
end

