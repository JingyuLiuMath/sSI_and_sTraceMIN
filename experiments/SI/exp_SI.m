exp_SI_settings;

for fileNo = fileNo_list
    mat_name = MatNames(fileNo);
    fprintf("\nMatrix: %s\n", mat_name);

    [A, ~] = FileSVDExp(FileNames(fileNo));
    
    N = size(A, 1);
    nev = nev_func(N);
    nex = nex_func(N, nev);
    fprintf("N: %d, nev: %d, nex: %d\n", N ,nev, nex);

    result = struct();
    result.n = N;
    result.nev = nev;
    result.nex = nex;
    result.opts = opts;
    result.seed = seed_list;
    result.t_list = zeros(1, num_repeat);
    for it_repeat = 1 : num_repeat
        % initial guess
        rng(seed_list(it_repeat), 'twister');
        X = randn(N, nex);

        % standard method
        [~, ~, info] = SI(A, X, nev, opts);
        result.t_list(it_repeat) = info.t_total;
        result.info(it_repeat) = info;

        fprintf("SI, run %d/%d\n", it_repeat, num_repeat);
        fprintf("  time: %.1e\n", result.t_list(it_repeat));
        fprintf("  reason: %s\n", info.reason);
        fprintf("  iteration number: %d\n", info.iter);
        fprintf("  relative residual: %.1e\n", info.final_res);
        fprintf("  decomp time: %.1e\n", info.t_decomp);
    end
    save(data_path + "SI_results" ...
        + "_" + mat_name ...
        + ".mat", "result", '-v7.3');
end
