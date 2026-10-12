function print_tables(result_list, row_labels, caption_name, label_name, headers)
% Rows are matrices; columns are methods, with the baseline first.

if nargin < 5
    headers = ["Matrix", "Time", "Iter.", "Rel. res.", "Save"];
end

num_methods = size(result_list, 2);
fprintf("\\begin{table}[tbhp]\n");
fprintf("\\centering\n");
fprintf("\\resizebox{\\textwidth}{!}{%%\n");
fprintf("\\begin{tabular}{lrrr%s}\n", repmat('rrrr', 1, num_methods - 1));
fprintf("\\toprule\n");

fprintf("%s", headers(1));
for it_method = 1 : num_methods
    num_columns = 3 + (it_method > 1);
    fprintf(" & \\multicolumn{%d}{c}{%s}", num_columns, ...
        replace(result_list(1, it_method).method_name, "_", "\_"));
end
fprintf(" \\\\\n");

first_column = 2;
for it_method = 1 : num_methods
    last_column = first_column + 2 + (it_method > 1);
    fprintf("\\cmidrule(lr){%d-%d}", first_column, last_column);
    first_column = last_column + 1;
end
fprintf("\n");
for it_method = 1 : num_methods
    fprintf(" & %s & %s & %s", headers(2), headers(3), headers(4));
    if it_method > 1
        fprintf(" & %s", headers(5));
    end
end
fprintf(" \\\\\n");
fprintf("\\midrule\n");

for it_matrix = 1 : size(result_list, 1)
    fprintf("%s", replace(row_labels(it_matrix), "_", "\_"));
    for it_method = 1 : num_methods
        result = result_list(it_matrix, it_method);
        fprintf(" & %.1e & %g & %.1e", result.time, result.iter, result.final_res);
        if it_method > 1
            saved_percent = 100 * (1 - result.time / result_list(it_matrix, 1).time);
            fprintf(" & %.0f\\%%", saved_percent);
        end
    end
    fprintf(" \\\\\n");
end

fprintf("\\bottomrule\n");
fprintf("\\end{tabular}\n");
fprintf("}\n");
fprintf("\\caption{%s}\n", caption_name);
fprintf("\\label{tab:%s}\n", label_name);
fprintf("\\end{table}\n\n");

end
