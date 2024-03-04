function [BG1,BG2,BG3] = extractBG(I1,I2,I3,canny_params,strel_params)
%REMOVEBG 此处显示有关此函数的摘要
%   此处显示详细说明
IMG = {I1, I2, I3};
BG_IMG = cell(1, 3);
BG = cell(1, 3);

% 循环处理每张图片
for i = 1:3
    % 使用Canny边缘检测
    img = IMG{i};
    edges = edge(rgb2gray(img), 'canny', canny_params{i});
    % figure;
    % imshow(edges)

    % 形态学操作: 腐蚀和膨胀
    se = strel(strel_params{i}{1}, strel_params{i}{2});
    edges_dilated = imdilate(edges, se);
    edges_filled = imfill(edges_dilated, 'holes');
    edges_eroded = imerode(edges_filled, se);
    % figure;
    % imshow(edges_eroded);

    % 创建掩膜
    mask = edges_eroded;
    BG{i} = mask;

    % 应用掩膜
    for ch = 1:3
        img(:,:,ch) = img(:,:,ch) .* uint8(mask);
    end
    BG_IMG{i} = img;
    % [J1, J2, J3] = deal(BG_IMG{:});

    % 显示结果
    % figure;
    % imshow(BG_IMG{i});
end
% [J1, J2, J3] = deal(BG_IMG{:});
[BG1,BG2,BG3] = deal(BG{:});
end

