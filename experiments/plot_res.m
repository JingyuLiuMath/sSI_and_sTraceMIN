function plot_res(result_list, figure_prefix, matname)
% Each struct contains one method's selected residual history.

% Use the same canvas and plot box for every matrix, with room for large labels.
figure_size = [1200, 850];
fig = figure("Color", "white", "Units", "pixels", ...
    "Position", [100, 100, figure_size]);
font_size = 60;
legend_font_size = 0.8 * font_size;
line_width = 6;
marker_size = 20;
ax = axes(fig, "Units", "pixels", "Position", [250, 190, 847, 563]);
styles = ["-", "--", "-.", ":"];
markers = ["o", "s", "^", "d", "v", ">", "<", "p"];

for it_method = 1 : numel(result_list)
    result = result_list(it_method);
    marker_step = max(1, ceil(numel(result.res_hist) / 12));
    marker_start = 1 + floor((it_method - 1) * marker_step / numel(result_list));
    semilogy(ax, result.res_hist, ...
        "LineWidth", line_width, ...
        "MarkerSize", marker_size, ...
        "LineStyle", styles(1 + mod(it_method - 1, numel(styles))), ...
        "Marker", markers(1 + mod(it_method - 1, numel(markers))), ...
        "MarkerIndices", marker_start : marker_step : numel(result.res_hist), ...
        "DisplayName", replace(result.method_name, "\nu", "$\nu$"));
    hold(ax, "on");
end

set(ax, "PositionConstraint", "innerposition", "FontSize", font_size, ...
    "TickLabelInterpreter", "latex", ...
    "YTick", 10.^(-10 : 2 : 0), ...
    "YTickLabel", ["$10^{-10}$", "$10^{-8}$", "$10^{-6}$", ...
        "$10^{-4}$", "$10^{-2}$", "$10^{0}$"]);
% Include every requested tick without clipping residuals outside this range.
limits = ylim(ax);
ylim(ax, [min(limits(1), 1e-10), max(limits(2), 1)]);
xlabel(ax, "Iteration", "Interpreter", "latex", "FontSize", font_size);
ylabel(ax, "Relative residual", "Interpreter", "latex", "FontSize", font_size);
title(ax, "\texttt{" + replace(matname, "_", "\_") + "}", ...
    "Interpreter", "latex", "FontSize", font_size);
legend(ax, "Location", "northeast", "Interpreter", "latex", ...
    "FontSize", legend_font_size);
drawnow;

figure_path = fileparts(figure_prefix);
if ~isfolder(figure_path)
    mkdir(figure_path);
end
% Preserve the canvas instead of cropping to each plot's tick-label extents.
export_size = figure_size / get(groot, "ScreenPixelsPerInch");
export_options = {"Units", "inches", ...
    "Width", export_size(1), "Height", export_size(2), ...
    "Padding", "figure", "PreserveAspectRatio", "on"};
exportgraphics(fig, figure_prefix + "_res.pdf", "ContentType", "vector", ...
    export_options{:});
exportgraphics(fig, figure_prefix + "_res.png", "Resolution", 300, ...
    export_options{:});

end
