
clear;
figure();
N = 8;
h = 1 / N;
sol_Size = 2^10;
elem_Size = sol_Size / N;
x = linspace( 0, 1, elem_Size + 1 )';
z = linspace( 0, h, elem_Size + 1 )';
delta = 0;
degree = 3;
a_Lin = ones(N + 1, 1);
a_Cub = ones(2*N + 2, 1);
ShapeFunc = false;

% Global functions, local shape functions and their derivatives:
[theta_Lin, theta_Prime_Lin, psi_Lin, psi_Prime_Lin, ...
    theta_Cub, theta_Prime_Cub, psi_Cub, psi_Prime_Cub] = ...
    Def_FEM_Func( delta );

if ShapeFunc == true
    
    if degree == 1
        plot(x, psi_Lin{1}(x), 'red', x, psi_Lin{2}(x), 'green');
        legend({'$\psi_1$', '$\psi_2$'}, 'Interpreter', 'latex');
    else
        plot(x, psi_Cub{1}(x), 'red', x, psi_Cub{2}(x), 'green', ...
            x, psi_Cub{3}(x), 'blue', x, psi_Cub{4}(x), 'black');
        legend({'$\psi_1$', '$\psi_2$', '$\psi_3$', '$\psi_4$'}, ...
            'Interpreter', 'latex');
    end;
    grid;
    return;
end;

% Here ShapeFunc is false, i.e., plot basis-functions.
Gamma_Lin = zeros(elem_Size + 1, 2);
Gamma_Lin(:, 1) = psi_Lin{1}( x );
Gamma_Lin(:, 2) = psi_Lin{2}( x );

Gamma_Cub = zeros(elem_Size + 1, 4);
Gamma_Cub(:, 1) = psi_Cub{1}( x );
Gamma_Cub(:, 2) = psi_Cub{2}( x );
Gamma_Cub(:, 3) = psi_Cub{3}( x );
Gamma_Cub(:, 4) = psi_Cub{4}( x );

if degree == 1
    plot( z, Gamma_Lin(:, 1), z, Gamma_Lin(:, 2) );
    hold;
    for i = 2:1:N
        z = z + h;
        plot( z, Gamma_Lin(:, 1), z, Gamma_Lin(:, 2) );
    end;
else
    plot(z, Gamma_Cub(:, 1), z, Gamma_Cub(:, 2), ...
        z, Gamma_Cub(:, 3), z, Gamma_Cub(:, 4));
    hold;
    for i = 2:1:N
        z = z + h;
        plot(z, Gamma_Cub(:, 1), z, Gamma_Cub(:, 2), ...
            z, Gamma_Cub(:, 3), z, Gamma_Cub(:, 4));
    end;
end;

grid;
