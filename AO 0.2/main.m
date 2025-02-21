%_______________________________________________________________________________________%
%  Aquila Optimizer (AO) source codes (version 1.0)                                     %
%                                                                                       %
%  Developed in MATLAB R2015a (7.13)                                                    %
%  Author and programmer: Laith Abualigah                                               %
%  Abualigah, L, Yousri, D, Abd Elaziz, M, Ewees, A, Al-qaness, M, Gandomi, A.          %
%         e-Mail: Aligah.2020@gmail.com                                                 %
%       Homepage:                                                                       %
%         1- https://scholar.google.com/citations?user=39g8fyoAAAAJ&hl=en               %
%         2- https://www.researchgate.net/profile/Laith_Abualigah                       %
%                                                                                       %
%   Main paper:                                                                         %
%_____________Aquila Optimizer: A novel meta-heuristic optimization algorithm___________%
%__Main paper: please, cite it as follws:_______________________________________________%

%Abualigah, L., Yousri, D., Elaziz, M.A., Ewees, A.A., A. Al-qaness, M.A., Gandomi, A.H.%
%Aquila Optimizer: A novel meta-heuristic optimization Algorithm,          
%Computers & Industrial Engineering (2021), doi:https://doi.org/10.1016/j.cie.2021.107250 
% Computers & Industrial Engineering.
%_______________________________________________________________________________________%

clear all 
clc

Solution_no=50;     
M_Iter=1000;
run_times = 30;


numbers = 13;

every_times_best = zeros(run_times,numbers);

for r = 1 : run_times
for i = 1 : numbers
    [LB,UB,Dim,F_obj]=Get_F("F"+num2str(i)); 
    [Best_FF,Best_P,conv]=AO(Solution_no,M_Iter,LB,UB,Dim,F_obj);  


    % figure('Position',[454   445   694   297]);
    % subplot(1,2,1);
    % func_plot("F"+num2str(i));
    % title('Parameter space')
    % xlabel('x_1');
    % ylabel('x_2');
    % zlabel(["F"+num2str(i),'( x_1 , x_2 )'])
    % 
    % 
    % subplot(1,2,2);
    % semilogy(conv,'Color','r','LineWidth',2)
    % title('Convergence curve')
    % xlabel('Iteration#');
    % ylabel('Best fitness function');
    % axis tight
    % legend('Aquila (AO)')
    every_times_best(r,i) = Best_FF;


    display(['The best-obtained solution by AO is : ', num2str(Best_P)]);
    display(['The best optimal values of the objective funciton found by AO is : ', num2str(Best_FF)]);

end
end

mean_value = mean(every_times_best);   % 每列的平均值
std_value = std(every_times_best);     % 每列的標準差
min_value = min(every_times_best);     % 每列的最小值
max_value = max(every_times_best);     % 每列的最大值

fprintf('平均值: %f\n', mean_value);
fprintf('標準差: %f\n', std_value);
fprintf('最小值: %f\n', min_value);
fprintf('最大值: %f\n', max_value);       



