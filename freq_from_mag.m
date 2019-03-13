function [w] = freq_from_mag(G, amp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[mag, ~, w_out] = bode(G,10.^(-1.5:0.0001:3));

for i = 2:length(mag)
    mag0 = mag(i-1);
    mag1 = mag(i);
    
    if(mag0 < amp && amp <= mag1)
        w = w_out(i);
        return;
    end
    
    if(mag1 < amp && amp <= mag0)
        w = w_out(i-1);
        return;
    end
end
end

