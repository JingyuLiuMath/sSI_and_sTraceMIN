exp_TrMIN_settings;

for fileNo = fileNo_list
    mat_name = MatNames(fileNo);
    saved = load(data_path + "TrMIN_results_" + mat_name + ".mat", "result");
    it_repeat = find(saved.result.t_list == median(saved.result.t_list), 1);
    result_list = struct('method_name', "TrMIN", ...
        'nlock_hist', saved.result.info(it_repeat).nlock_hist);

    for it_factor = 1 : numel(s_factor_list)
        factor = s_factor_list(it_factor);
        alpha = alpha_list(it_factor);
        fprintf("sfactor: %d\n", factor);
        fprintf("alpha: %.1e\n", alpha);
        saved = load(data_path + "sTrMIN_results_" + mat_name ...
            + "_" + string(factor) + "_" + string(alpha) + ".mat", "result");
        it_repeat = find(saved.result.t_list == median(saved.result.t_list), 1);
        result_list(it_factor + 1) = struct( ...
            'method_name', "sTrMIN (\nu = " + string(factor) + ")", ...
            'nlock_hist', saved.result.info(it_repeat).nlock_hist);
    end

    plot_nlock_hist(result_list, figure_prefix + "_" + mat_name, mat_name);
end
