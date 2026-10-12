exp_SI_settings;

for it = 1 : length(s_factor_list)
    factor = s_factor_list(it);
    alpha = alpha_list(it);
    fprintf("s_factor: %d\n", factor);
    fprintf("alpha: %.1e\n", alpha);
    myopts = opts;
    myopts.alpha = alpha;
    for fileNo = fileNo_list
        mat_name = MatNames(fileNo);
        fprintf("\nMatrix: %s\n", mat_name);

        [A, ~] = FileSVDExp(FileNames(fileNo));

        N = size(A, 1);
        nev = nev_func(N);
        nex = nex_func(N, nev);
        s = factor * nex;
        fprintf("N: %d, nev: %d, nex: %d, s: %d\n", N, nev, nex, s);

        result = struct();
        result.mat_name = mat_name;
        result.n = N;
        result.nev = nev;
        result.nex = nex;
        result.s_factor = factor;
        result.alpha = alpha;
        result.s = s;
        result.opts = myopts;
        result.seed = seed_list;
        result.t_list = zeros(1, num_repeat);
        for it_repeat = 1 : num_repeat
            % initial guess
            rng(seed_list(it_repeat), 'twister');
            X = randn(N, nex);
            solver_rng = rng;

            % sketch
            S_mat = sparse_sign(s, N);
            S = @(Y) S_mat * Y;

            % sketched method
            rng(solver_rng);
            [~, ~, info] = sSI(A, S, X, nev, myopts);
            result.t_list(it_repeat) = info.t_total;
            result.info(it_repeat) = info;

            fprintf("sSI, run %d/%d\n", it_repeat, num_repeat);
            fprintf("  time: %.1e\n", result.t_list(it_repeat));
            fprintf("  reason: %s\n", info.reason);
            fprintf("  iteration number: %d\n", info.iter);
            fprintf("  relative residual: %.1e\n", info.final_res);
            fprintf("  decomp time: %.1e\n", info.t_decomp);
        end
        save(data_path + "sSI_results" ...
            + "_" + mat_name ...
            + "_" + string(factor) ...
            + "_" + string(alpha) ...
            + ".mat", "result", '-v7.3');
    end
end
