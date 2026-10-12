function [V, d] = ordered_sym_eig(A)

[V, D] = eig(A);

d = diag(D);

[~, idx] = sort(d, 'ascend');

V = V(:, idx);
d = d(idx);

end