function wallface(v, order, n, tx, wrap)

% We want to access OpenGL constants. They are defined in the global
% variable GL. GLU constants and AGL constants are also available in the
% variables GLU and AGL...
global GL


% Bind (Select) texture 'tx' for drawing:
glBindTexture(GL.TEXTURE_2D,tx);
glBegin(GL.POLYGON);

% wrap(1)=norm(v(:,order(1))-v(:,order(2)))/50;
% wrap(2)=norm(v(:,order(2))-v(:,order(3)))/50;

% Assign n as normal vector for this polygons surface normal:
glNormal3dv(n);

for iVertex=1:4
    glTexCoord2dv(wrap(iVertex, :));
    glVertex3dv(v(:,order(iVertex)));
end
% glTexCoord2dv([ 0 wrap(1) ]);
% glVertex3dv(v(:,order(2)));
%
% glTexCoord2dv([ wrap(2) wrap(1) ]);
% glVertex3dv(v(:,order(3)));
%
% glTexCoord2dv([ wrap(2) 0 ]);
% glVertex3dv(v(:,order(4)));

glEnd;
