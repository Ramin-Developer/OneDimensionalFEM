function Plot_FEM_Solutions(no_Of_Elements, sol_Size, x, u_Exact, u_FEM_Lin, u_FEM_Cub)
%PLOT_FEM_SOLUTIONS Plot exact and FEM solutions for selected mesh sizes.

% Element size in the FEM solution
elem_Size = sol_Size ./ no_Of_Elements;

% Construct exact solution:
sol_Exact = u_Exact(x);
size_N = length(no_Of_Elements);

% Construct a three dimensional matrix for the FEM-solution of the problem.
% Element (i, j, 1) is the Linear-FEM Solution at x_i with j elements.
% Element (i, j, 2) is the Cubic-FEM Solution at x_i with j elements.
u_FEM = zeros(sol_Size + 1, size_N, 2);

% Construct FEM-Solution as a linear combination of the shape-functions:
for size_Ind = 1:1:size_N
    points_Per_Element = elem_Size(size_Ind);
    u_FEM(:, size_Ind, 1) = Evaluate_FEM_Field( ...
        u_FEM_Lin{size_Ind}, points_Per_Element);
    u_FEM(:, size_Ind, 2) = Evaluate_FEM_Field( ...
        u_FEM_Cub{size_Ind}, points_Per_Element);
end

figure();
left = 0.09;
bottom = 0.55;
width = 0.24;
height = 0.40;
horizontalSpace = 0.08;

for k = 1:1:2
    for size_Ind = 1:1:min(size_N, 3)

        N = no_Of_Elements(size_Ind);
        subplot(2, size_N, (k - 1)*size_N + size_Ind, 'Position', ...
            [left bottom width height]);
        plot(x, sol_Exact, 'red', x, u_FEM(:, size_Ind, k), ...
            'green', 'LineWidth', 2);
        left = left + width + horizontalSpace;

        % Grid and thick marks:
        grid;
        set(gca, 'FontName', 'Arial', 'FontSize', 14);
        set(gca, 'XTick', [0.25 0.5 0.75 1]);

        % Legend
        str_FEM = ['$u_{cub}$, ' 'N = ' num2str(N)];
        if k == 1
            str_FEM = ['$u_{lin}$, ' 'N = ' num2str(N)];
        end;
        h_leg = legend('$u_{ex}$', str_FEM, ...
            'Location', 'Northwest', 'Orientation', 'Vertical');
        set(h_leg, 'Interpreter', 'Latex', 'FontSize', 14);
    end;

    left = 0.09;
    bottom = 0.05;
    width = 0.24;
    height = 0.40;
    horizontalSpace = 0.08;
end;

function values = Evaluate_FEM_Field(local_Fields, points_Per_Element)

y = linspace(0, 1, points_Per_Element + 1)';
num_Elements = numel(local_Fields);
values = zeros(points_Per_Element * num_Elements + 1, 1);

for elem_No = 1:num_Elements
    start_Ind = (elem_No - 1) * points_Per_Element + 1;
    end_Ind = start_Ind + points_Per_Element;
    values(start_Ind:end_Ind) = local_Fields{elem_No}(y);
end