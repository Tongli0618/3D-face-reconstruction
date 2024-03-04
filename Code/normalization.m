function [J1,J2,J3] = normalization(I1,I2,I3)
% Calculate mean and standard deviation
mean1 = mean(I1(:));
std1 = std(double(I1(:)));

mean2 = mean(I2(:));
std2 = std(double(I2(:)));

mean3 = mean(I3(:));
std3 = std(double(I3(:)));

% Select Middle as the reference image
referenceMean = mean2;
referenceStd = std2;

% Calculate the normalized image
J1 = (referenceStd / std1) * (double(I1) - mean1) + referenceMean;
J2 = (referenceStd / std2) * (double(I2) - mean2) + referenceMean;
J3 = (referenceStd / std3) * (double(I3) - mean3) + referenceMean;

J1 = uint8(J1);
J2 = uint8(J2);
J3 = uint8(J3);
end

