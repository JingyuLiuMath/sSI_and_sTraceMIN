function [x, info] = myGMRES(A, b, m)

info.t_gmres_orth = 0;
info.t_gmres_apply = 0;
info.t_gmres_solve = 0;

[N, nrhs] = size(b);

if ~isa(A, 'function_handle')
    A = @(x) A*x;
end

% Arnoldi basis and Hessenberg matrices
V = zeros(N, nrhs, m);
H = zeros(m + 1, m, nrhs);

t_gmres_orth_start = tic;
beta = vecnorm(b);
V(:, :, 1) = b ./ beta;
info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

for j = 1 : m
    t_gmres_apply_start = tic;
    w = A(V(:, :, j));
    info.t_gmres_apply = info.t_gmres_apply + toc(t_gmres_apply_start);

    t_gmres_orth_start = tic;
    for i = 1 : j
        h = sum(conj(V(:, :, i)) .* w, 1);

        H(i, j, :) = H(i, j, :) ...
            + reshape(h, 1, 1, nrhs);

        w = w - V(:, :, i) .* h;
    end

    h = vecnorm(w);
    H(j + 1, j, :) = reshape(h, 1, 1, nrhs);

    if j < m
        V(:, :, j + 1) = w ./ h;
    end
    info.t_gmres_orth = info.t_gmres_orth + toc(t_gmres_orth_start);

end

t_gmres_solve_start = tic;
x = zeros(size(b));
for irhs = 1 : nrhs
    Vnow = reshape(V(:, irhs, :), N, m);
    Hnow = H(:, :, irhs);

    e1 = zeros(m + 1, 1);
    e1(1) = beta(irhs);

    y = Hnow \ e1;
    x(:, irhs) = Vnow * y;
end
info.t_gmres_solve = info.t_gmres_solve + toc(t_gmres_solve_start);

end
