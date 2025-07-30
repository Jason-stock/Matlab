% MATLAB script to visualize the Complex Gaussian Membership Function (cGMF)

% Define parameters
m = 0;  % Mean
sigma = 2;  % Spread
lambda = 60;  % Phase frequency factor
h = linspace(-10, 10, 10000);  % Base variable


% Compute amplitude and phase terms
rs = exp(-0.5 * ((h - m) / sigma).^2);
omega_s = -exp(-0.5 * ((h - m) / sigma).^2) .* ((h - m) / sigma^2) * lambda;


% Compute complex membership function
real_part = rs .* cos(omega_s);
imag_part = rs .* sin(omega_s);


% Plotting the 3D parametric curve
figure;
plot3(real_part, h, imag_part, 'r', 'LineWidth', 1.5);
grid on;
xlabel('real-part of membership');
ylabel('h');
zlabel('imaginary-part of membership');
title('Complex Gaussian Membership Function (cGMF)');



% (b) Real, Imaginary, and Amplitude vs. Base Variable
figure;
amp_func = exp(-0.5 * ((h - m) / sigma).^2);
plot(h, amp_func, 'g', 'LineWidth', 2); % Amplitude function
hold on;
plot(h, exp(-0.5 * ((h - m) / sigma).^2) .* cos(-exp(-0.5 * ((h - m) / sigma).^2) .* ((h - m) / sigma^2) * lambda), 'b', 'LineWidth', 2);
plot(h, exp(-0.5 * ((h - m) / sigma).^2) .* sin(-exp(-0.5 * ((h - m) / sigma).^2) .* ((h - m) / sigma^2) * lambda), 'r', 'LineWidth', 2);
hold off;
legend('Amplitude', 'Real Part', 'Imaginary Part');
xlabel('h'); ylabel('Membership Value');
title('Amplitude, Real, and Imaginary Parts vs. Base Variable'); grid on;


