function [] = model_plot(Y_predict_train,Y_train,Y_predict_test,Y_test,Loss)
%learning curve繪製

figure;
result_plot_lrnCurve(length(Loss), Loss);
title('Learning Curve');

%函數圖形繪製
figure;
result_plot_graph(1:500, Y_train, Y_predict_train);
title("Graph of training");

figure;
result_plot_graph(1:498, Y_test, Y_predict_test);
title("Graph of testing");

figure;
result_plot_graph(1:500, Y_train, Y_predict_train);
title("Graph of training");

figure;
result_plot_graph(1:498, Y_test, Y_predict_test);
title("Graph of testing");
end

