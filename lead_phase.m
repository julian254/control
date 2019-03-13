function [G_lc, C] = lead_phase(G, e_max, te, strict, PM_min, GM_min)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
s = tf('s');

G_l = K_for_error(G,e_max,te,strict);

bode(G_l)
hold on

if(checkMargins(G_l,PM_min,GM_min, 'inicial'))
    G_lc = G_l;
    return;
end

[~, Pm_act] = margin(G_l)

for theta = 5:5:(90-PM_min+Pm_act)
    psi = PM_min - Pm_act + theta
    
    b = (1+sin(psi*pi()/180))/(1-sin(psi*pi()/180))
    
    Wpm = freq_from_mag(G_l,1/sqrt(b))
    
    T = 1/(sqrt(b)*Wpm)
    
    C = (1+b*T*s)/(1+T*s);
    G_lc = G_l*C;
    bode(G_lc)
    
    if(b<=1)
        warning('No sirve una red de adelanto.')
    end
    
    if(checkMargins(G_lc,PM_min,GM_min))
        break;
    end
end

checkMargins(G_lc,PM_min,GM_min,'final');

hold off

end

