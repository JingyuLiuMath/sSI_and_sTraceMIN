function plot_time_ratios(fileNo_list, MatNames, data_path, figure_prefix, ...
    methods, s_factor_list, alpha_list, time_fields, time_names, time_colors)
% Group matrices and normalize each group by its standard method's time.

label_flag = false; % Set false to hide time and percentage labels.

n_cases = numel(fileNo_list);
n_methods = 1 + numel(s_factor_list);
n_parts = numel(time_fields) + 1; % Unlisted time is Other.
ratios = zeros(n_cases * n_methods, n_parts);
part_times = zeros(size(ratios));
x = zeros(n_cases * n_methods, 1);
matrix_labels = strings(1, n_cases);
matrix_x = zeros(1, n_cases);
bar_step = 0.30;
cluster_gap = 0.70;

for i = 1 : n_cases
    mat_name = MatNames(fileNo_list(i));
    rows = (i - 1) * n_methods + (1 : n_methods);
    x(rows) = (i - 1) * ((n_methods - 1) * bar_step + cluster_gap) ...
        + (0 : n_methods - 1) * bar_step;
    matrix_x(i) = mean(x(rows));
    matrix_labels(i) = "\texttt{" + replace(mat_name, "_", "\_") + "}";

    filename = fullfile(data_path, methods(1) + "_results_" + mat_name + ".mat");
    [parts, baseline_time] = median_time_parts(filename, time_fields);
    part_times(rows(1), :) = parts;
    ratios(rows(1), :) = parts / baseline_time;

    for j = 1 : numel(s_factor_list)
        filename = fullfile(data_path, methods(2) + "_results_" + mat_name ...
            + "_" + string(s_factor_list(j)) + "_" + string(alpha_list(j)) + ".mat");
        parts = median_time_parts(filename, time_fields);
        part_times(rows(j + 1), :) = parts;
        ratios(rows(j + 1), :) = parts / baseline_time;
    end
end

method_labels = strings(1, n_methods);
method_labels(1) = methods(1);
for j = 1 : numel(s_factor_list)
    method_labels(j + 1) = methods(2) + " ($\nu = " + string(s_factor_list(j)) + "$)";
end

fig = figure("Color", "white", "Position", ...
    [100, 100, max(900, 150 * n_cases + 300), 520]);
font_size = 24;
ax = axes(fig);
bars = bar(ax, x, ratios(:, end : -1 : 1), 1, "stacked");
colors = [time_colors; 0.680, 0.520, 0.720]; % Other.
for k = 1 : n_parts
    bars(k).FaceColor = colors(n_parts - k + 1, :);
    bars(k).EdgeColor = "black";
    bars(k).LineWidth = 0.25;
end

if label_flag
    for k = 1 : n_parts
        for row = 1 : numel(x)
            share = ratios(row, k); % Same baseline as the y-axis.
            if share <= 0.05
                continue;
            end
            y = sum(ratios(row, k + 1 : end)) + share / 2;
            text(ax, x(row), y, sprintf("%.1f s\n(%.1f%%)", ...
                part_times(row, k), 100 * share), ...
                "HorizontalAlignment", "center", "VerticalAlignment", "middle", ...
                "Color", "black", "FontSize", font_size, "Interpreter", "none", ...
                "HandleVisibility", "off");
        end
    end
end

ax.XTick = matrix_x;
ax.XTickLabel = matrix_labels;
ax.TickLabelInterpreter = "latex";
ax.FontSize = font_size;
ax.YGrid = "on";
ax.XGrid = "off";
ax.GridLineStyle = "--";
ax.Box = "off";
xtickangle(ax, 20);
xlim(ax, [min(x) - 0.25, max(x) + 0.25]);
ylim(ax, [0, 1.05 * max([1; sum(ratios, 2)])]);
y_ticks = 0 : 0.2 : ax.YLim(2);
yticks(ax, y_ticks);
yticklabels(ax, string(round(100 * y_ticks)) + "\%");
xlabel(ax, "Matrix", "Interpreter", "latex", "FontSize", font_size);
ylabel(ax, "Run time relative to " + methods(1), "Interpreter", "latex", ...
    "FontSize", font_size);
title(ax, "Each group, left to right: " + strjoin(method_labels, ", "), ...
    "Interpreter", "latex", "FontSize", font_size);
legend(ax, bars(end : -1 : 1), [time_names, "Other"], ...
    "Location", "eastoutside", "Interpreter", "latex", "FontSize", font_size);

out_name = figure_prefix + "_time_ratio_clustered";
figure_path = fileparts(out_name);
if ~isfolder(figure_path)
    mkdir(figure_path);
end
exportgraphics(fig, out_name + ".pdf", "ContentType", "vector");
exportgraphics(fig, out_name + ".png", "Resolution", 300);
fprintf("Saved %s.pdf and %s.png\n", out_name, out_name);
end

function [parts, total_time] = median_time_parts(filename, time_fields)
saved = load(filename, "result");
info_list = saved.result.info;
if isempty(info_list) || ~all(isfield(info_list, ["t_total", time_fields]))
    error("Missing timing fields in %s", filename);
end

total_times = [info_list.t_total];
[~, it_run] = min(abs(total_times - median(total_times)));
info = info_list(it_run);
total_time = info.t_total;
parts = zeros(1, numel(time_fields) + 1);
for k = 1 : numel(time_fields)
    parts(k) = info.(time_fields(k));
end
parts(end) = total_time - sum(parts(1 : end - 1));
if ~isfinite(total_time) || total_time <= 0 || any(~isfinite(parts)) || any(parts < 0)
    error("Invalid timing breakdown in %s", filename);
end
end
