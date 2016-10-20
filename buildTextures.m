function [textures tx]=buildTextures(options)

iTexture=0;
rand('seed', 0);

%% GRAY
iTexture=iTexture+1;
textures(iTexture).name='GRAY';
tx.('GRAY')=iTexture;
textures(iTexture).matrix=zeros(options.size)+0.5;

%% Strong white noise (used for the floor) 
iTexture=iTexture+1;
textures(iTexture).name='WNSTRONG';
tx.('WNSTRONG')=iTexture;
textures(iTexture).matrix=(rand(options.size)-0.5)*options.floorContrast/100+0.5;

%% Weak white noise - not-a-stimulus for the walls
iTexture=iTexture+1;
textures(iTexture).name='WNWEAK';
tx.('WNWEAK')=iTexture;
nLevels=63;
noisetmp=round((rand(options.size)-0.5)*nLevels)/(nLevels-1);
textures(iTexture).matrix=noisetmp*options.noiseContrast/100+0.5;
noise=textures(iTexture).matrix;

%% gratings
% old version - large matrices
% noise=repmat(noise, options.sfMultiplier, 1);
% noise=reshape(noise, options.size, options.sfMultiplier*options.size);
% % prenoise=noise;
% gf=fspecial('gaussian', [1, options.sfMultiplier], 1);%options.sfMultiplier);
% % noise=filter2(gf, noise, 'same');
% noise=imfilter(noise, gf, 'circular');
% t=(0:options.size*options.sfMultiplier-1)/options.size;
% % t=(0:options.size-1)*options.sfMultiplier/options.size;
% grating=repmat(sin(2*pi*t)/2+0.5, options.size, 1);
% for iGrat=1:length(options.gratingContrasts)
%     iTexture=iTexture+1;
%     textures(iTexture).name=['COSGRATING', num2str(iGrat)];
%     tx.(['COSGRATING', num2str(iGrat)])=iTexture;
%     textures(iTexture).matrix=(grating-0.5)*options.gratingContrasts(iGrat)/100+noise;
% end

% newer version - keep matrices the same size (lose some resolution for the
% gratings)
t=(0:options.size-1)*options.sfMultiplier/options.size;
grating=repmat(sin(2*pi*t)/2+0.5, options.size, 1);
for iGrat=1:length(options.gratingContrasts)
    iTexture=iTexture+1;
    textures(iTexture).name=['COSGRATING', num2str(iGrat)];
    tx.(['COSGRATING', num2str(iGrat)])=iTexture;
    textures(iTexture).matrix=(grating-0.5)*options.gratingContrasts(iGrat)/100+noise;
end

% plotting the textures for debugging

% for i=1:iTexture
%     subplot(3, 4, i)
%     imshow(textures(i).matrix, [0 1]);
%     title(textures(i).name);
% end