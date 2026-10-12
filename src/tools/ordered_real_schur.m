function [U, T] = ordered_real_schur(A)

[U, T] = schur(A, 'real');

lambda = ordeig(T);

[~, ~, cluster] = unique(real(lambda), "sorted");

cluster = max(cluster) + 1 - cluster;

[U, T] = ordschur(U, T, cluster);

end