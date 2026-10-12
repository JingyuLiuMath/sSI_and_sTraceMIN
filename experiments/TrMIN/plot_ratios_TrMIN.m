exp_TrMIN_settings;

fileNo_list = [2, 6, 8, 10, 12];

time_fields = ["t_orth", "t_rr", "t_correction", "t_post_update", "t_residual"];
time_names = ["Orth / Whitening", "RR / sRR", "Correction", "Basis Update", "Residual"];
time_colors = [
    0.355 0.670 0.850 % Orth / Whitening
    0.880 0.448 0.403 % RR / sRR
    0.387 0.720 0.477 % Correction
    0.950 0.689 0.347 % Basis Update
    0.456 0.582 0.780 % Residual
];

% To display the three GMRES components instead of t_correction:
% time_fields = ["t_orth", "t_rr", "t_gmres_orth", "t_gmres_apply", ...
%     "t_gmres_solve", "t_post_update", "t_residual"];
% time_names = ["Orth / Whitening", "RR / sRR", "GMRES orth", ...
%     "GMRES apply", "GMRES solve", "Basis Update", "Residual"];
% time_colors = [
%     0.355 0.670 0.850 % Orth / Whitening
%     0.880 0.448 0.403 % RR / sRR
%     0.650 0.450 0.300 % GMRES orth
%     0.387 0.720 0.477 % GMRES apply
%     0.100 0.550 0.550 % GMRES solve (teal)
%     0.950 0.689 0.347 % Basis Update
%     0.456 0.582 0.780 % Residual
% ];

plot_time_ratios(fileNo_list, MatNames, data_path, figure_prefix, ...
    ["TrMIN", "sTrMIN"], s_factor_list, alpha_list, ...
    time_fields, time_names, time_colors);
