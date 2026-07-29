function Basis_Shape_Func(mode, degree, num_Elements)
%BASIS_SHAPE_FUNC Plot local shape functions or global basis patterns.
%
%   BASIS_SHAPE_FUNC() plots cubic global basis patterns over a uniform mesh.
%   BASIS_SHAPE_FUNC('shape', degree, num_Elements) plots local shapes.
%   BASIS_SHAPE_FUNC('basis', degree, num_Elements) plots repeated basis.

if nargin < 1
    mode = 'basis';
end
if nargin < 2
    degree = 3;
end
if nargin < 3
    num_Elements = 8;
end

if ~(degree == 1 || degree == 3)
    error('Basis_Shape_Func:InvalidDegree', ...
        'degree must be 1 (linear) or 3 (cubic).');
end

if num_Elements <= 0 || mod(num_Elements, 1) ~= 0
    error('Basis_Shape_Func:InvalidElements', ...
        'num_Elements must be a positive integer.');
end

[psi_Lin, ~, psi_Cub, ~] = Def_FEM_Func;

num_Points = 2^10;
points_Per_Element = num_Points / num_Elements;
if mod(points_Per_Element, 1) ~= 0
    points_Per_Element = floor(points_Per_Element);
end

y = linspace(0, 1, points_Per_Element + 1)';
h = 1 / num_Elements;
z = linspace(0, h, points_Per_Element + 1)';

figure();
if strcmpi(mode, 'shape')
    Plot_Local_Shapes(y, degree, psi_Lin, psi_Cub);
else
    Plot_Global_Basis(z, h, num_Elements, degree, psi_Lin, psi_Cub);
end

set(gca, 'FontName', 'Arial', 'FontSize', 12);
grid on;

function Plot_Local_Shapes(y, degree, psi_Lin, psi_Cub)

if degree == 1
    plot(y, psi_Lin{1}(y), 'r-', y, psi_Lin{2}(y), 'g-', 'LineWidth', 1.5);
    legend({'$\psi_1$', '$\psi_2$'}, 'Interpreter', 'latex');
    return;
end

plot(y, psi_Cub{1}(y), 'r-', y, psi_Cub{2}(y), 'g-', ...
    y, psi_Cub{3}(y), 'b-', y, psi_Cub{4}(y), 'k-', 'LineWidth', 1.5);
legend({'$\psi_1$', '$\psi_2$', '$\psi_3$', '$\psi_4$'}, ...
    'Interpreter', 'latex');

function Plot_Global_Basis(z, h, num_Elements, degree, psi_Lin, psi_Cub)

if degree == 1
    local_Basis = [psi_Lin{1}(z ./ h), psi_Lin{2}(z ./ h)];
else
    local_Basis = [psi_Cub{1}(z ./ h), psi_Cub{2}(z ./ h), ...
        psi_Cub{3}(z ./ h), psi_Cub{4}(z ./ h)];
end

line_Style = {'r-', 'g-', 'b-', 'k-'};
num_Local = size(local_Basis, 2);

hold on;
for elem = 1:num_Elements
    z_Shift = z + (elem - 1) * h;
    for k = 1:num_Local
        plot(z_Shift, local_Basis(:, k), line_Style{k}, 'LineWidth', 1.2);
    end
end
hold off;
