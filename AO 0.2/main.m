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

Solution_no=20;  
F_name='F1';    
M_Iter=1000;    



[LB,UB,Dim,F_obj]=Get_F(F_name); 
[Best_FF,Best_P,conv]=AO(Solution_no,M_Iter,LB,UB,Dim,F_obj);  

figure('Position',[454   445   694   297]);
subplot(1,2,1);
func_plot(F_name);
title('Parameter space')
xlabel('x_1');
ylabel('x_2');
zlabel([F_name,'( x_1 , x_2 )'])


subplot(1,2,2);
semilogy(conv,'Color','r','LineWidth',2)
title('Convergence curve')
xlabel('Iteration#');
ylabel('Best fitness function');
axis tight
legend('Aquila (AO)')


display(['The best-obtained solution by AO is : ', num2str(Best_P)]);
display(['The best optimal values of the objective funciton found by AO is : ', num2str(Best_FF)]);

        



