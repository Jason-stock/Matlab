% 檔案名稱: generate_hydrogen_dist_v2.m
function generate_hydrogen_dist_v2(num_points, num_bins)
    
    fprintf('正在生成 %d 個隨機點 (v2)...\n', num_points);
    % === 修改點 1: 呼叫移除鉗位操作的版本 ===
    r_norm = inverse_transform_sampling_no_clamp(num_points);
    fprintf('生成完畢。\n');

    % 為了能看見尾部，我們將統計範圍稍微擴大
    max_range = 1.5; % 例如統計到 r_norm = 1.5 (對應 r=9)
    
    fprintf('正在將點分配到 %d 個區間中...\n', num_bins);
    [counts, edges] = histcounts(r_norm, 'NumBins', num_bins, 'BinLimits', [0, max_range]);
    
    bin_width = edges(2) - edges(1);
    bin_centers = edges(1:end-1) + bin_width / 2;
    
    fprintf('正在繪製圖表 (v2)...\n');
    figure;
    
    pdf_y_values = counts / (num_points * bin_width);
    
    bar(bin_centers, pdf_y_values, 'hist');
    
    title(sprintf('氫原子 1s 徑向機率分佈 (N = %d)', num_points), 'FontSize', 16);
    xlabel('標準化半徑 (r / 6a₀)', 'FontSize', 12); % x 軸的意義變為 r/6a0
    ylabel('機率密度', 'FontSize', 12);
    xlim([0, max_range]);
    grid on;
    set(gca, 'FontSize', 11);
    
    fprintf('圖表繪製完成！\n');
end

function r_norm = inverse_transform_sampling_no_clamp(dim)
    % ... (這部分演算法與之前完全相同) ...
    u = rand(1, dim);
    r = ones(1, dim);
    max_iter = 20;
    tol = 1e-8;
    for i = 1:dim
        g  = @(x) 1 - (2*x^2 + 2*x + 1) * exp(-2*x) - u(i);
        gp = @(x) 4 * x.^2 .* exp(-2*x);
        ri = (u(i) < 0.5) * 0.5 + (u(i) >= 0.5) * 2.0;
        for it = 1:max_iter
            fx = g(ri);
            if abs(fx) < tol, break; end
            fpx = gp(ri);
            if abs(fpx) < 1e-12, ri = ri + tol; continue; end
            ri_new = ri - fx / fpx;
            if ri_new < 0, ri_new = tol; elseif ri_new > 10, ri_new = 10; end
            if abs(ri_new - ri) < tol, ri = ri_new; break; end
            ri = ri_new;
        end
        r(i) = ri;
    end
    
    % === 修改點 2: 只進行標準化，不進行鉗位操作 ===
    r_norm = r / 6.0;
end

generate_hydrogen_dist_v2(5000000, 500);

% 執行完畢後，您會得到一張圖，並且工作區 (Workspace) 中會有名為
% counts_data 和 centers_data 的變數，裡面儲存了統計數據。