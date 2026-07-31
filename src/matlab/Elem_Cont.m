function [K_Elem_Lin, b_Elem_Lin, K_Elem_Cub, b_Elem_Cub, quadratureMode] = ...
        Elem_Cont( h, elem_No, q_Func, load_Func, ...
        psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol )

%ELEM_CONT Compute linear and cubic element contributions.

assert(isnumeric(h) && isscalar(h) && h > 0, ...
    'Elem_Cont:InvalidMeshSize', ...
    'h must be a positive numeric scalar.');
assert(isnumeric(elem_No) && isscalar(elem_No) && elem_No > 0 && mod(elem_No, 1) == 0, ...
    'Elem_Cont:InvalidElementNumber', ...
    'elem_No must be a positive integer scalar.');
assert(isa(q_Func, 'function_handle') && isa(load_Func, 'function_handle'), ...
    'Elem_Cont:InvalidFunctions', ...
    'q_Func and load_Func must be function handles.');
assert(iscell(psi_Lin) && iscell(psi_Prime_Lin) && iscell(psi_Cub) && iscell(psi_Prime_Cub), ...
    'Elem_Cont:InvalidBasis', ...
    'All basis inputs must be cell arrays.');
assert(isnumeric(RelTol) && isscalar(RelTol) && RelTol > 0, ...
    'Elem_Cont:InvalidRelTol', ...
    'RelTol must be a positive numeric scalar.');
assert(isfinite(RelTol), ...
    'Elem_Cont:InvalidRelTol', ...
    'RelTol must be finite.');

[KLin16, bLin16, KCub16, bCub16] = Gauss_Cont( ...
    16, h, elem_No, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub);
[KLin32, bLin32, KCub32, bCub32] = Gauss_Cont( ...
    32, h, elem_No, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub);

if Contributions_Agree( ...
        {KLin16, bLin16, KCub16, bCub16}, ...
        {KLin32, bLin32, KCub32, bCub32}, RelTol)
    K_Elem_Lin = KLin32;
    b_Elem_Lin = bLin32;
    K_Elem_Cub = KCub32;
    b_Elem_Cub = bCub32;
    quadratureMode = 'fixed-gauss';
    return;
end

[K_Elem_Lin, b_Elem_Lin] = Cal_Cont( ...
    1, h, elem_No, q_Func, psi_Lin, psi_Prime_Lin, load_Func, RelTol);
[K_Elem_Cub, b_Elem_Cub] = Cal_Cont( ...
    3, h, elem_No, q_Func, psi_Cub, psi_Prime_Cub, load_Func, RelTol);
quadratureMode = 'adaptive';

function [KLin, bLin, KCub, bCub] = Gauss_Cont( ...
    order, h, elemNo, qFunc, loadFunc, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub)

[nodes, weights] = Gauss_Rule(order);
x = (elemNo - 1 + nodes) .* h;
qValues = reshape(qFunc(x), [], 1);
loadValues = reshape(loadFunc(x), [], 1);
[basisLin, derivativeLin] = Evaluate_Basis(psiLin, psiPrimeLin, nodes);
[basisCub, derivativeCub] = Evaluate_Basis(psiCub, psiPrimeCub, nodes);
weightedQ = weights .* qValues ./ h;
weightedLoad = weights .* loadValues .* h;
KLin = bsxfun(@times, derivativeLin, weightedQ.') * derivativeLin.';
bLin = basisLin * weightedLoad;
KCub = bsxfun(@times, derivativeCub, weightedQ.') * derivativeCub.';
bCub = basisCub * weightedLoad;

function [basisValues, derivativeValues] = Evaluate_Basis(psi, psiPrime, nodes)

basisCount = numel(psi);
basisValues = zeros(basisCount, numel(nodes));
derivativeValues = zeros(basisCount, numel(nodes));
for idx = 1:basisCount
    basisValues(idx, :) = reshape(psi{idx}(nodes), 1, []);
    derivativeValues(idx, :) = reshape(psiPrime{idx}(nodes), 1, []);
end

function [nodes, weights] = Gauss_Rule(order)

persistent nodes16 weights16 nodes32 weights32
if isempty(nodes16)
    [nodes16, weights16] = Build_Gauss_Rule(16);
    [nodes32, weights32] = Build_Gauss_Rule(32);
end
if order == 16
    nodes = nodes16;
    weights = weights16;
else
    nodes = nodes32;
    weights = weights32;
end

function [nodes, weights] = Build_Gauss_Rule(order)

indices = (1:order - 1)';
offDiagonal = indices ./ sqrt(4 .* indices.^2 - 1);
jacobiMatrix = diag(offDiagonal, 1) + diag(offDiagonal, -1);
[vectors, values] = eig(jacobiMatrix);
[nodes, sortIndex] = sort(diag(values));
weights = 2 .* vectors(1, sortIndex).^2;
nodes = (nodes + 1) ./ 2;
weights = weights(:) ./ 2;

function agree = Contributions_Agree(lowOrder, highOrder, relTol)

agree = true;
for idx = 1:numel(lowOrder)
    scale = max(1, max(abs(highOrder{idx}(:))));
    difference = max(abs(lowOrder{idx}(:) - highOrder{idx}(:)));
    if difference > 5 * relTol * scale
        agree = false;
        return;
    end
end


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
