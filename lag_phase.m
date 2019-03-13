function [G_lc, C] = lag_phase(G, e_max, te, strict, PM_min, GM_min)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
s = tf('s');

G_l = K_for_error(G,e_max,te,strict);

if(checkMargins(G_l,PM_min,GM_min, 'inicial'))
    G_lc = G_l;
    return;
end

phi = PM_min + 6 - 180

Wpm = freq_from_phase(G_l, phi)

a = 1/abs(freqresp(G_l,Wpm))

T = 10/(a*Wpm)

C = (1+a*T*s)/(1+T*s)

G_lc = G_l*C;

if(a<=0 || a>=1)
   warning('No sirve una red de atraso.')
end

checkMargins(G_lc,PM_min,GM_min,'final');

bode(G_l)
hold on
bode(G_lc)
hold off

end

