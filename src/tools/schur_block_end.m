function k = schur_block_end(Theta, k)

if k < size(Theta, 1) && Theta(k + 1, k) ~= 0
    k = k + 1;
end

end
