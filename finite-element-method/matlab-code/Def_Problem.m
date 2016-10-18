function [h, sol_Size, q_Function, load_Func, ...
    x, u_FEM_Lin, u_FEM_Cub, u_Exact, RelTol] = ...
    Def_Problem( N, q_Type, load_Coeff, q_Coeff, delta, P )

% A uniform discretizatin
h = 1 ./ N;

% No. of points in the final plot:
sol_Size = 2^10;

% Evaluation points in the final solution
x = linspace(0, 1, sol_Size + 1 )';

% Initialize FEM-solution:
u_FEM_Lin = cell( 1, length(N) );
u_FEM_Cub = cell( 1, length(N) );

% Relative tolerance for numerical integration:
RelTol = 1e-12;

% Convert coefficients of the polynomial load to a general
% quadratic polynomial:
load_Degree = length(load_Coeff) - 1;
if load_Degree == 0
    load_Coeff = [load_Coeff 0 0];
elseif load_Degree == 1
    load_Coeff = [load_Coeff 0];
end;

if strcmpi(q_Type, 'q_Const') == 1
    [q_Function, load_Func, u_Exact] = ...
    Def_q_Const( load_Coeff, q_Coeff, delta, P );

elseif strcmpi(q_Type, 'q_Frac_With_Denom_1st_Degree') == 1
    [q_Function, load_Func, u_Exact] = ...
    Def_q_Frac_Denom_1st_Degree( load_Coeff, q_Coeff, delta, P );

elseif strcmpi(q_Type, 'q_Frac_With_Denom_2nd_Degree') == 1
    [q_Function, load_Func, u_Exact] = ...
    Def_q_Frac_Denom_2nd_Degree( load_Coeff, q_Coeff, delta, P );

elseif strcmpi(q_Type, 'Exponential') == 1
    [q_Function, load_Func, u_Exact] = ...
    Def_q_Exp( load_Coeff, q_Coeff, delta, P );
end;

function [q_Function, load_Func, u_Exact] = ...
    Def_q_Const( load_Coeff, q_Coeff, delta, P )

d = zeros(1, 5);
q_Function = @(x) q_Coeff(1)*x.^0;
load_Func = @(x) load_Coeff(1) + load_Coeff(2) * x + load_Coeff(3) * x.^2;

d(1) = delta;

d(2) = (P + load_Coeff(1) + load_Coeff(2) / 2 ...
    + load_Coeff(3) / 3) / q_Coeff(1);

d(3) = -load_Coeff(1) / ( 2 * q_Coeff(1) );

d(4) = -load_Coeff(2) / ( 6 * q_Coeff(1) );

d(5) = -load_Coeff(3) / ( 12 * q_Coeff(1) );

u_Exact = @(x) d(1) + d(2)*x + d(3)*x.^2 + d(4)*x.^3 + d(5)*x.^4;

function [q_Function, load_Func, u_Exact] = ...
    Def_q_Frac_Denom_1st_Degree( load_Coeff, q_Coeff, delta, P )

d = zeros(1, 6);
q_Function = @(x) q_Coeff(1) ./ ( x + q_Coeff(2) );
load_Func = @(x) load_Coeff(1) + load_Coeff(2) * x + load_Coeff(3) * x.^2;

d(1) = delta;

d(2) = q_Coeff(2) * P / q_Coeff(1) ...
       + q_Coeff(2) * load_Coeff(1) / q_Coeff(1) ...
       + q_Coeff(2) * load_Coeff(2) / ( 2 * q_Coeff(1) ) ...
       + q_Coeff(2) * load_Coeff(3) / ( 3 * q_Coeff(1) );

d(3) = P / ( 2 * q_Coeff(1) ) ...
    + ( 1 - q_Coeff(2) ) * load_Coeff(1) / ( 2 * q_Coeff(1) ) ...
    + load_Coeff(2) / ( 4 * q_Coeff(1) ) ...
    + load_Coeff(3) / ( 6 * q_Coeff(1) );        

d(4) = - load_Coeff(1) / ( 3 * q_Coeff(1) ) ...
    - q_Coeff(2) * load_Coeff(2) / ( 6 * q_Coeff(1) );

d(5) = - load_Coeff(2) / ( 8 * q_Coeff(1) ) ...
    - q_Coeff(2) * load_Coeff(3) / ( 12 * q_Coeff(1) );

d(6) = -load_Coeff(3) / ( 15 * q_Coeff(1) );

u_Exact = @(x) d(1) + d(2)*x + d(3)*x.^2 + d(4)*x.^3 + ...
    d(5)*x.^4 + d(6)*x.^5;

function [q_Function, load_Func, u_Exact] = ...
    Def_q_Frac_Denom_2nd_Degree( load_Coeff, q_Coeff, delta, P )
    
d = zeros(1, 7);
q_Function = @(x) q_Coeff(1) ./ ( x.^2 + q_Coeff(2) );    
load_Func = @(x) load_Coeff(1) + load_Coeff(2) * x ...
    + load_Coeff(3) * x.^2;

d(1) = delta;

d(2) = q_Coeff(2) * P / q_Coeff(1) + ...
    q_Coeff(2) * load_Coeff(1) / q_Coeff(1) + ...
    q_Coeff(2) * load_Coeff(2) / ( 2 * q_Coeff(1) ) + ...
    q_Coeff(2) * load_Coeff(3) / ( 3 * q_Coeff(1) );

d(3) = -q_Coeff(2) * load_Coeff(1) / ( 2 * q_Coeff(1) );

d(4) = P / ( 3 * q_Coeff(1) ) ...
    + load_Coeff(1) / ( 3 * q_Coeff(1) ) ...
    + ( 1 - q_Coeff(2) ) * load_Coeff(2) / ( 6 * q_Coeff(1) ) ...
    + load_Coeff(3) / ( 9 * q_Coeff(1) );

d(5) = -load_Coeff(1) / ( 4 * q_Coeff(1) ) ...
    - q_Coeff(2) * load_Coeff(3) / ( 12 * q_Coeff(1) );

d(6) = - load_Coeff(2) / ( 10 * q_Coeff(1) ); 

d(7) = - load_Coeff(3) / ( 18 * q_Coeff(1) );

u_Exact = @(x) d(1) + d(2)*x + d(3)*x.^2 + d(4)*x.^3 ...
    + d(5)*x.^4 + d(6)*x.^5 + d(7)*x.^6;

function [q_Function, load_Func, u_Exact] = ...
        Def_q_Exp( load_Coeff, q_Coeff, delta, P )

% An exponential q(x) and a general up to 2nd degree load polynomial:
d = zeros(1, 5);
alpha = q_Coeff(1);
q_Function = @(x) exp( -alpha * x );
load_Func = @(x) load_Coeff(1) + load_Coeff(2)*x + load_Coeff(3).*x.^2;

d(1) = delta ...
    - load_Coeff(1) / alpha ...
    - load_Coeff(2) / (2 * alpha) ...
    - load_Coeff(3) / (3 * alpha) ...
    - load_Coeff(1) / alpha^2 ...
    + load_Coeff(2) / alpha^3 ...
    - 2 * load_Coeff(3) / alpha^4 ...
    - P / alpha;

d(2) = load_Coeff(1) / alpha ...
    + load_Coeff(2) / ( 2 * alpha )...
    + load_Coeff(3) / (3 * alpha) ...
    + load_Coeff(1) / alpha^2 ...
    - load_Coeff(2) / alpha^3 ...
    + 2 * load_Coeff(3) / alpha^4 + P/alpha;

d(3) = - load_Coeff(1) / alpha ...
    + load_Coeff(2) / alpha^2 ...
    - 2 * load_Coeff(3) / alpha^3;

d(4) = - load_Coeff(2) / ( 2 * alpha ) ...
    + load_Coeff(3) / alpha^2;

d(5) = - load_Coeff(3) / ( 3 * alpha );

u_Exact = @(x) d( 1 ) ...
    + ( d(2) + d(3)*x + d(4)*x.^2 + d(5)*x.^3 ) .* exp(alpha * x);

