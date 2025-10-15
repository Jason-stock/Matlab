function [gBest, thenParm, yAll] = PSO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN)
%初始化參數
parmDim = sum(baseVarFuzzyN)*3;
error = 0.001;
failCount = 0;
pCnsqParm = cell(particleNum);

%初始化p, v, pBest與rmse
p = rand(particleNum,parmDim);
v = rand(particleNum,parmDim);
pBest = p;
pBestVal = zeros(particleNum,1);
rmse = zeros(particleNum,1);

%設定velocity上限與下限
vMin = -100;
vMax = 100;

%以Fuzzy Inference System的輸出計算每個particle的RMSE
for j = 1:particleNum
    %entering fuzzy inference system
    [Y_output, pCnsqParm{j}] = cFIS(H_train, Y_train, baseVarFuzzyN, p(j,:));
    rmse(j,1) = RMSE(Y_output, Y_train);
    pBestVal(j,1) = rmse(j,1);
end
    
%初始化gBest(if-part parameter), gBestValue(rmse), thenParm
[val, idx] = min(pBestVal);
gBest = pBest(idx,:);
gBestVal = val;
thenParm = pCnsqParm{idx};
    
for i = 1:tIter
    %setting end-loop criteria
    if gBestVal < error
        break;
    end
        
    %decrease velocity limit every 300 failures
    if failCount==30
        vMax = vMax/10;
        vMin = vMin/10;
        failCount = 0;
    end

    for j = 1:particleNum
        %確保velocity介於vMax與vMin之間
        v(j,:) = newV( v(j,:), p(j,:), 2,pBest(j,:),2,gBest(1,:));
        v(j,:) = rangeV(v(j,:), vMin, vMax);

        %更新p
        p(j,:) = newX( p(j,:),v(j,:) );
            
        %計算RMSE並更新pBest
        [Y_output, pCnsqParm{j}] = cFIS(H_train, Y_train, baseVarFuzzyN, p(j,:));
        rmse(j,1) = RMSE(Y_output, Y_train);
        if pBestVal(j,1) > rmse(j,1)
            pBest(j,:) = p(j,:);
            pBestVal(j,1) = rmse(j,1);
        end
    end
    disp(pBestVal);

    [val, idx] = min(rmse);

    %設定failCount
    if gBestVal-val < 0.00001
        failCount = failCount+1;
    end
    
    %更新gBest, gBestVal(RMSE)，並更新a0, a1, a2
    if  gBestVal > val
        gBestVal = val;
        gBest = pBest(idx,:);
        thenParm = pCnsqParm{idx};
    end
    fprintf('%d',i);

    %xAll紀錄訓練過程參數,yAll紀錄訓練過程RMSE
    xAll(i,:) = gBest;
    yAll(i) = gBestVal;
    fprintf(" %f\n",gBestVal);
end
end