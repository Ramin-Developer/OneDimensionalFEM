function tests = test_independent_element_oracles
%TEST_INDEPENDENT_ELEMENT_ORACLES Verify assembly against independent oracles.

tests = functiontests(localfunctions);
end

function testConstantElementContributionsMatchClosedForm(~)
h = 0.25;
qValue = 2;
loadValue = 3;
[psiLin, psiPrimeLin, psiCub, psiPrimeCub] = Def_FEM_Func;

[KLin, bLin, KCub, bCub] = Elem_Cont( ...
    h, 2, @(x) qValue + 0 .* x, @(x) loadValue + 0 .* x, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, 1e-12);

expectedKLin = qValue / h * [1 -1; -1 1];
expectedBLin = h * loadValue * [1/2; 1/2];
expectedKCub = qValue / h * [ ...
    6/5 -6/5 1/10 1/10; ...
    -6/5 6/5 -1/10 -1/10; ...
    1/10 -1/10 2/15 -1/30; ...
    1/10 -1/10 -1/30 2/15];
expectedBCub = h * loadValue * [1/2; 1/2; 1/12; -1/12];

assert(max(abs(KLin(:) - expectedKLin(:))) < 1e-12);
assert(max(abs(bLin(:) - expectedBLin(:))) < 1e-12);
assert(max(abs(KCub(:) - expectedKCub(:))) < 1e-12);
assert(max(abs(bCub(:) - expectedBCub(:))) < 1e-12);
end

function testAllRigidityFamiliesMatchFixedGaussOracle(~)
qFunctions = { ...
    @(x) 2 + 0 .* x, ...
    @(x) 3 ./ (x + 2), ...
    @(x) 3 ./ (x.^2 + 2), ...
    @(x) exp(-0.7 .* x) ...
};
meshCases = [1/2 1; 1/4 3];
loadFunc = @(x) 1 + 2 .* x - 3 .* x.^2;
[psiLin, psiPrimeLin, psiCub, psiPrimeCub] = Def_FEM_Func;

for qIdx = 1:numel(qFunctions)
    for meshIdx = 1:size(meshCases, 1)
        h = meshCases(meshIdx, 1);
        elemNo = meshCases(meshIdx, 2);
        [KLin, bLin, KCub, bCub] = Elem_Cont( ...
            h, elemNo, qFunctions{qIdx}, loadFunc, ...
            psiLin, psiPrimeLin, psiCub, psiPrimeCub, 1e-12);
        [expectedKLin, expectedBLin] = FixedGaussElementOracle( ...
            1, h, elemNo, qFunctions{qIdx}, loadFunc);
        [expectedKCub, expectedBCub] = FixedGaussElementOracle( ...
            3, h, elemNo, qFunctions{qIdx}, loadFunc);

        assert(max(abs(KLin(:) - expectedKLin(:))) < 1e-11);
        assert(max(abs(bLin(:) - expectedBLin(:))) < 1e-11);
        assert(max(abs(KCub(:) - expectedKCub(:))) < 1e-11);
        assert(max(abs(bCub(:) - expectedBCub(:))) < 1e-11);
    end
end
end

function testManufacturedSolutionsCoverAllFamiliesAndBoundaryData(~)
models = { ...
    {@(x) 2 + 0 .* x, @(x) 0 .* x}, ...
    {@(x) 3 ./ (x + 2), @(x) -3 ./ (x + 2).^2}, ...
    {@(x) 3 ./ (x.^2 + 2), @(x) -6 .* x ./ (x.^2 + 2).^2}, ...
    {@(x) exp(-0.7 .* x), @(x) -0.7 .* exp(-0.7 .* x)} ...
};
uExact = @(x) 1 + x + x.^2;
uPrime = @(x) 1 + 2 .* x;
delta = uExact(0);
numElements = [4 8];

for modelIdx = 1:numel(models)
    qFunc = models{modelIdx}{1};
    qPrime = models{modelIdx}{2};
    loadFunc = @(x) -(qPrime(x) .* uPrime(x) + 2 .* qFunc(x));
    P = qFunc(1) * uPrime(1);
    errorsLin = zeros(size(numElements));
    errorsCub = zeros(size(numElements));

    for meshIdx = 1:numel(numElements)
        N = numElements(meshIdx);
        h = 1 / N;
        [uLin, uCub] = Calc_FEM_Sol( ...
            N, h, delta, P, qFunc, loadFunc, 1e-12);
        errorsLin(meshIdx) = FixedGaussL2Error(uExact, uLin, N);
        errorsCub(meshIdx) = FixedGaussL2Error(uExact, uCub, N);
    end

    assert(errorsLin(2) < errorsLin(1));
    assert(max(errorsCub) < 1e-10);
end
end

function [K, b] = FixedGaussElementOracle(degree, h, elemNo, qFunc, loadFunc)
[nodes, weights] = GaussRule8;
[basis, derivatives] = IndependentBasis(degree, nodes);
x = (elemNo - 1 + nodes) .* h;
weightedQ = weights .* qFunc(x) ./ h;
weightedLoad = weights .* loadFunc(x) .* h;
K = derivatives * diag(weightedQ) * derivatives.';
b = basis * weightedLoad;
end

function errorNorm = FixedGaussL2Error(uExact, localFields, N)
[nodes, weights] = GaussRule8;
h = 1 / N;
squaredError = 0;
for elemNo = 1:N
    x = (elemNo - 1 + nodes) .* h;
    difference = uExact(x) - localFields{elemNo}(nodes);
    squaredError = squaredError + h * sum(weights .* difference.^2);
end
errorNorm = sqrt(squaredError);
end

function [basis, derivatives] = IndependentBasis(degree, y)
if degree == 1
    basis = [1 - y.'; y.'];
    derivatives = [-ones(size(y.')); ones(size(y.'))];
    return;
end

basis = [ ...
    (1 - 3 .* y.^2 + 2 .* y.^3).'; ...
    (3 .* y.^2 - 2 .* y.^3).'; ...
    (y - 2 .* y.^2 + y.^3).'; ...
    (-y.^2 + y.^3).'];
derivatives = [ ...
    (-6 .* y + 6 .* y.^2).'; ...
    (6 .* y - 6 .* y.^2).'; ...
    (1 - 4 .* y + 3 .* y.^2).'; ...
    (-2 .* y + 3 .* y.^2).'];
end

function [nodes, weights] = GaussRule8
nodes = 0.5 .* (1 + [ ...
    -0.9602898564975363; -0.7966664774136267; ...
    -0.5255324099163290; -0.1834346424956498; ...
     0.1834346424956498;  0.5255324099163290; ...
     0.7966664774136267;  0.9602898564975363]);
weights = 0.5 .* [ ...
    0.1012285362903763; 0.2223810344533745; ...
    0.3137066458778873; 0.3626837833783620; ...
    0.3626837833783620; 0.3137066458778873; ...
    0.2223810344533745; 0.1012285362903763];
end
