function [polos] = findPoles(A, B, varargin)
%FINDPOLES iterate different combinations of poles, looking for those that
%meet the given restrictions.
%   SYSTEM PARAMETERS
%   A, B, C are the matrix of state-space model of system.
%   Br is the B in closed-loop. Default: B.
%
%   r_direct is the constant that multiply the reference signal to the
%   control signal. (default: 0).
%
%   RESTRICTIONS
%
%   t_s is the max settling time.
%
%   u_max_max is the maximum value that the control signal can take.
%   u_max_min is the minimum maximum value of the control signal.
%
%   Example: if u_max_max = 5 and u_max_min = 4.5, the control signal would
%   have the maximum between 4.5 and 5.
%
%   u_min_min is the minimum value that the control signal can take.
%   u_min_max is the maximum minimum value of the control signal.
%
%   w_min (rad/s) and f_min (Hz) are the frequency that have, at least, a magnitude of
%   db_min (default: -3 dB). w_min has priority.
%
%   zeros is a vector of real values. for each value, a pole of smaller
%   magnitude is placed.
%
%   ITERATIONS
%
%   minP is the minimum magnitude of the poles.
%   maxP is the maximum magnitude of the poles.
%   m is the number of values that are tested for each pole. (default: 10)

p = inputParser;
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
squaredMatrix = @(A) min(size(A) == size(A'));
addRequired(p,'A',squaredMatrix);
addRequired(p,'B');
addRequired(p,'C');
addOptional(p,'Br',B,@(x) min(size(x)==size(B)));
addParameter(p,'r_direct',0);

addParameter(p,'t_s',Inf,validScalarPosNum);
addParameter(p,'u_max_max',Inf,validScalarPosNum);
addParameter(p,'u_max_min',-Inf);
addParameter(p,'u_min_max',Inf);
addParameter(p,'u_min_min',-Inf);
addParameter(p,'f_min',0,validScalarPosNum);
addParameter(p,'w_min',0,validScalarPosNum);
addParameter(p,'db_min',-3);
addParameter(p,'zeros',[]);

addParameter(p,'minP',0.5,validScalarPosNum);
addParameter(p,'maxP',15,validScalarPosNum);
addParameter(p,'m',10,validScalarPosNum);
parse(p,A,B,varargin{:});

zeros = p.Results.zeros;
minP = p.Results.minP;
m = p.Results.m;
r_direct = p.Results.r_direct;

t_s = p.Results.t_s;
u_max_max = p.Results.u_max_max;
u_max_min = p.Results.u_max_min;
u_min_max = p.Results.u_min_max;
u_min_min = p.Results.u_min_min;
db_min = p.Results.db_min;

Bf = p.Results.Br;
Cf = p.Results.C;

n = length(A); %% número de polos
nz = length(zeros); %% coloca al menos un polo antes de cada cero para cancelar sobrepicos.

range = p.Results.maxP-minP;

if(p.Results.w_min == 0)
    w_min = 2*pi*p.Results.f_min;
end

polosM = nchoosek(-(0:m)*range/m-minP,n-nz);

for i = zeros
    sz = size(polosM);
    polosM = repmat(polosM,m,1);
    
    polosM = [polosM repelem((1:m)*i/4/m+3*i/4,sz(1))'];
    
end

%disp('combinaciones generadas')

min_max_u = Inf;

for polosT = polosM.'
    polos = polosT';
    
    K = place(A,B,polos);
    
    Af = A - B*K;
    
    [min_u, max_u] = bounds(step(ss(Af,Bf,-K,r_direct)));
    
    if(max_u < min_max_u && max_u >= u_max_min)
        min_max_u = max_u;
        polos_min_max_u = polos;
    end
    
    if(max_u <= u_max_max && max_u >= u_max_min && min_u >= u_min_min && min_u <= u_min_max)
        sys = ss(Af,Bf,Cf,0);
        S = stepinfo(sys);
        if(S.SettlingTime < t_s ...
                && abs(evalfr(sys,w_min*1i)) >= 10^(db_min/20))
            return;
        end
    end
    
end

%mag = abs(evalfr(ss(Af,Bf,Cf,0),w_min*1i));

warning('No se encontraron polos que cumplan los requisitos. Se devuelve un resultado que cumpla la restrición del máximo de la señal de control.')

% disp('Mejor resultado:')
% disp(min_max_u)
% disp(polos_min_max_u)

polos = polos_min_max_u;

end

