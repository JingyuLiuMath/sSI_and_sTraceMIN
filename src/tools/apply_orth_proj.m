function info = apply_orth_proj(X, W)

num_repeat = 10;

info.t_total = 0;
info.t_coeff = 0;  % C = X' * W
info.t_back = 0;  % Z = X * C
info.t_minus = 0;  % W_new = W - Z

% Warmup all operations (not timed).
for warmup = 1 : 3
    C = X' * W;
    Z = X * C;
    W_new = W - Z;
end

% Apply P
for it_repeat = 1 : num_repeat
    t_coeff_start = tic;
    C = X' * W;
    info.t_coeff = info.t_coeff + toc(t_coeff_start);

    t_back_start = tic;
    Z = X * C;
    info.t_back = info.t_back + toc(t_back_start);

    t_minus_start = tic;
    W_new = W - Z;
    info.t_minus = info.t_minus + toc(t_minus_start);
end
info.t_coeff = info.t_coeff / num_repeat;
info.t_back = info.t_back / num_repeat;
info.t_minus = info.t_minus / num_repeat;
info.t_total = info.t_coeff + info.t_back + info.t_minus;

end
