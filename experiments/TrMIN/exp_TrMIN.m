exp_TrMIN_settings;

for fileNo = fileNo_list
    mat_name = MatNames(fileNo);
    fprintf("\nMatrix: %s\n", mat_name);

    [A, ~] = FileSVDExp(FileNames(fileNo));

    N = size(A, 1);
    nev = nev_func(N);
    nex = nex_func(N, nev);
    fprintf("N: %d, nev: %d, nex: %d\n", N, nev, nex);

    result = struct();
    result.mat_name = mat_name;
    result.n = N;
    result.nev = nev;
    result.nex = nex;
    result.opts = opts;
    result.inner_maxiter = inner_maxiter;
    result.seed = seed_list;
    result.t_list = zeros(1, num_repeat);
    for it_repeat = 1 : num_repeat
        % initial guess
        rng(seed_list(it_repeat), 'twister');
        X = randn(N, nex);

        % standard method
        [~, ~, info] = TrMIN(A, X, LinSolver, nev, opts);
        result.t_list(it_repeat) = info.t_total;
        result.info(it_repeat) = info;

        fprintf("TrMIN, run %d/%d\n", it_repeat, num_repeat);
        fprintf("  inner GMRES steps: %d\n", inner_maxiter);
        fprintf("  time: %.1e\n", result.t_list(it_repeat));
        fprintf("  reason: %s\n", info.reason);
        fprintf("  iteration number: %d\n", info.iter);
        fprintf("  relative residual: %.1e\n", info.final_res);
    end
    save(data_path + "TrMIN_results" ...
        + "_" + mat_name ...
        + ".mat", "result", '-v7.3');
end
