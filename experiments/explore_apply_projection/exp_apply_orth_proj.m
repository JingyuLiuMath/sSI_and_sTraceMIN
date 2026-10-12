exp_apply_projection_settings;

for fileNo = fileNo_list
    mat_name = MatNames(fileNo);
    [A, ~] = FileSVDExp(FileNames(fileNo));
    N = size(A, 1);
    fprintf("\nMatrix: %s, N: %d, nex: %d\n", mat_name, N, nex);

    for nrhs = nrhs_list
        result = struct();
        result.mat_name = mat_name;
        result.n = N;
        result.nnzA = nnz(A);
        result.nex = nex;
        result.nrhs = nrhs;
        result.seed = seed_list;
        result.t_list = zeros(1, num_repeat);

        for it_repeat = 1 : num_repeat
            rng(seed_list(it_repeat), 'twister');
            [X, ~] = qr(randn(N, nex), "econ");
            W = randn(N, nrhs);

            info = apply_orth_proj(X, W);
            result.t_list(it_repeat) = info.t_total;
            result.info(it_repeat) = info;

            fprintf("Orthogonal projection, nrhs: %d, run %d/%d\n", ...
                nrhs, it_repeat, num_repeat);
            fprintf("  Coefficients: %.1e s\n", info.t_coeff);
            fprintf("  Back multiply: %.1e s\n", info.t_back);
            fprintf("  Subtraction: %.1e s\n", info.t_minus);
            fprintf("  Total: %.1e s\n", result.t_list(it_repeat));
        end

        save(data_path + "apply_orth_proj_results_" + mat_name ...
            + "_r" + nrhs + ".mat", "result", '-v7.3');
    end
end
