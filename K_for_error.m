function [G_l] = K_for_error(G, e_max, te, strict)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
s = tf('s');

switch te
    case {'p','posición','posicion','pos'}
        K = (1-e_max)/(evalfr(G, 0)*e_max);
    case {'v', 'velocidad', 'velocity', 'vel'}
        K = 1/(evalfr(minreal(s*G), 0)*e_max);
    case {'a', 'aceleración', 'aceleracion', 'ace'}
        K = 1/(evalfr(minreal(s^2*G), 0)*e_max);
    otherwise
        error('El tipo de error solo puede ser de posición (p), velocidad (v) o aceleración (a).')
end

if(K < 1)
    K = 1;
    strict = false;
end

if(strict)
    K = K+1;
end

K

G_l = K*G;
end

