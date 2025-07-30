%%
for i = 1:10
    x = linspace(0,10,101);
    plot(x,sin(x+i));
    print(gcf,'deps',strcat('plot',num2str(i),'.ps'));
end

%%
n = 1;
while prod(1:n) < 1e100
    n = n+1;
end

disp(n);
%%
sum = 0;
i = 1;
while i <= 999
    sum = sum+i;
    i = i+1;
end 
%%
i = 1;
for n = 1:2:10
    a(i) = 2^n;
    i = i+1;
end

disp(a);
%%
M1 = [0,-1,4;9,-14,25;-34,49,64];
for i = 1:length(M1)
    for j = 1:length(M1)
        if M1(i,j)<0
            M1(i,j)=0;
        end
        M2(i,j) = M1(i,j);
    end
end

disp(M2);
%%
x = linspace(0, 2*pi, 100);	% 在 0 到 2*pi 間，等分取 100 個點  
plot(x, sin(x),'displayName', x, cos(x),'displayName', x, sin(x)+cos(x),'displayName');	% 進行多條曲線描點作圖 

%%
y = peaks;
plot(y)
%%
x = peaks;  
y = x';		% 求矩陣 x 的轉置矩陣 x' 
plot(x, y);	% 取用矩陣 y 的每一行向量，與對應矩陣 x 			% 的每一個行向量作圖
%%
x = randn(30);	% 產生 30×30 的亂數(正規分佈)矩陣
z = eig(x);	% 計算 x 的「固有值」(或稱「特徵值」)
plot(z, 'o')
grid on		% 畫出格線

%%
x = linspace(0, 8*pi);	% 在 0 到 8*pi 間，等分取 100 個點
semilogx(x, sin(x));    % 使 x 軸為對數刻度，並對其正弦函數作圖

%%
x = 0:0.5:4*pi;		 % x 向量的起始與結束元素為 0 及 4*pi，0.5為各元素相差值
y = sin(x); 
plot(x, y, 'k:diamond');	% 其中「k」代表黑色，「：」代表點線，而「diamond 」則指定菱形為曲線的線標

%%
x = 0:0.1:4*pi;		% 起始與結束元素為 0 及 4，0.1 為各元素相差值
y = sin(x);
plot(x, y);
axis([-inf, inf, 0, 1]);	% 畫出正弦波 y 軸介於 0 和 1 的部份

%%
my_sum = zeros(1,10);
for i = 1:10
    my_sum(i) = i;
end

disp(my_sum);
%%

w3 = rand(3,4);
disp(w3);