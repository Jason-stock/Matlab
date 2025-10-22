% 清理工作區和命令視窗
clear; clc;

% --- 1. 定義物理常數 ---
% 在原子單位制 (atomic units) 下，波耳半徑 a_0 = 1。
% 這個常數在歸一化計算中會被約掉，所以設為 1 不影響最終的驗證結果。
a0 = 1.0;

% --- 2. 定義被積分的函數 ---
% integral3 函數需要一個以 (x, y, z) 為參數的函數句柄 (function handle)。
% 我們需要將球座標 (r, θ, φ) 映射到 (x, y, z)。
% MATLAB 的積分順序是：先對 z (內層)，再對 y，最後對 x (外層)。
% 我們的積分順序是：先對 r (內層)，再對 θ，最後對 φ (外層)。
% 因此，我們建立如下映射：
% x -> φ (phi)
% y -> θ (theta)
% z -> r
integrand = @(x, y, z) (1 / (pi * a0^3)) .* exp(-2 .* z ./ a0) .* z.^2 .* sin(y);

% --- 3. 設定積分的上下限 ---
% x (phi) 的範圍: 0 到 2π
phi_min = 0;
phi_max = 2 * pi;

% y (theta) 的範圍: 0 到 π
theta_min = 0;
theta_max = pi;

% z (r) 的範圍: 0 到 無窮大
r_min = 0;
r_max = inf;

% --- 4. 執行三重積分 ---
% integral3 的參數順序是：被積函數, xmin, xmax, ymin, ymax, zmin, zmax
result = integral3(integrand, phi_min, phi_max, theta_min, theta_max, r_min, r_max);

% --- 5. 輸出結果 ---
fprintf('=== 氫原子 1s 波函數歸一化數值驗證 (MATLAB) ===\n');
fprintf('三重積分的計算結果: %.15f\n', result);

% 檢查結果是否在一個很小的容忍誤差內等於 1
tolerance = 1e-9;
if abs(result - 1.0) < tolerance
    fprintf('\n結論：計算結果非常接近 1，成功驗證了 Ψ_1s 波函數是歸一化的！\n');
else
    fprintf('\n結論：計算結果與 1 有明顯差距，請檢查程式碼或積分設定。\n');
end