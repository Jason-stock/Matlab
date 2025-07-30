inputs = [0.5;0.2;0.7];
outputs = deep_neural_network(inputs);
disp(outputs);

%第一題:神經元模組函式
function output = neuron(inputs, weights, bias, transfer_function)
    % inputs: 輸入值 (行向量)
    % weights: 權重 (列向量)
    % bias: 閥值 (標量)
    % transfer_function: 轉化函數

    % 計算輸入值與權重的內積，得到一個總和後(純量)，在與閥值(純量)相加。
    weighted_sum = weights * inputs + bias;
    % 應用轉化函數將得到的值做轉化。
    output = transfer_function(weighted_sum);
end

%第二題: 神經網路層模組函式
function layer_output = neural_layer(inputs, weights_matrix, biases, transfer_function)
    % inputs: 輸入值 (行向量)
    % weights_matrix: 權重矩陣 (每列對應一個神經元的權重)
    % biases: 閥值向量 (每個神經元一個閥值)
    % transfer_function: 轉化函數
    
    num_neurons = size(weights_matrix, 1);   % 獲取神經元數量
    layer_output = zeros(num_neurons, 1);   % 初始化輸出
    

    % 將input(行向量)、第1~N(神經元的數量)列的權重(列向量)、閥值，轉化函數帶入神經元
    for i = 1:num_neurons
        layer_output(i) = neuron(inputs, weights_matrix(i, :), biases(i), transfer_function);
    end
end

%第三題: 深度神經網路模組函式
function output = deep_neural_network(inputs)
    
    % inputs: 輸入值 (行向量)

    % 第一層參數設定 
    weights_layer1 =[-1.4827,1.7382,0.1663;
                     -0.043,-0.430,0.376;
                      0.960,-1.627,-0.226;
                      0.842,-1.453,-0.573];  % 4個神經元
    biases_layer1 = [-1.148;2.024;-2.359;-2.757];  
    
    % 第二層參數設定 
    weights_layer2 = [-0.509,0.317,0.777,0.317;
                      -1.321,0.138,0.622,0.317;
                      -0.454,-0.345,0.454,0.787;
                      -0.422,-0.787,0.784,0.424;
                      -0.737,-0.380,0.378,0.427];  % 4個來自第一層的輸出，5個神經元
    biases_layer2 = [0.052;-1.288;-0.371;-0.757;-0.563];
    
    % 第三層參數設定
    weights_layer3 =[0.052,-1.288,-0.371,-0.757,0.052;
                    -0.777,-1.999,-0.999,-0.999,-0.577];  % 5個來自第二層的輸出，2個神經元
    biases_layer3 = [-0.999;1.999];


    % 定義轉化函數
    transfer_function1 = @(x) double(x > 0);      % Hard Limit
    transfer_function2 = @(x) 1 ./ (1 + exp(-x)); % Log-Sigmoid
    transfer_function3 = @(x) max(0, min(x, 1));   % Saturating Linear

    % 計算各層輸出
    output_layer1 = neural_layer(inputs, weights_layer1, biases_layer1, transfer_function1);
    output_layer2 = neural_layer(output_layer1, weights_layer2, biases_layer2, transfer_function2);
    output_layer3 = neural_layer(output_layer2, weights_layer3, biases_layer3, transfer_function3);

    output = output_layer3;  % 最終輸出

end


