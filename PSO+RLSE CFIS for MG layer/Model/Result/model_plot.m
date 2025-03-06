function [] = model_plot(Tr,Ts,Loss)
%learning curve繪製
Y_predict_train = Tr(:,1);
Y_train = Tr(:,2);
Y_predict_test = Ts(:,1);
Y_test = Ts(:,2);

subplot(2,2,1);
result_plot_lrnCurve(length(Loss), Loss);
title('Learning Curve');

subplot(2,2,2);
error_train = Y_predict_train-Y_train;
error_test = Y_predict_test-Y_test;
result_plot_error(1:500, real(error_train), 1:500, real(error_test ));
title('Function approximation error');

%函數圖形繪製
subplot(2,2,3);
result_plot_graph(1:500, Y_train, real(Y_predict_train));
title("Graph of training");

subplot(2,2,4);
result_plot_graph(501:1000, Y_test, real(Y_predict_test));
title("Graph of testing");
end

