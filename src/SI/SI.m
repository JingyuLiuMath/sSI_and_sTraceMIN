function [X, d, info] = SI(A, X, nev, opts)

t_total_start = tic;

[N, nex] = size(X);

mytol = opts.tol;

% output information
info = struct();

info.iter = 0;
info.final_res = NaN;
info.res_hist = nan(opts.maxiter, 1);
info.nlock_hist = nan(opts.maxiter, 1);
info.reason = "maximum_iteration";

info.t_total = 0;
info.t_normest = 0;
info.t_decomp = 0;
info.t_orth = 0;
info.t_rr = 0;
info.t_inv_apply = 0;
info.t_post_update = 0;
info.t_residual = 0;
info.t_lock = 0;
info.t_final_res= 0;
info.t_other = 0;

t_normest_start = tic;
normA = normest(A, 1e-3);
info.t_normest = toc(t_normest_start);

% prepare decomposition
t_decomp_start = tic;
A_decomp = decomposition(A);
info.t_decomp = toc(t_decomp_start);

iter = 1;

% pre-step
t_orth_start = tic;
[X, ~] = qr(X, "econ");
info.t_orth = info.t_orth + toc(t_orth_start);

% RR
t_rr_start = tic;
[Z, d] = RR(A, X);
info.t_rr = info.t_rr + toc(t_rr_start);

% post-step
t_post_update_start = tic;
X = X * Z;
info.t_post_update = info.t_post_update + toc(t_post_update_start);

% check convergence
t_residual_start = tic;
[info.res_hist(iter), ~, res_col] = ...
    evp_residuals_diag(A, normA, X, d, nev, 0);
conv_flag = (info.res_hist(iter) <= mytol);
info.t_residual = info.t_residual + toc(t_residual_start);

% lock
t_lock_start = tic;
nlock = lock_diag(res_col, mytol);
info.nlock_hist(iter) = nlock;
info.t_lock = info.t_lock + toc(t_lock_start);

% loop
while iter < opts.maxiter && ~conv_flag
    iter = iter + 1;

    lock = 1 : nlock;
    active = (nlock + 1) : nex;

    % pre-step: inverse iteration
    t_inv_apply_start = tic;
    X_active = A_decomp \ X(:, active);
    info.t_inv_apply = info.t_inv_apply + toc(t_inv_apply_start);

    % pre-step: orth
    t_orth_start = tic;
    X_lock = X(:, lock);
    for repeat = 1 : 2
        X_active = X_active - X_lock * (X_lock' * X_active);
    end
    [X_active, ~] = qr(X_active, "econ");
    X(:, active) = X_active;
    info.t_orth = info.t_orth + toc(t_orth_start);

    % RR
    t_rr_start = tic;
    [Z, d] = RR(A, X);
    info.t_rr = info.t_rr + toc(t_rr_start);

    % post-step
    t_post_update_start = tic;
    X = X * Z;
    info.t_post_update = info.t_post_update + toc(t_post_update_start);

    % check convergence
    t_residual_start = tic;
    [info.res_hist(iter), ~, res_col] = ...
        evp_residuals_diag(A, normA, X, d, nev, 0);
    conv_flag = (info.res_hist(iter) <= mytol);
    info.t_residual = info.t_residual + toc(t_residual_start);

    % lock
    t_lock_start = tic;
    nlock = lock_diag(res_col, mytol);
    info.nlock_hist(iter) = nlock;
    info.t_lock = info.t_lock + toc(t_lock_start);
end

t_post_update_start = tic;
X = X(:, 1 : nev);
d = d(1 : nev);
info.t_post_update = info.t_post_update + toc(t_post_update_start);

info.iter = iter;
info.res_hist = info.res_hist(1 : iter);
info.nlock_hist = info.nlock_hist(1 : iter);
if conv_flag
    info.reason = "converged";
end

t_final_res_start = tic;
[info.final_res] = evp_residuals_diag(A, normA, X, d, nev, 0);
info.t_final_res = toc(t_final_res_start);

info.t_total = toc(t_total_start);

info.t_other = info.t_total - ( ...
    info.t_normest + ...
    info.t_decomp + ...
    info.t_orth + ...
    info.t_rr + ...
    info.t_inv_apply + ...
    info.t_post_update + ...
    info.t_residual + ...
    info.t_lock + ...
    info.t_final_res);
end
