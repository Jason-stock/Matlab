
%% 第一題
first_iteration_result()
function first_iteration_result()
    % 設定參數
    R = 1; % 輸入數據維度
    S1 = 3; % 第一層神經元數量
    S2 = 4; % 第二層神經元數量
    S3 = 1; % 第三層神經元數量

    learning_rate = 0.01;

    % 初始化權重和閥值為0.2
    W1 = ones(S1, R) * 0.2; % 第一層權重
    b1 = ones(S1, 1) * 0.2; % 第一層閥值

    W2 = ones(S2, S1) * 0.2; % 第二層權重
    b2 = ones(S2, 1) * 0.2; % 第二層閥值

    W3 = ones(S3, S2) * 0.2; % 第三層權重
    b3 = ones(S3, 1) * 0.2; % 第三層閥值

    % 訓練數據對
    p_data = [-0.5; 0.1; 0.6]; % 輸入數據
    t_data = [1; 2; 3]; % 目標數據
    my_error_list = zeros(3,1); %記錄每一次的誤差值

    % 類神經網路模型
    for i = 1:length(p_data)
        p = p_data(i);
        t = t_data(i);

        % 前向傳播
        a1 = tanh(W1 * p + b1); % 第一層輸出 (Hyperbolic Tangent)
        a2 = sigmoid(W2 * a1 + b2); % 第二層輸出 (Log-Sigmoid)
        a3 = W3 * a2 + b3; % 第三層輸出 (Linear)

        % 計算誤差
        e = t - a3;
        my_error_list(i) = e;

        % 後向傳播計算靈敏度向量
        delta3 = e; % 第三層的誤差（線性）
        delta2 = (W3' * delta3) .* sigmoid_derivative(a2); 
        delta1 = (W2' * delta2) .* tanh_derivative(a1);

        % 更新權重和閥值
        W3_new = W3 + learning_rate * (delta3 * a2');
        b3_new = b3 + learning_rate * delta3;

        W2_new = W2 + learning_rate * (delta2 * a1');
        b2_new = b2 + learning_rate * delta2;

        W1_new = W1 + learning_rate * (delta1 * p);
        b1_new = b1 + learning_rate * delta1;

        % 顯示迭代一次的結果
        fprintf('淨輸入(Training Pair): (%f, %f)\n', p,t);
        fprintf('第一層輸出:\n');
        disp(a1);
        fprintf('第二層輸出:\n');
        disp(a2);
        fprintf('第三層輸出:%.4f\n', a3);
        fprintf('Error: %.4f\n', e);
        
        fprintf('Sensitivity Vectors:\n');
        fprintf('Sensitivity for Layer 3: %.4f\n', delta3);
        fprintf('Sensitivity for Layer 2: \n');
        disp(delta2);
        fprintf('Sensitivity for Layer 1: \n');
        disp(delta1);

        fprintf('Updated Weights and Biases of layer:\n');
        
        fprintf('W1:\n');
        disp(W1_new);
        
        fprintf('b1:\n');
        disp(b1_new);
        
        fprintf('W2:\n');
        disp(W2_new);
        
        fprintf('b2:\n');
        disp(b2_new);
        
        fprintf('W3:\n');
        disp(W3_new);
        
        fprintf('b3:\n');
        disp(b3_new);
        
    end
    % 印出所有error
    disp(my_error_list);
    % 計算MSE
    my_mse = mse(my_error_list);
    fprintf('MSE: %.4f\n', my_mse);

    function y = mse(x)
        a = 0;
        for j = 1:length(x)
            a = a+(x(j)^2);
            disp(a);
        end
        
        y = a./length(x);
    end

end

%% 第二題
function_approximation();
function function_approximation()
    % 設定參數
    R = 1; % 輸入數據維度
    S1 = 6; % 第一層神經元數量
    S2 = 4; % 第二層神經元數量
    S3 = 1; % 第三層神經元數量
    Q = 101; % 訓練數據點數量
    M = 25; % 測試數據點數量
    learning_rate = 0.01; % 學習率
    nT = 7000; % 訓練次數

    % 初始化權重和閥值（隨機初始化）
    W1 = rand(S1, R) ; % 第一層權重
    b1 = rand(S1, 1) ; % 第一層閥值

    W2 = rand(S2, S1) ; % 第二層權重
    b2 = rand(S2, 1) ; % 第二層閥值

    W3 = rand(S3, S2) ; % 第三層權重
    b3 = rand(S3, 1) ; % 第三層閥值

    % 生成訓練數據
    p_train = linspace(-2.4, 2.4, Q)'; % 訓練數據點
    g_train = 1 + sin((5 * pi / 3) * p_train); % 目標函數值

    % 生成測試數據
    p_test = linspace(-1.95, 1.95, M)'; % 測試數據點
    g_test = 1 + sin((5 * pi / 3) * p_test); % 測試目標函數值

    % 訓練過程中的MSE記錄
    mse_train = zeros(nT, 1);

    % 進行反向傳播訓練
    for epoch = 1:nT
        total_error = 0;
        
        for i = 1:Q
            p = p_train(i);
            t = g_train(i);

            % 前向傳播
            a1 = tanh(W1 * p + b1); % 第一層輸出
            a2 = sigmoid(W2 * a1 + b2); % 第二層輸出
            a3 = W3 * a2 + b3; % 第三層輸出 (線性)

            % 計算誤差
            e = t - a3;
            total_error = total_error + e^2;

            % 後向傳播計算靈敏度向量
            delta3 = e; % 第三層誤差（線性層）
            delta2 = (W3' * delta3) .* sigmoid_derivative(a2); % 第二層誤差
            delta1 = (W2' * delta2) .* tanh_derivative(a1); % 第一層誤差

            % 更新權重和閥值
            W3 = W3 + learning_rate * (delta3 * a2');
            b3 = b3 + learning_rate * delta3;

            W2 = W2 + learning_rate * (delta2 * a1');
            b2 = b2 + learning_rate * delta2;

            W1 = W1 + learning_rate * (delta1 * p);
            b1 = b1 + learning_rate * delta1;
        end

        % 計算MSE
        mse_train(epoch) = total_error / Q;
    end

    % 訓練結束後的MSE值
    fprintf('最佳MSE值 (訓練階段): %.6f\n', mse_train(end));

    % 測試階段
    a3_test = zeros(M, 1);
    for j = 1:M
        p = p_test(j);
        a1 = tanh(W1 * p + b1); % 第一層輸出
        a2 = sigmoid(W2 * a1 + b2); % 第二層輸出
        a3_test(j) = W3 * a2 + b3; % 第三層輸出 (線性)
    end

    % 測試階段的MSE
    mse_test = mean((g_test - a3_test).^2);
    fprintf('測試階段的MSE值: %.6f\n', mse_test);

    % 畫出學習曲線
    figure;
    x = 1:nT;
    plot(x, mse_train(x),'LineWidth',2);
    title('學習曲線');
    xlabel('疊代次數');
    ylabel('MSE');

    % 畫出訓練數據的函數逼近結果
    figure;
    plot(p_train, g_train, 'b-', 'LineWidth', 2); hold on;
    plot(p_train, g_train - mse_train(end), 'r--', 'LineWidth', 2); % 模型預測曲線
    title('訓練數據 - 函數逼近結果');
    xlabel('p');
    ylabel('g(p)');
    legend('目標函數', '模型輸出');

    % 畫出測試數據的函數逼近結果
    figure;
    plot(p_test, g_test, 'b-', 'LineWidth', 2); hold on;
    plot(p_test, a3_test, 'r--', 'LineWidth', 2); % 測試階段模型預測
    title('測試數據 - 函數逼近結果');
    xlabel('p');
    ylabel('g(p)');
    legend('目標函數', '模型輸出');
end

% Sigmoid 函數
function y = sigmoid(x)
    y = 1 ./ (1 + exp(-x));
end

% Tanh 函數
function y = tanh(x)
    y = (exp(x) - exp(-x)) ./ (exp(x) + exp(-x));
end

% Sigmoid 函數導數
function y_prime = sigmoid_derivative(y)
    y_prime = y .* (1 - y);
end

% Tanh 函數導數
function y_prime = tanh_derivative(y)
    y_prime = 1 - y.^2;
end
