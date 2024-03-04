function [disparityMap_reliable,unreliable] = removeUnreliable(disparityMap)
% Remove NaN
unreliable=false(size(disparityMap));
for a=1:length(disparityMap(:,1))
  for b=1:length(disparityMap)
      if isnan(disparityMap(a,b))
         unreliable(a,b)=1;
      else
         unreliable(a,b)=0; 
      end 
  end
end
disparityMap(unreliable)=0;

% Smooth disparity map
w = 10; % half of windows size
sigma = 5; 
mask = fspecial('gaussian', 2*w+1, sigma); % Gaussian filter
disparityMap_reliable = zeros(size(disparityMap));
[M, N] = size(disparityMap);
for i = w+1:M-(w+1)
    for j = w+1:N-(w+1)
        if disparityMap(i,j)~=0
            localRegion = disparityMap(i - w:i + w, j - w:j + w);
            nonZeros = localRegion ~= 0;
            localRegion = localRegion .* mask;
            disparityMap_reliable(i, j) = sum(localRegion .* nonZeros) / sum(mask .* nonZeros);
        end
    end
end