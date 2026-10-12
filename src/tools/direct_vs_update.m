function [t_sx, t_ax, t_sax] = direct_vs_update(A, S, X)
% Each output contains mean [direct, update] times in seconds after warmup.

num_repeat = 3;
t_sx = zeros(1, 2);
t_ax = zeros(1, 2);
t_sax = zeros(1, 2);

SX = S(X);
AX = A * X;
SAX = S(AX);

[~, T] = qr(SX, "econ");
X = X / T;

% Warmup all six operations (not timed).
SX1 = S(X);
SX2 = SX / T;
AX1 = A * X;
AX2 = AX / T;
SAX1 = S(AX1);
SAX2 = SAX / T;

for it_repeat = 1 : num_repeat
    % SX
    t_start = tic;
    SX1 = S(X);
    t_sx(1) = t_sx(1) + toc(t_start);

    t_start = tic;
    SX2 = SX / T;
    t_sx(2) = t_sx(2) + toc(t_start);

    % AX
    t_start = tic;
    AX1 = A * X;
    t_ax(1) = t_ax(1) + toc(t_start);

    t_start = tic;
    AX2 = AX / T;
    t_ax(2) = t_ax(2) + toc(t_start);

    % SAX
    t_start = tic;
    SAX1 = S(AX1);
    t_sax(1) = t_sax(1) + toc(t_start);

    t_start = tic;
    SAX2 = SAX / T;
    t_sax(2) = t_sax(2) + toc(t_start);
end

t_sx = t_sx / num_repeat;
t_ax = t_ax / num_repeat;
t_sax = t_sax / num_repeat;

end
