% 較複雜的PDF: P(x) = 3x^2, x in [0,1]

% 1. 抽樣參數
N = 10000;
u = rand(N,1);  % 均勻分布 U(0,1)

% 2. 使用反CDF產生樣本
x_samples = u.^(1/3);   % 因為 F(x) = x^3 ⇒ x = u^(1/3)

% 3. 繪圖
figure;

% (a) 樣本的直方圖
subplot(2,1,1);
histogram(x_samples, 50, 'Normalization', 'pdf');
title('逆變換抽樣樣本分佈 (P(x) = 3x^2)');
xlabel('x'); ylabel('PDF 估計');
hold on;
x = linspace(0,1,100);
plot(x, 3*x.^2, 'r-', 'LineWidth', 2);
legend('樣本直方圖', '理論 PDF','Location', 'northwest');

% (b) 畫出CDF與反CDF
subplot(2,1,2);
fplot(@(x) x.^3, [0 1], 'b', 'LineWidth', 2); hold on;
fplot(@(u) u.^(1/3), [0 1], 'r--', 'LineWidth', 2);
title('CDF 與其反函數');
xlabel('x 或 u'); ylabel('F(x) / F^{-1}(u)');
legend('F(x) = x^3', 'F^{-1}(u) = u^{1/3}','Location', 'northwest');
grid on;

%%
% 數值逆變換抽樣 - 使用 Beta(2.5, 3.5) 分布為例

% 1. 定義 PDF
alpha = 2.5;
beta_param = 3.5;
B = beta(alpha, beta_param);  % 正確呼叫 Beta 函數

pdf_func = @(x) (x.^(alpha-1) .* (1 - x).^(beta_param-1)) / B;


% 2. 建立 x 網格並計算 PDF
x_grid = linspace(0, 1, 10000);
pdf_vals = pdf_func(x_grid);

% 3. 計算 CDF（使用累加近似積分）
% dx = x_grid(2) - x_grid(1);
cdf_vals = cumtrapz(x_grid, pdf_vals);
cdf_vals = cdf_vals / cdf_vals(end);  % 正規化至 [0,1]

% 4. 數值反CDF（建立插值函數）
inv_cdf_func = @(u) interp1(cdf_vals, x_grid, u, 'linear', 'extrap');

% 5. 產生樣本
N = 10000;
u = rand(N,1);
x_samples = inv_cdf_func(u);

% 6. 視覺化
figure;

% (a) 樣本的直方圖 + 理論 PDF
subplot(2,1,1);
histogram(x_samples, 50, 'Normalization', 'pdf');
hold on;
plot(x_grid, pdf_vals, 'r', 'LineWidth', 2);
title('數值逆變換抽樣樣本與理論 PDF');
xlabel('x'); ylabel('PDF');
legend('樣本直方圖', '理論 PDF', 'Location', 'northwest');

% (b) 理論 CDF 與反CDF
subplot(2,1,2);
plot(x_grid, cdf_vals, 'b', 'LineWidth', 2); hold on;
plot(cdf_vals, x_grid, 'r--', 'LineWidth', 2);
title('CDF 與其數值反函數');
xlabel('x / u'); ylabel('F(x) / F^{-1}(u)');
legend('F(x)', 'F^{-1}(u)', 'Location', 'northwest');
grid on;
