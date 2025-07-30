function [gBest, thenParm, yAll] = AOA(tIter, H_train, Y_train, particleNum, baseVarFuzzyN)
    % 初始化參數
    parmDim = sum(baseVarFuzzyN) * 3;
    error = 0.001;
    failCount = 0;
    pCnsqParm = cell(particleNum, 1);
    
    % AOA 參數
    alpha = 5;              % 控制參數
    MOA_min = 0.2;
    MOA_max = 1;
    epsilon = 1e-10;        % 防止除以 0
    
    % 初始化解 (population)
    X = rand(particleNum, parmDim);
    X_best = X;
    fitness = zeros(particleNum, 1);
    
    % 計算初始 fitness
    for i = 1:particleNum
        [Y_output, pCnsqParm{i}] = cFIS(H_train, Y_train, baseVarFuzzyN, X(i, :));
        fitness(i) = RMSE(Y_output, Y_train);
    end
    
    [gBestVal, idx] = min(fitness);
    gBest = X(idx, :);
    thenParm = pCnsqParm{idx};

    % 儲存歷史
    yAll = zeros(tIter, 1);
    
    for t = 1:tIter
        MOA = MOA_min + t * ((MOA_max - MOA_min) / tIter);
        MOP = 1 - (t^alpha / tIter^alpha); % exploration vs exploitation
        
        for i = 1:particleNum
            r1 = rand;
            r2 = rand;
            r3 = rand;
            r4 = rand;
            X_new = X(i, :);
            
            for d = 1:parmDim
                if r1 > MOA  % exploration
                    if r2 < 0.5
                        X_new(d) = gBest(d) / (MOP + epsilon) * ((upper(d) - lower(d)) * r3 + lower(d));
                    else
                        X_new(d) = gBest(d) * MOP * ((upper(d) - lower(d)) * r3 + lower(d));
                    end
                else  % exploitation
                    if r4 < 0.5
                        X_new(d) = gBest(d) - MOP * ((upper(d) - lower(d)) * r3 + lower(d));
                    else
                        X_new(d) = gBest(d) + MOP * ((upper(d) - lower(d)) * r3 + lower(d));
                    end
                end
            end
            
            % 修正範圍
            X_new = max(X_new, 0);  % 限制在 [0, 1] 範圍或自訂範圍
            X_new = min(X_new, 1);
            
            % 計算新 fitness
            [Y_output, pCnsqParm{i}] = cFIS(H_train, Y_train, baseVarFuzzyN, X_new);
            fNew = RMSE(Y_output, Y_train);
            
            % 更新個體
            if fNew < fitness(i)
                X(i, :) = X_new;
                fitness(i) = fNew;
            end
        end
        
        % 更新全域最佳
        [minFit, minIdx] = min(fitness);
        if gBestVal - minFit < 1e-5
            failCount = failCount + 1;
        else
            failCount = 0;
        end
        
        if gBestVal > minFit
            gBestVal = minFit;
            gBest = X(minIdx, :);
            thenParm = pCnsqParm{minIdx};
        end
        
        yAll(t) = gBestVal;
        fprintf('%d %f\n', t, gBestVal);
        
        if gBestVal < error
            break;
        end
    end
end

function val = upper(d)
    val = 1; % 根據實際參數範圍定義上限
end

function val = lower(d)
    val = 0; % 根據實際參數範圍定義下限
end
