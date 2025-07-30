function [] = model_plot(Tr,Ts,Loss)
%learning curve繪製
Y_predict_train = Tr(:,1);
Y_train = Tr(:,2);
Y_predict_test = Ts(:,1);
Y_test = Ts(:,2);

figure;
result_plot_lrnCurve(length(Loss), Loss);
title('Learning Curve');

figure;
error_train = Y_predict_train-Y_train;
error_test = Y_predict_test-Y_test;
result_plot_error(1:300, real(error_train), 1:297, real(error_test ));
title('Function approximation error');

%函數圖形繪製
figure;
result_plot_graph(1:300, Y_train, real(Y_predict_train));
title("Graph of training");

figure;
result_plot_graph(1:297, Y_test, real(Y_predict_test));
title("Graph of testing");
end

