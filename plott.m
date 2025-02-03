%%
hold on
plot(cos(0:pi/20:2*pi),'or--');
plot(sin(0:pi/20:2*pi),'xg:');
hold off
%%
x=0:0.5:4*pi;
y=sin(x); h=cos(x); w=1./(1+exp(-x));
g=(1/(2*pi*2)^0.5).*exp((-1.*(x-2*pi).^2)./(2*2^2));
plot(x,y,'bd-',x,h,'gp:',x,w,'ro-',x,g,'c^-');

legend('sin(x)','cos(x)','Sigmoid','Gauss function');
%%
x = 0:0.1:2*pi; 
y1 = sin(x);
y2 = exp(-x); 
plot(x, y1, '--*', x, y2, ':o');
xlabel('t = 0 to 2\pi');
ylabel('values of sin(t) and e^{-x}');
title('Function Plots of sin(t) and e^{-x}');
legend('sin(t)','e^{-x}');

%%
x = linspace(0,3); 
y = x.^2.*sin(x); 
plot(x,y); 
line([2,2],[0,2^2*sin(2)]); 
str = '$$ \int_{0}^{2} x^2\sin(x) dx $$'; 
text(0.25,2.5,str,'Interpreter','latex');
annotation('arrow','X',[0.32,0.5],'Y',[0.6,0.4]);  
% X的起始位置、結束位置，Y的起始位置、結束位置。
% 其中 (0, 0) 表示圖形的左下角，而 (1, 1) 表示右上角。

%%
x = linspace(0, 2*pi, 1000);
y = sin(x); h = plot(x,y); 
get(h)
set(gca, 'XLim', [0, 2*pi],'FontSize', 25);
% 限制X軸的軸距與設定文字的大小
set(gca, 'YLim', [-1.2, 1.2],'FontSize', 25);
% 限制Y軸的軸距與設定文字的大小
set(gca, 'XTick', 0:pi/2:2*pi);
% 設定X軸的刻度
set(gca, 'XTickLabel', 0:90:360);
% 設定Y軸的刻度形式
%%
[x,y] = meshgrid(-10:0.1:10 , -10:0.1:10);
z = 4*sin(2*(x.^2+y.^2).^0.5)./(x.^2+y.^2).^0.5;

figure(1);
mesh(x,y,z);
xlabel('x軸');
ylabel('y軸');
zh = zlabel('z軸');
set(zh,'Rotation',90);
title('三維圖型');

figure(2);
contour3(x, y, z, 30);
xlabel('x軸');
ylabel('y軸');
zh = zlabel('z軸');
set(zh,'Rotation',360);
title('三維圖型的等高線圖');

figure(3);
fixed_z_value1 = 0;
fixed_z_value2 = 5;
contour(x, y, z, [fixed_z_value1 fixed_z_value2]);
xlabel('x軸');
ylabel('y軸');
set(zh,'Rotation',360);
title('x=0的等高線圖');
%%
[x, y] = meshgrid(-5:0.5:5, -5:0.5:5);
z = x.^2 + y.^2;

figure; 
fig = mesh(x, y, z); 
%設定x軸，y軸，z軸以及標題的名稱
xlabel('X 軸'); 
ylabel('Y 軸');
zh = zlabel('Z 軸');
set(zh, 'Rotation', 360); %將zlabel轉180度
title('三維圖型');

grid on;
%%
theta = linspace(0, 2*pi, 50);
rho = sin(0.5*theta);
[x, y] = pol2cart(theta, rho);	% 由極座標轉換至直角座標
compass(x, y);
