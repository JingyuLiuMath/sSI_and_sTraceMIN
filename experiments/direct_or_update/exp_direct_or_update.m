exp_direct_or_update_settings;

operation_names = ["SX", "AX", "SAX"];
method_names = ["direct", "update"];
for factor = s_factor_list
    fprintf("\ns_factor: %g\n", factor);
    for fileNo = fileNo_list
        mat_name = MatNames(fileNo);
        fprintf("\nMatrix: %s\n", mat_name);

        [A, ~] = FileSVDExp(FileNames(fileNo));
        N = size(A, 1);
        nev = nev_func(N);
        nex = nex_func(N, nev);
        s = factor * nex;

        result = struct();
        result.mat_name = mat_name;
        result.n = N;
        result.nnzA = nnz(A);
        result.ratio_A = result.nnzA / N;
        result.nev = nev;
        result.nex = nex;
        result.s_factor = factor;
        result.s = s;
        result.seed = seed;
        fprintf("N: %d, nnzA: %d, ratio_A: %.1e\n", ...
            N, result.nnzA, result.ratio_A);
        fprintf("nev: %d, nex: %d, s: %d\n", nev, nex, s);

        rng(seed, 'twister');
        X = randn(N, nex);
        S_mat = sparse_sign(s, N);
        S = @(Y) S_mat * Y;

        [result.t_sx, result.t_ax, result.t_sax] = direct_vs_update(A, S, X);
        fprintf("Mean over 3 timed runs (after warmup):\n");
        times = [result.t_sx; result.t_ax; result.t_sax];
        for it_operation = 1 : 3
            [~, it_method] = min(times(it_operation, :));
            method = method_names(it_method);
            if times(it_operation, 1) == times(it_operation, 2)
                method = "equal";
            end
            fprintf("  %s: direct %.1e s, update %.1e s; use %s\n", ...
                operation_names(it_operation), ...
                times(it_operation, 1), times(it_operation, 2), method);
        end

        save(data_path + "direct_or_update_results_" + mat_name ...
            + "_" + string(factor) + ".mat", "result", '-v7.3');
    end
end
