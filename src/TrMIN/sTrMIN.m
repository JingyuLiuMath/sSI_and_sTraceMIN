function [X, d, info] = sTrMIN(A, S, X, LinSolver, nev, opts)

t_total_start = tic;

[N, nex] = size(X);

mytol = opts.tol * opts.alpha;

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
SX = S(X);
[SX, G] = qr(SX, "econ");
SAX = S(A * X) / G;
info.t_orth = info.t_orth + toc(t_orth_start);

% sRR
t_rr_start = tic;
[Z, T] = sRR(SX, SAX);
mynev = schur_block_end(T, nev);
info.t_rr = info.t_rr + toc(t_rr_start);

% post-step
t_post_update_start = tic;
X = X * (G \ Z);
SX = SX * Z;
SAX = SAX * Z;
info.t_post_update = info.t_post_update + toc(t_post_update_start);

% check convergence
t_residual_start = tic;
[info.res_hist(iter), ~, res_col] = ...
    evp_sresiduals_schur(normA, SX, SAX, T, mynev, 0);
conv_flag = (info.res_hist(iter) <= mytol);
info.t_residual = info.t_residual + toc(t_residual_start);

% lock
t_lock_start = tic;
nlock = lock_schur(T, res_col, mytol);
info.nlock_hist(iter) = nlock;
info.t_lock = info.t_lock + toc(t_lock_start);

% loop
while iter < opts.maxiter && ~conv_flag
    iter = iter + 1;

    lock = 1 : nlock;
    active = (nlock + 1) : nex;

    % pre-step: correction
    t_correction_start = tic;
    P = @(Y) Y - X * (SX' * S(Y));
    Afun = @(Y) P(A * Y);

    X_active = X(:, active);
    % Delta_active = P(LinSolver(Afun, P(A * X_active - X * T(:, active))));
    [Delta_active, info_solver] = LinSolver(Afun, P(A * X_active));
    info.t_gmres_orth = info.t_gmres_orth + info_solver.t_gmres_orth;
    info.t_gmres_apply = info.t_gmres_apply + info_solver.t_gmres_apply;
    info.t_gmres_solve = info.t_gmres_solve + info_solver.t_gmres_solve;
    Delta_active = P(Delta_active);
    X_active = X_active - Delta_active;
    info.t_correction = info.t_correction + toc(t_correction_start);

    % pre-step: orth
    t_orth_start = tic;
    SX_active = S(X_active);
    SX_lock = SX(:, lock);
    G_lock_act = zeros(nlock, numel(active));
    for repeat = 1 : 2
        H = SX_lock' * SX_active;
        SX_active = SX_active - SX_lock * H;
        G_lock_act = G_lock_act + H;
    end
    [SX_active, G_active] = qr(SX_active, "econ");

    SAX(:, active) = (S(A * X_active) - SAX(:, lock) * G_lock_act) / G_active;
    SX(:, active) = SX_active;
    X(:, active) = X_active;
    info.t_orth = info.t_orth + toc(t_orth_start);

    % sRR
    t_rr_start = tic;
    [Z, T] = sRR(SX, SAX);
    mynev = schur_block_end(T, nev);
    info.t_rr = info.t_rr + toc(t_rr_start);

    % post-step
    t_post_update_start = tic;
    C_active = G_active \ Z(active, :);
    C = [Z(lock, :) - G_lock_act * C_active; C_active];
    X = X * C;
    SX = SX * Z;
    SAX = SAX * Z;
    info.t_post_update = info.t_post_update + toc(t_post_update_start);

    % check convergence
    t_residual_start = tic;
    [info.res_hist(iter), ~, res_col] = ...
        evp_sresiduals_schur(normA, SX, SAX, T, mynev, 0);
    conv_flag = (info.res_hist(iter) <= mytol);
    info.t_residual = info.t_residual + toc(t_residual_start);

    % lock
    t_lock_start = tic;
    nlock = lock_schur(T, res_col, mytol);
    info.nlock_hist(iter) = nlock;
    info.t_lock = info.t_lock + toc(t_lock_start);
end

t_post_update_start = tic;
X = X(:, 1 : mynev);
info.t_post_update = info.t_post_update + toc(t_post_update_start);

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
X = X * Z(:, 1 : nev);
d = d(1 : nev);
info.t_post_update = info.t_post_update + toc(t_post_update_start);

info.iter = iter;
info.res_hist = info.res_hist(1 : iter);
info.nlock_hist = info.nlock_hist(1 : iter);
if conv_flag
    info.reason = "sketched_converged";
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
