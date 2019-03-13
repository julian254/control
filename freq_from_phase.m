function [w] = freq_from_phase(G, phi)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[~, phase, w_out] = bode(G,10.^(-1.5:0.0001:3));

for i = 2:length(phase)
    fase0 = phase(i-1);
    fase1 = phase(i);
    
    if(fase0 < phi && phi <= fase1)
        w = w_out(i);
        return;
    end
    
    if(fase1 < phi && phi <= fase0)
        w = w_out(i-1);
        return;
    end
end
end

