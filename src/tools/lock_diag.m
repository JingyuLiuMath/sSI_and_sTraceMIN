function nlock = lock_diag(res, tol)

nlock = find([res(:) > tol / 100; true], 1) - 1;

end