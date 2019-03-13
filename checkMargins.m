function [cumple] = checkMargins(G, PM_min, GM_minDB, war)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

 if nargin ~= 4
      war = '';
 end
 
 GM_min = 10^(GM_minDB/20.0);

[Gm_new, Pm_new] = margin(G);
cumple = Gm_new >= GM_min && Pm_new >= PM_min;

if(cumple)
    if (strcmp(war,'inicial'))
        disp('No se necesita compensador.')
    end
else
    if (strcmp(war,'final'))
        warning('El compensador no cumplió con las margenes.')
    end
end
end

