function info = apply_sketched_proj(S, X_S, SX, W)

num_repeat = 10;

info.t_total = 0 ;
info.t_sketching = 0;  % SW = S(W)
info.t_coeff = 0;  % C_S = SX' * SW
info.t_back = 0;  % Z_S = X_S * C_S
info.t_minus= 0;  % W_S_new = W - Z_S


% Warmup all operations (not timed).
for warmup = 1 : 3
    SW = S(W);
    C_S = SX' * SW;
    Z_S = X_S * C_S;
    W_S_new = W - Z_S;
end

% Apply P_S
for it_repeat = 1 : num_repeat
    t_sketching_start = tic;
    SW = S(W);
    info.t_sketching = info.t_sketching + toc(t_sketching_start);

    t_coeff_start = tic;
    C_S = SX' * SW;
    info.t_coeff = info.t_coeff + toc(t_coeff_start);

    t_back_start = tic;
    Z_S = X_S * C_S;
    info.t_back = info.t_back + toc(t_back_start);

    t_minus_start = tic;
    W_S_new = W - Z_S;
    info.t_minus = info.t_minus + toc(t_minus_start);
end
info.t_sketching = info.t_sketching / num_repeat;
info.t_coeff = info.t_coeff / num_repeat;
info.t_back = info.t_back / num_repeat;
info.t_minus = info.t_minus / num_repeat;
info.t_total = info.t_sketching + info.t_coeff + info.t_back + info.t_minus;

end
