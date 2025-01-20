%% LAB:08 Finding the edges
% AIM: For the color image, convert to RGB to Gray and find the edges
% using the following operators:
% 1) Use of thresholding with Sobel operator.
% 2) Canny operators.
% 3) Laplace of Gaussian (LOG) Marr-Hilderth transform.
% Compare the results with threshold gradient, LOG, and Canny operators.


clc;
clear all;
close all;
datetime

% Read and convert the image to grayscale
img = imread('cameraman.tif'); % Load the image (use appropriate image path)
gray_img = img; % Convert to grayscale if necessary

% Display original grayscale image
figure;
subplot(2,2,1);
imshow(gray_img);
title('Grayscale Image');

%% 1. Sobel Operator with thresholding logic
% Add Gaussian noise to the grayscale image for testing noise robustness
noisy_img = imnoise(gray_img, 'gaussian', 0, 0.01); % Gaussian noise with variance 0.01

% Sobel kernels
Gx = [-1 0 1; -2 0 2; -1 0 1]; % Horizontal
Gy = [-1 -2 -1; 0 0 0; 1 2 1]; % Vertical

% Apply convolution using conv2 for 2D convolution
sobel_x = conv2(double(noisy_img), Gx, 'same');
sobel_y = conv2(double(noisy_img), Gy, 'same');

% Compute gradient magnitude
sobel_magnitude = sqrt(sobel_x.^2 + sobel_y.^2);

% Apply thresholding
threshold = 150; % Adjust threshold for better results
sobel_edges = sobel_magnitude > threshold;

% Display Sobel edges
subplot(2,2,2);
imshow(sobel_edges);
title('Sobel Edge Detection with Noise');

%% 2. Canny Operator logic (without using predefined functions)
% Step 1: Gaussian filter to smooth the image
sigma = 1.0; % Standard deviation for Gaussian filter
gaussian_filter = fspecial('gaussian', [5, 5], sigma);
smoothed_img = conv2(double(gray_img), gaussian_filter, 'same');

% Step 2: Compute gradient using Sobel filters (same as above)
grad_x = conv2(smoothed_img, Gx, 'same');
grad_y = conv2(smoothed_img, Gy, 'same');

% Step 3: Compute gradient magnitude and direction
gradient_magnitude = sqrt(grad_x.^2 + grad_y.^2);
gradient_direction = atan2(grad_y, grad_x); % Gradient direction in radians

% Step 4: Non-Maximum Suppression (suppress non-edge pixels)
direction = round(gradient_direction * (180 / pi) / 45) * 45;
nms_edges = zeros(size(gradient_magnitude));
for i = 2:size(gradient_magnitude, 1) - 1
    for j = 2:size(gradient_magnitude, 2) - 1
        if direction(i, j) == 0
            if gradient_magnitude(i, j) >= gradient_magnitude(i, j-1) && gradient_magnitude(i, j) >= gradient_magnitude(i, j+1)
                nms_edges(i, j) = gradient_magnitude(i, j);
            end
        elseif direction(i, j) == 45
            if gradient_magnitude(i, j) >= gradient_magnitude(i-1, j+1) && gradient_magnitude(i, j) >= gradient_magnitude(i+1, j-1)
                nms_edges(i, j) = gradient_magnitude(i, j);
            end
        elseif direction(i, j) == 90
            if gradient_magnitude(i, j) >= gradient_magnitude(i-1, j) && gradient_magnitude(i, j) >= gradient_magnitude(i+1, j)
                nms_edges(i, j) = gradient_magnitude(i, j);
            end
        elseif direction(i, j) == 135
            if gradient_magnitude(i, j) >= gradient_magnitude(i-1, j-1) && gradient_magnitude(i, j) >= gradient_magnitude(i+1, j+1)
                nms_edges(i, j) = gradient_magnitude(i, j);
            end
        end
    end
end

% Step 5: Hysteresis Thresholding
high_thresh = 0.2 * max(max(nms_edges)); % High threshold
low_thresh = 0.1 * high_thresh;          % Low threshold
canny_edges = (nms_edges >= high_thresh);

% Display Canny edges
subplot(2,2,3);
imshow(canny_edges);
title('Canny Edge ');

%% 3. Laplacian of Gaussian (LoG) logic
% Step 1: Apply Gaussian filter for smoothing
sigma = 1.0;
gaussian_filter = fspecial('gaussian', [5, 5], sigma);
smoothed_img = conv2(double(gray_img), gaussian_filter, 'same');

% Step 2: Compute Laplacian (Second-order derivative)
laplacian_filter = [0 -1 0; -1 4 -1; 0 -1 0];
log_edges = conv2(smoothed_img, laplacian_filter, 'same');

% Step 3: Apply the 'log' edge detection with an appropriate threshold
log_edges = edge(gray_img, 'log', 0.004); % Adjusted threshold value

% Display LoG edges
subplot(2,2,4);
imshow(log_edges);
title('Laplace of Gaussian (LoG)');

%% Comparison of results
figure;
subplot(1,3,1);
imshow(sobel_edges);
title('Sobel (with Noise)');

subplot(1,3,2);
imshow(log_edges);
title('LoG (Marr-Hilderth)');

subplot(1,3,3);
imshow(canny_edges);
title('Canny Operator');
