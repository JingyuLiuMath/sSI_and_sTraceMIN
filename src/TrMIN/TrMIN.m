function [X, d, info] = TrMIN(A, X, LinSolver, nev, opts)

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
info.t_orth = 0;
info.t_rr = 0;
info.t_correction = 0;
info.t_gmres_orth = 0;
info.t_gmres_apply = 0;
info.t_gmres_solve = 0;
info.t_post_update = 0;
info.t_residual = 0;
info.t_lock = 0;
info.t_final_res = 0;
info.t_other = 0;

t_normest_start = tic;
normA = normest(A, 1e-3);
info.t_normest = toc(t_normest_start);

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
[info.res_hist(iter), R, res_col] = ...
    evp_residuals_diag(A, normA, X, d, nev, 1);
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

    % pre-step: correction
    t_correction_start = tic;
    P = @(Y) Y - X * (X' * Y);
    Afun = @(Y) P(A * Y);

    [Delta_active, info_solver] = LinSolver(Afun, P(R(:, active)));
    info.t_gmres_orth = info.t_gmres_orth + info_solver.t_gmres_orth;
    info.t_gmres_apply = info.t_gmres_apply + info_solver.t_gmres_apply;
    info.t_gmres_solve = info.t_gmres_solve + info_solver.t_gmres_solve;
    Delta_active = P(Delta_active);
    X_active = X(:, active) - Delta_active;
    info.t_correction = info.t_correction + toc(t_correction_start);

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
    [info.res_hist(iter), R, res_col] = ...
        evp_residuals_diag(A, normA, X, d, nev, 1);
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
    info.t_orth + ...
    info.t_rr + ...
    info.t_correction + ...
    info.t_post_update + ...
    info.t_residual + ...
    info.t_lock + ...
    info.t_final_res);

end
