exp_SI_settings;

fileNo_list = [2, 6, 8, 10, 12];

time_fields = ["t_decomp", "t_orth", "t_rr", ...
    "t_inv_apply", "t_post_update", "t_residual"];
% Prioritize bold italic symbols in vector PDFs; PNG may render only italic.
time_names = ["Decomposition", "Orth / Whitening", "RR / sRR", ...
    "Apply $\textbf{\textit{A}}^{-1}$", "Basis update", "Residual"];
time_colors = [
    0.650 0.450 0.300 % Decomp
    0.355 0.670 0.850 % Orth / Whitening
    0.880 0.448 0.403 % RR / sRR
    0.387 0.720 0.477 % Apply A^{-1}
    0.950 0.689 0.347 % Basis update
    0.456 0.582 0.780 % Residual
];

plot_time_ratios(fileNo_list, MatNames, data_path, figure_prefix, ...
    ["SI", "sSI"], s_factor_list, alpha_list, ...
    time_fields, time_names, time_colors);
