function nlock = lock_schur(T, res, tol)

n = size(T, 1);
block_end = [0, find([T(2 : (n + 1) : end), 0] == 0)];
block_end = block_end(block_end <= numel(res));

first_unconverged = find( ...
    [res(block_end(2 : end)) > tol / 100, true], 1);
nlock = block_end(first_unconverged);

end