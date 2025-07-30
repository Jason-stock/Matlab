%%
%使用eval劃出正弦取線
x = 0:pi/100:2*pi;
str = 'figure ; y = sin(2*x) ; plot(x,y) ; legend("sin2x")';

eval(str);
%%
for n = 3:5
    eval(['M' num2str(n) '=magic(n)'])
end
%%
str1 = 'x = 0:0.5:2*pi ; y = sin(2*x)';
str2 = 'x = 0:0.5:2*pi ; y = cos(2*x);';
T1 = evalc(str1);
T2 = evalc(str2);
%%  輸入兩個變數x跟y，如果x>y的話，x與y交換

x = input('x=');
y = input('y=');

if(x>y)
    t = x;
    x = y;
    y = t;
end
disp(x);
disp(y);
%%
n = 1;
for i = 1:20
    n = n.*i;
end
disp(n);
%%
if('m'>'N')
    disp('m較大');
else
    disp('N較大');
end
%%
a = input('輸入一個數字');
if(mod(a,5)==0)
    disp(a+"是五的倍數");
end
%%  將輸入的三個數做排序，將最大的數存入a，最小的數存入c

a = input('輸入第一個數字:');
b = input('輸入第二個數字:');
c = input('輸入第三個數字:');

if(a<b)
    t = a;
    a = b;
    b = t;
end
if(a<c)
    t = a;
    a = c;
    c = t;
end
if(b<c)
    t = b;
    b = c;
    c = t;
end
disp(a+""+b+""+c);
%%  將矩陣的兩個對角線做相加，並將答案印出
A = [1,2,3;4,5,6;7,8,9];
sum1 = 0;
i = 1;
j = 1;
while(i<=length(A))
    sum1 = sum1+A(i,j);
    i = i+1;
    j = j+1;
end
sum2 = 0;
k = length(A);
f = length(A);
while(k>0)
    sum2 = sum2+A(k,f);
    k = k-1;
    f = f-1;
end
disp(sum1);
disp(sum2);

%%  使使用if-else操作數學公式
% 1/1-1/2+1/3-1/4+......+1/99-1/100
ans = 0;
for i = 1:100
    if(mod(i,2)==0)
        ans = ans-1/i;
    else
        ans = ans+1/i;
    end
end
disp(ans);
%%  使用while回全找出費氏數列中剛好>1000的那個數
a1 = 1;
a2 = 1;
ans = 0;

while(ans<1000)
    ans = a1+a2;
    a1 = a2;
    a2 = ans;
end

disp(ans);
%%  使用while迴圈找出費氏數列中<=100的所有數(n1 = 1; n2 = 1; nk = nk-1 + nk-2)
n1 = 1;
n2 = 1;
ans = 0;

while(ans<100)
    ans = n1+n2;
    if(ans<100)
        disp(ans);
    end
    n1 = n2;
    n2 = ans;
end

%%  依照輸入的值，放入對應的方程式做計算，並將答案印出(if-elseif-else用法)
x = input("輸入一個數字:");
if x<1
    ans = 2*x+3;
elseif x>=1 && x<=3
    ans = x^2-3;
else
    ans = x^2-3*x+3;
end
disp(ans);

%%  依照輸入的價格給予折扣，並將折扣後的價格印出(if-elseif-else用法)
price = input("輸入一個價格:");

if price < 1000 && price > 0
    disp("沒有折扣，您購買的價格為 " + string(price));
elseif price < 2000 && price >= 1000
    discount = price * 0.02;
    disp("2%折扣，您購買的價格為 " + string(price - discount));
elseif price < 3000 && price >= 2000
    discount = price * 0.03;
    disp("3%折扣，您購買的價格為 " + string(price - discount));
elseif price < 4000 && price >= 3000
    discount = price * 0.05;
    disp("5%折扣，您購買的價格為 " + string(price - discount));
elseif price < 5000 && price >= 4000
    discount = price * 0.08;
    disp("8%折扣，您購買的價格為 " + string(price - discount));
elseif price >= 5000
    discount = price * 0.1;
    disp("10%折扣，您購買的價格為 " + string(price - discount));
else
    disp("您輸入的價格錯誤");
end
%%  輸入一個成績，依照輸入的成績的等級，發放獎學金(switch case用法)
a = input("請輸入一個成績:","s");
switch(a)
    case 'A'
        disp("恭喜!你的獎學金為1000元");
    case 'B'
        disp("恭喜!你的獎學金為500元");
    case 'C'
        disp("恭喜!你的獎學金為100元");
    case 'D'
        disp("抱歉，沒有獎學金");
    case 'E'
        disp("抱歉，沒有獎學金");
    case 'F'
        disp("抱歉，沒有獎學金");
    otherwise
        disp("成績輸入錯誤，請重新輸入");
end

%%  印出一個9*9乘法表
for i = 1:9
    for j = 1:9
        A(i,j) = i*j;
    end
end
disp(A);

%%  印出一個高度4，寬度為7的金字塔
str = "";
for i = 1:4
    for j = 1:4-i
        str = str + sprintf(' ');  %sprintf可以將output的值存入變數
    end
    for k = 1:2*i-1
        str = str + sprintf("*");
    end
    str = str + sprintf('\n');
end
disp(str);

%% 將for與switch case用法一起使用

for i = 1:5
    for j = 1:5
        switch(i-j)
            case 0
                A(i,j) = 2;
            case -1
                A(i,j) = 1;
            case 1
                A(i,j) = 1;
            otherwise
                A(i,j) = 0;
        end
    end
end

disp(A);
            
%% 使用while求1+2+3+4+...+100
i = 1; sum = 0;
while(i<=100)
    sum = sum+i;
    i = i+1;
end
disp(sum);

%% 使用while，求1+2+3+...n>=100的最小整數n
i = 0; sum = 0;
while(sum<100)
    i = i+1;
    sum = sum+i;
end
disp(i);

%%  使用遞迴，算出費是數列的第n項
function output =  fib(n)
   if(n==1)
       output = 1;
   elseif(n==2)
       output = 2;
   else
       output = fib(n-1)+fib(n-2);
   end
end

disp(fib(10));

%%  利用continue敘述控制迴圈
n = 0;
A = -20+40*rand(1,100);  %在區間[-20,20]隨機建立100個數
for i = 1:50
    if A(i)<=0
        continue  %若為負數或零，則跳出本次迴圈
    end
    n = n+1;  %統計正數的個數
    B(n) = A(i);  %將正數存在陣列B中
end
disp(n);
plot(B,'*b:');
grid on;

%%  利用break敘述控制迴圈

A(1) = 1;  %Fibonacci級數A(1) = 1，A(2) = 1
A(2) = 1;
for i = 3:1000
    A(i) = A(i-1)+A(i-2);
    if(A(i)>1000)
        n = i;
        ans = A(i);
        break;
    end
end

disp(n);
disp(ans);

plot(A , '*b:');

%%  keyboard用法
a = [1 2 3;4 5 6];
b = [2 3 4;5 6 7];
keyboard
c = a+b;
disp(c);

%%
for i = 1:10
    disp(i);
end
%%
for i = 1:2:10
    disp(i);
end

%%
for i = [10, 20, 30]
    fprintf('Value: %d\n', i);
end