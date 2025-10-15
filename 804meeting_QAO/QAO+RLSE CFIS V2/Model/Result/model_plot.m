function [] = model_plot(Tr,Ts,Loss)
%learning curve繪製

Y_predict_train = Tr(:,1);
Y_train = Tr(:,2);
Y_predict_test = Ts(:,1);
Y_test = Ts(:,2);

figure;
result_plot_lrnCurve(length(Loss), Loss);
title('Learning Curve');

%函數圖形繪製
figure;
result_plot_graph(1:500, Y_train, Y_predict_train);
title("Graph of training");

figure;
result_plot_graph(501:1000, Y_test, Y_predict_test);
title("Graph of testing");

figure;
result_plot_graph(501:1000, Y_train, Y_predict_train);
title("Graph of training");

figure;
result_plot_graph(501:1000, Y_test, Y_predict_test);
title("Graph of testing");
end

