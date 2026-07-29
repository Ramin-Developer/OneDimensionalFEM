function [q_Type, q_Coeff, load_Coeff, delta, P, numElements] = Read_input

%READ_INPUT Return default solver configuration for the demo run.

% ------------------------ Rigidity Function q(x) ------------------------

% A constant q(x):
q_Type = 'q_Const';
q_Coeff = 1;

% Fractional q(x) with a first degree denominator:
% q_Type = 'q_Frac_With_Denom_1st_Degree';
% q_Coeff = [10 0.01];

% A Fractional q(x) with a second degree denominator:
% q_Type = 'q_Frac_With_Denom_2nd_Degree';
% q_Coeff = [10 0.01];

% An Exponential q(x):
% q_Type = 'Exponential';
% q_Coeff = 1;

% -------------------------- Load Function f(x) --------------------------

% Coefficients of a constant polynomial load:
% load_Coeff = 1;

% Coefficients of a linear polynomial load:
% load_Coeff = [1 2];

% Coefficients of a quadratic polynomial load:
load_Coeff = [1 2 -3];

% ------------------------- Boundary Conditions -------------------------

% Dirichlet condition on the left hand side:
delta = 0;

% Normal Condition on the right hand side:
% For a constant choice of q(x):
P = 0.01;

% Normal Condition on the right hand side:
% For a fractional choice of q(x) with a first degree denoominator:
% P = 1;

% For a fractional choice of q(x) with a second degree denoominator:
% P = 1;

% For an exponential choice of q(x):
% P = 0.01;

% ------------------------------- Meshing -------------------------------

% Number of elements in a uniform meshing:
numElements = [4 8 16];
