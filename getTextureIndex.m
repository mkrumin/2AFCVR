function index = getTextureIndex(str, textures)

for ind=1:length(textures)
    if isequal(textures(ind).name, str)
        index=ind;
        return;
    end
end

index=1; % no texture found with the correct name, pushing GRAY instead
% 
% switch str
%     case 'GRAY'
%         index = 1;
%     case 'WHITENOISE'
%         index = 2;
%     case 'COSGRATING'
%         index = 3;
%     case 'COS10x'
%         index = 4;
%     case 'COS50LARGE'
%         index = 5;
%     case 'SINx1'
%         index=6;
%     case 'SINx2'
%         index=7;
%     case 'SINx3'
%         index=8;
%     case 'SINx4'
%         index=9;
%     otherwise
%         index = 2;
% end