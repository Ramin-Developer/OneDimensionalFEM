function [K_Elem_Lin, b_Elem_Lin, K_Elem_Cub, b_Elem_Cub] = ...
        Elem_Cont( h, elem_No, q_Func, load_Func, ...
        psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol )

% Set up element contribution for the linear basis-functions:
[K_Elem_Lin, b_Elem_Lin] = Cal_Cont( 1, h, elem_No, q_Func, ...
    psi_Lin, psi_Prime_Lin, load_Func, RelTol);

% Set up element contribution for the cubic basis-functions:
[K_Elem_Cub, b_Elem_Cub] = Cal_Cont( 3, h, elem_No, ...
    q_Func, psi_Cub, psi_Prime_Cub, load_Func, RelTol );


function [K_Elem, b_Elem] = Cal_Cont( basis_Degree, h, elem_No, ...
    q_Func, psi, psi_Prime, load_Func, RelTol)

% Initialize the stiffness matrix and the load vector for the linear and
% the cubic case:
K_Elem = zeros(2, 2);
b_Elem = zeros(2, 1);
if basis_Degree == 3
    K_Elem = zeros(4, 4);
    b_Elem = zeros(4, 1);
end;

% Calculate entries of element matrix and element load:
for i = 1:1:basis_Degree + 1
    for j = 1:1:basis_Degree + 1

        % Define stiffness integrand in the local coordinates:
        stiff_Elem_Int = @(y) ...
            ( 1/h ) .* q_Func( ( elem_No - 1 + y ) * h ) ...
            .* psi_Prime{i}(y) .* psi_Prime{j}(y);
        
        % Integrate over the element:
        K_Elem(i, j) = quadgk(stiff_Elem_Int, 0, 1, 'RelTol', RelTol);
    end;
    
	% Define load integrand in the local coordinates:
	load_Int = @(y) h * load_Func( ( elem_No - 1 + y ) * h ) .* psi{i}(y);
    
    % Integrate over the element:
    b_Elem(i) = quadgk(load_Int, 0, 1, 'RelTol', RelTol);
end;
