exp_SI_settings;

caption_name = "Runtime (in seconds), iterations and relative residual of SI and sSI.";
label_name = "SI";
result_list = struct('method_name', {}, 'iter', {}, 'final_res', {}, ...
    'time', {});

it_matrix = 0;
for fileNo = fileNo_list
    it_matrix = it_matrix + 1;
    mat_name = MatNames(fileNo);
    saved = load(data_path + "SI_results_" + mat_name + ".mat", "result");
    it_repeat = find(saved.result.t_list == median(saved.result.t_list), 1);
    info = saved.result.info(it_repeat);
    result_list(it_matrix, 1) = struct('method_name', "SI", ...
        'iter', info.iter, 'final_res', info.final_res, ...
        'time', saved.result.t_list(it_repeat));

    for it_factor = 1 : numel(s_factor_list)
        factor = s_factor_list(it_factor);
        alpha = alpha_list(it_factor);
        fprintf("sfactor: %d\n", factor);
        fprintf("alpha: %.1e\n", alpha);
        saved = load(data_path + "sSI_results_" + mat_name ...
            + "_" + string(factor) + "_" + string(alpha) + ".mat", "result");
        it_repeat = find(saved.result.t_list == median(saved.result.t_list), 1);
        info = saved.result.info(it_repeat);
        result_list(it_matrix, it_factor + 1) = struct( ...
            'method_name', "sSI ($\nu$ = " + string(factor) + ")", ...
            'iter', info.iter, 'final_res', info.final_res, ...
            'time', saved.result.t_list(it_repeat));
    end

end

print_tables(result_list, string(fileNo_list), caption_name, label_name, ...
    ["No.", "time", "iter", "relres", "save"]);
