function [Best_FF, Best_P, conv] = AO(N, T, LB, UB, Dim, F_obj)
    Best_P = zeros(1, Dim);
    Best_FF = inf;  % 設置為無窮大
    X = initialization(N, Dim, UB, LB);
    Xnew = X;
    Ffun = zeros(1, size(X, 1));
    Ffun_new = zeros(1, size(Xnew, 1));

    t = 1;
    alpha = 0.1;
    delta = 0.1;

    while t <= T
        for i = 1:size(X, 1)
            % 邊界檢查，如果超過會低於邊界值，則改為邊界值
            F_UB = X(i, :) > UB;
            F_LB = X(i, :) < LB;
            X(i, :) = (X(i, :) .* (~(F_UB + F_LB))) + UB .* F_UB + LB .* F_LB;
            
            % 計算適應度
            Ffun(1, i) = F_obj(X(i, :));
            if Ffun(1, i) < Best_FF
                Best_FF = Ffun(1, i);
                Best_P = X(i, :);
            end
        end
        
        % 計算 G1, G2 及 QF
        G2 = 2 * rand() - 1;
        G1 = 2 * (1 - (t / T));
        QF = t^((2 * rand() - 1) / (1 - T)^2);
        
        % 螺旋飛行參數
        to = 1:Dim;
        u = 0.0265;
        r0 = 10;
        r = r0 + u * to;
        omega = 0.005;
        phi0 = 3 * pi / 2;
        phi = -omega * to + phi0;
        x = r .* sin(phi);
        y = r .* cos(phi);
        
        % 更新粒子位置
        for i = 1:size(X, 1)
            if t <= (2 / 3) * T
                if rand < 0.5
                    Xnew(i, :) = Best_P * (1 - t / T) + (mean(X(i, :)) - Best_P) * rand();
                else
                    Xnew(i, :) = Best_P .* Levy(Dim) + X(floor(N * rand() + 1), :) + (y - x) * rand;
                end
            else
                if rand < 0.5
                    Xnew(i, :) = (Best_P - mean(X)) * alpha - rand + ((UB - LB) * rand + LB) * delta;
                else
                    Xnew(i, :) = QF * Best_P - (G2 * X(i, :) * rand) - G1 .* Levy(Dim) + rand * G2;
                end
            end
            
            % 計算新適應度
            Ffun_new(1, i) = F_obj(Xnew(i, :));
            if Ffun_new(1, i) < Ffun(1, i)
                X(i, :) = Xnew(i, :);
                Ffun(1, i) = Ffun_new(1, i);
            end
        end

        % 記錄收斂數據
        conv(t) = Best_FF;
        t = t + 1;
    end
end

function X = initialization(N, Dim, UB, LB)
    X = rand(N, Dim) .* (UB - LB) + LB;
end

function o = Levy(d)
    beta = 1.5;
    sigma = (gamma(1 + beta) * sin(pi * beta / 2) / ...
            (gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);
    u = randn(1, d) * sigma;
    v = randn(1, d);
    step = u ./ abs(v).^(1 / beta);
    o = step;
end
