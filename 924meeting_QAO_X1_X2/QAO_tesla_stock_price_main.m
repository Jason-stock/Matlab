addpath(fullfile(pwd, 'Model'),fullfile(pwd, 'Model/Result'));
data = load("Tesla Stock Price History.csv");

disp(data);

%使用optimizer找出模型最佳參數
% tIter = 30;
% for r = 1:nRuns
%     fprintf('=== 第 %d 次實驗 ===\n', r);
%     [ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer(H_train, Y_train, tIter);
%     finalRMSEs(r) = lossAll(end);        % 記錄最後 RMSE
% 
%     %使用approxiamtor預測資料
%     Y_predict_train = approximator(H_train, ifParm, cnsqParm, baseVarFuzzyN);
%     Y_predict_test = approximator(H_test, ifParm, cnsqParm, baseVarFuzzyN);
% 
%     %輸出圖形與損失值
%     printLoss(Y_predict_train, Y_train, Y_predict_test, Y_test);
%     model_plot([Y_predict_train,Y_train],[Y_predict_test,Y_test], lossAll );
% end
% 
% % ====== 計算統計量 ======
% bestVal = min(finalRMSEs);
% worstVal= max(finalRMSEs);
% meanVal = mean(finalRMSEs);
% stdVal  = std(finalRMSEs);
% 
% % ====== 顯示統計結果 ======
% fprintf('\n========= 統計結果 (共 %d 次) =========\n', nRuns);
% fprintf('Best  RMSE: %.6f\n', bestVal);
% fprintf('Worst RMSE: %.6f\n', worstVal);
% fprintf('Mean  RMSE: %.6f\n', meanVal);
% fprintf('Std   RMSE: %.6f\n', stdVal);
% 
% rmpath(fullfile(pwd, 'Model'),fullfile(pwd, 'Model/Result'));