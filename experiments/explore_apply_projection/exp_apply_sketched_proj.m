exp_apply_projection_settings;

for it_factor = 1 : length(s_factor_list)
    factor = s_factor_list(it_factor);
    s = factor * nex;
    fprintf("s_factor: %d\n", factor);

    for fileNo = fileNo_list
        mat_name = MatNames(fileNo);
        [A, ~] = FileSVDExp(FileNames(fileNo));
        N = size(A, 1);
        fprintf("\nMatrix: %s, N: %d, nex: %d, s: %d\n", mat_name, N, nex, s);

        for nrhs = nrhs_list
            result = struct();
            result.mat_name = mat_name;
            result.n = N;
            result.nnzA = nnz(A);
            result.nex = nex;
            result.nrhs = nrhs;
            result.s_factor = factor;
            result.s = s;
            result.seed = seed_list;
            result.t_list = zeros(1, num_repeat);

            for it_repeat = 1 : num_repeat
                % Match the standard method's X and W for each seed and nrhs.
                rng(seed_list(it_repeat), 'twister');
                [X, ~] = qr(randn(N, nex), "econ");
                W = randn(N, nrhs);

                S_mat = sparse_sign(s, N);
                S = @(Y) S_mat * Y;
                [SX, R] = qr(S(X), 0);
                X_S = X / R;

                info = apply_sketched_proj(S, X_S, SX, W);
                result.t_list(it_repeat) = info.t_total;
                result.info(it_repeat) = info;

                fprintf("Sketched projection, s_factor: %d, nrhs: %d, run %d/%d\n", ...
                    factor, nrhs, it_repeat, num_repeat);
                fprintf("  Sketching S(W): %.1e s\n", info.t_sketching);
                fprintf("  Coefficients: %.1e s\n", info.t_coeff);
                fprintf("  Back multiply: %.1e s\n", info.t_back);
                fprintf("  Subtraction: %.1e s\n", info.t_minus);
                fprintf("  Total: %.1e s\n", result.t_list(it_repeat));
            end
            result.nnzS = nnz(S_mat);

            save(data_path + "apply_sketched_proj_results_" + mat_name ...
                + "_" + factor + "_r" + nrhs + ".mat", "result", '-v7.3');
        end
    end
end
