exp_apply_projection_settings;

fileNo_list = [2, 6, 8, 10, 12];

figure_prefix = "./figure";
label_flag = false;
font_size = 32;

% Prioritize bold italic symbols in vector PDFs; PNG may render only italic.
% Paired formulas list standard / sketched operations; tilde(X) = S * X_S.
time_names = ["\widetilde{\textbf{\textit{W}}} \gets \textbf{\textit{S}}\textbf{\textit{W}}", ...
    "\textbf{\textit{C}} \gets \textbf{\textit{X}}^{\top}\textbf{\textit{W}} \;/\; " ...
        + "\textbf{\textit{C}}_{\textbf{\textit{S}}} \gets \widetilde{\textbf{\textit{X}}}^{\top} \widetilde{\textbf{\textit{W}}}", ...
    "\textbf{\textit{Z}} \gets \textbf{\textit{X}}\textbf{\textit{C}} \;/\; " ...
        + "\textbf{\textit{Z}}_{\textbf{\textit{S}}} \gets \textbf{\textit{X}}_{\textbf{\textit{S}}} \textbf{\textit{C}}_{\textbf{\textit{S}}}", ...
    "\textbf{\textit{W}} - \textbf{\textit{Z}} \;/\; " ...
        + "\textbf{\textit{W}} - \textbf{\textit{Z}}_{\textbf{\textit{S}}}"];
time_names = "$" + time_names + "$";
time_colors = [
    0.950 0.689 0.347 % SW
    0.355 0.670 0.850 % C = X'*W or tilde(X)'*tilde(W)
    0.387 0.720 0.477 % X*C or X_S*C
    0.690 0.570 0.800 % W - Z or W - Z_S
];

% Each configuration stores the mean of the repetitions in its projection kernel.
% Keep all timed parts from the run nearest to the median total time.
n_parts = numel(time_names);
n_methods = 1 + numel(s_factor_list);
method_names = ["standard", "$\nu=" + string(s_factor_list) + "$"];
for nrhs = nrhs_list
    n_cases = numel(fileNo_list);
    part_times = zeros(n_cases * n_methods, n_parts);
    baseline = zeros(n_cases * n_methods, 1);
    x = zeros(n_cases * n_methods, 1);
    matrix_x = zeros(1, n_cases);

    for i = 1 : n_cases
        mat_name = MatNames(fileNo_list(i));
        rows = (i - 1) * n_methods + (1 : n_methods);
        x(rows) = (i - 1) * (n_methods + 1) + (1 : n_methods);
        matrix_x(i) = mean(x(rows));
        saved = load(fullfile(data_path, "apply_orth_proj_results_" + mat_name ...
            + "_r" + nrhs + ".mat"), "result");
        result = saved.result;
        total_times = [result.info.t_total];
        [~, it_run] = min(abs(total_times - median(total_times)));
        info_P = result.info(it_run);
        part_times(rows(1), :) = [0, info_P.t_coeff, info_P.t_back, info_P.t_minus];
        baseline(rows) = info_P.t_total;

        for j = 1 : numel(s_factor_list)
            factor = s_factor_list(j);
            saved = load(fullfile(data_path, "apply_sketched_proj_results_" + mat_name ...
                + "_" + factor + "_r" + nrhs + ".mat"), "result");
            result = saved.result;
            row = rows(j + 1);
            total_times = [result.info.t_total];
            [~, it_run] = min(abs(total_times - median(total_times)));
            info_P_S = result.info(it_run);
            part_times(row, :) = [info_P_S.t_sketching, info_P_S.t_coeff, ...
                info_P_S.t_back, info_P_S.t_minus];
        end
    end
    ratios = part_times ./ baseline;

    % Keep the reference plot's proportions and room for the rotated labels.
    figure_size = [1500, 710];
    plot_position = [0.108, 0.278, 0.557, 0.565];
    fig = figure("Color", "white", "Units", "pixels", ...
        "Position", [100, 100, figure_size]);
    ax = axes(fig, "Units", "normalized", "Position", plot_position, ...
        "PositionConstraint", "innerposition");
    % MATLAB stacks columns from bottom to top: purple, green, blue, yellow.
    stack_order = [4, 3, 2, 1];
    plot_ratios = ratios(:, stack_order);
    bars = bar(ax, x, plot_ratios, 1, "stacked");
    for k = 1 : n_parts
        bars(k).FaceColor = time_colors(stack_order(k), :);
        bars(k).EdgeColor = "black";
        bars(k).LineWidth = 0.25;
    end
    if label_flag
        for row = 1 : numel(x)
            for k = 1 : n_parts
                if plot_ratios(row, k) < 0.05
                    continue;
                end
                y = sum(plot_ratios(row, 1 : k - 1)) + plot_ratios(row, k) / 2;
                text(ax, x(row), y, sprintf("%.0f%%", 100 * plot_ratios(row, k)), ...
                    "HorizontalAlignment", "center", "VerticalAlignment", "middle", ...
                    "FontSize", 16, "Interpreter", "none", "HandleVisibility", "off");
            end
        end
    end

    ax.XTick = matrix_x;
    ax.XTickLabel = "\texttt{" + replace(MatNames(fileNo_list), "_", "\_") + "}";
    ax.TickLabelInterpreter = "latex";
    ax.FontSize = font_size;
    ax.YGrid = "on";
    ax.GridLineStyle = "--";
    ax.Box = "off";
    xtickangle(ax, 30);
    xlim(ax, [min(x) - 0.75, max(x) + 0.75]);
    ylim(ax, [0, 1.08 * max(sum(ratios, 2))]);
    y_ticks = 0 : 0.5 : ax.YLim(2);
    yticks(ax, y_ticks);
    yticklabels(ax, string(round(100 * y_ticks)) + "\%");
    xlabel(ax, "Matrix", "Interpreter", "latex", "FontSize", font_size);
    ylabel(ax, "Time relative to standard", "Interpreter", "latex", "FontSize", font_size);
    title(ax, "Each group: " + strjoin(method_names, ", ") + "; $\mathrm{nrhs}=" + nrhs + "$", ...
        "Interpreter", "latex", "FontSize", font_size);
    % Keep the right-hand legend centered beside the plot, with four rows.
    legend_width = 14;
    legend_height = 7;
    legend_row_gap = 1.6;
    legend_size = [0.30, 0.30 * figure_size(1) / figure_size(2) ...
        * legend_height / legend_width];

    % Use equal baseline gaps; center swatches on the capital letters in PDF.
    % Coordinates are in font-height units; order is yellow, blue, green, purple.
    legend_ax = axes(fig, "Units", "normalized", "Visible", "off", ...
        "Position", [0.676, plot_position(2) + (plot_position(4) - legend_size(2)) / 2, ...
            legend_size], "PositionConstraint", "innerposition", ...
        "XLim", [0, legend_width], "YLim", [0, legend_height]);
    rectangle(legend_ax, "Position", [0, 0, legend_width, legend_height], ...
        "FaceColor", "white", "EdgeColor", [0.4, 0.4, 0.4], "LineWidth", 0.5);
    for k = 1 : n_parts
        legend_y = legend_height / 2 + ((n_parts + 1) / 2 - k) * legend_row_gap;
        rectangle(legend_ax, "Position", [0.4, legend_y - 0.175, 0.55, 0.35], ...
            "FaceColor", time_colors(k, :), "EdgeColor", "black", "LineWidth", 0.25);
        text(legend_ax, 1.15, legend_y - 0.225, time_names(k), "Interpreter", "latex", ...
            "FontSize", font_size, "VerticalAlignment", "baseline");
    end

    drawnow;

    out_name = fullfile(figure_prefix, "projection_nrhs" + nrhs);
    if ~isfolder(fileparts(out_name))
        mkdir(fileparts(out_name));
    end
    % Preserve the canvas margins in both formats instead of cropping to text.
    export_size = figure_size / get(groot, "ScreenPixelsPerInch");
    export_options = {"Units", "inches", "Width", export_size(1), ...
        "Height", export_size(2), "Padding", "figure", "PreserveAspectRatio", "on"};
    exportgraphics(fig, out_name + ".pdf", "ContentType", "vector", export_options{:});
    exportgraphics(fig, out_name + ".png", "Resolution", 300, export_options{:});
    fprintf("Saved %s.pdf and %s.png\n", out_name, out_name);
end
