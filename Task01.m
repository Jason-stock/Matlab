x0 = 20;  %初始點設為20
nT = 40;  %初始更新次數
itr_times = 2;  %計算更新次數

all_min = find_min(x0);  %將初始值帶入將初始值帶入find_min，生成100個隨機值，並找出最小值


while itr_times <= nT
   temp_min = find_min(all_min);
   if temp_min < all_min
       all_min = temp_min;
   end
   itr_times = itr_times+1;
   
end

disp(all_min)


% 要找最小值的函式
function y = func(x)
    y = x*x'+10;
end

%% 使用高斯分佈來生成區間的X座標 

function y = rand_generate_100(x) 
    mu = 0; % mu均值 : 這是正態分佈的中心位置，表示隨機數的平均值
    sigma = 1; % 標準差 : 這是衡量數據分散程度的參數，表示隨機數的波動範圍
    data = normrnd(mu, sigma, [100, 1]); % 生成100个隨機數
    data(data < -1) = -1; % 將小於-1的值設為-1 
    data(data > 1) = 1;   % 將大於1的值設為1 (區間設定為[-1:1])
    y = data+x;
    disp(y)
end


%% 在區間內生成100個點，並將100個點帶入函數求得最小值

function min_data = find_min(x)
    input = rand_generate_100(x); %以初始點為中心，設立100個位置(使用高斯分佈生成隨機量)

    

    min = func(input(1));
    for i = 1:length(input)
        if func(input(i)) < min
            min = func(input(i));
        end
    end
    disp(min);
    min_data = min;
    
end