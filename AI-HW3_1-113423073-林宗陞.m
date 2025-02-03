%% 第一題
% 高斯歸屬函數
gaussian_membership = @(h, c, sigma) exp(-0.5 * ((h - c) ./ sigma) .^ 2);

% 實驗結果1：在題目給定範圍內設定1000個點並繪製 μA(hx) 和 μB(hy)
hx_vals_1 = linspace(-3, 4, 1000);
hy_vals_1 = linspace(-1, 5, 1000);

% 計算 μA(hx) 和 μB(hy)
muA_hx_1 = gaussian_membership(hx_vals_1, 3, 7);
muB_hy_1 = gaussian_membership(hy_vals_1, 5, 4);

% 繪製 μA(hx) 和 μB(hy)
figure;
subplot(1, 2, 1);
plot(hx_vals_1, muA_hx_1, 'b');
xlabel('h_x');
ylabel('\mu_A(h_x)');
title('Membership Function \mu_A(h_x)');

subplot(1, 2, 2);
plot(hy_vals_1, muB_hy_1, 'r');
xlabel('h_y');
ylabel('\mu_B(h_y)');
title('Membership Function \mu_B(h_y)');

% 實驗結果2：設定範圍及參數，並計算 μA×B(hx, hy) 和 μA+B(hx, hy)
hx_vals_2 = linspace(-3, 2, 1000);
hy_vals_2 = linspace(-3, 2, 1000);

% 創建網格(建立對應的二維陣列、以利於畫三維圖)
[hx_grid, hy_grid] = meshgrid(hx_vals_2, hy_vals_2);

% 計算 μA(hx) 和 μB(hy) 對應的網格值
muA_hx_2 = gaussian_membership(hx_grid, 2, 0.8);
muB_hy_2 = gaussian_membership(hy_grid, 0.9, 0.4);

% 計算笛卡爾積和聯積
muA_times_B = min(muA_hx_2, muB_hy_2);
muA_plus_B = max(muA_hx_2, muB_hy_2);


% 笛卡爾積
figure
mesh(hx_grid, hy_grid, muA_times_B);
xlabel('h_x');
ylabel('h_y');
zlabel('\mu_{A \times B}(h_x, h_y)');
title('Cartesian Product \mu_{A \times B}(h_x, h_y)');

% 笛卡爾聯積
figure
mesh(hx_grid, hy_grid, muA_plus_B);
xlabel('h_x');
ylabel('h_y');
zlabel('\mu_{A + B}(h_x, h_y)');
title('Cartesian Co-product \mu_{A + B}(h_x, h_y)');

