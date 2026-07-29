function [K_Elem_Lin, b_Elem_Lin, K_Elem_Cub, b_Elem_Cub] = ...
        Elem_Cont( h, elem_No, q_Func, load_Func, ...
        psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol )

%ELEM_CONT Compute linear and cubic element contributions.

% Set up element contribution for the linear basis-functions:
[K_Elem_Lin, b_Elem_Lin] = Cal_Cont( 1, h, elem_No, q_Func, ...
    psi_Lin, psi_Prime_Lin, load_Func, RelTol);

% Set up element contribution for the cubic basis-functions:
[K_Elem_Cub, b_Elem_Cub] = Cal_Cont( 3, h, elem_No, ...
    q_Func, psi_Cub, psi_Prime_Cub, load_Func, RelTol );


function [K_Elem, b_Elem] = Cal_Cont( basis_Degree, h, elem_No, ...
    q_Func, psi, psi_Prime, load_Func, RelTol)

basis_Count = basis_Degree + 1;
K_Elem = zeros(basis_Count, basis_Count);
b_Elem = zeros(basis_Count, 1);

% Calculate entries of element matrix and element load:
for i = 1:basis_Count
    for j = i:basis_Count

        % Define stiffness integrand in the local coordinates:
        stiff_Elem_Int = @(y) ...
            ( 1/h ) .* q_Func( ( elem_No - 1 + y ) * h ) ...
            .* psi_Prime{i}(y) .* psi_Prime{j}(y);

        % Integrate over the element:
        K_Elem(i, j) = quadgk(stiff_Elem_Int, 0, 1, 'RelTol', RelTol);
        if j ~= i
            K_Elem(j, i) = K_Elem(i, j);
        end
    end;

	% Define load integrand in the local coordinates:
	load_Int = @(y) h * load_Func( ( elem_No - 1 + y ) * h ) .* psi{i}(y);

    % Integrate over the element:
    b_Elem(i) = quadgk(load_Int, 0, 1, 'RelTol', RelTol);
end;
