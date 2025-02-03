function ave = calculateAvg(x)
    ave = sum(x(:))/numel(x);
end

z = 1:99;
ave = calculateAvg(z);

disp(ave);