function f = func(x, func_id)
    switch func_id
        case 1 % Sphere function
            f = sum(x.^2);
        case 2 % Schwefel 2.22 function
            f = sum(abs(x)) + prod(abs(x));
        case 3 % Schwefel 1.2 function
            f = sum(arrayfun(@(k) sum(x(1:k))^2, 1:length(x)));
        case 4 % Schwefel 2.21 function
            f = max(abs(x));
        case 5 % Rosenbrock function
            f = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (x(1:end-1) - 1).^2);
        case 6 % Step function
            f = sum(floor(x + 0.5).^2);
        case 7 % Quartic function
            f = sum((1:length(x)) .* (x.^4)) + rand;
        case 8 % Schwefel function
            f = 418.9829*length(x) - sum(x .* sin(sqrt(abs(x))));
        case 9 % Rastrigin function
            f = sum(x.^2 - 10*cos(2*pi*x) + 10);
        case 10 % Ackley function
            f = -20*exp(-0.2*sqrt(mean(x.^2))) - exp(mean(cos(2*pi*x))) + 20 + exp(1);
        case 11 % Griewank function
            f = sum(x.^2)/4000 - prod(cos(x ./ sqrt(1:length(x)))) + 1;
        case 12 % Penalized function 1
            y = 1 + (x+1)/4;
            f = pi/length(x) * (10*sin(pi*y(1))^2 + sum((y(1:end-1)-1).^2 .* (1+10*sin(pi*y(2:end)).^2)) + (y(end)-1)^2) + sum(100*max(0,x-10).^4 + 100*max(0,-x-10).^4);
        case 13 % Penalized function 2
            f = 0.1*(sin(3*pi*x(1))^2 + sum((x(1:end-1)-1).^2 .* (1+sin(3*pi*x(2:end)).^2)) + (x(end)-1)^2 * (1+sin(2*pi*x(end))^2)) + sum(100*max(0,x-10).^4 + 100*max(0,-x-10).^4);
        otherwise
            error('Invalid function ID');
    end
end
