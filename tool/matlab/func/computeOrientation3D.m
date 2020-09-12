function [orientation_2D, orientation_3D] = computeOrientation3D(object,P)
% takes an object and a projection matrix (P) and projects the 3D
% object orientation vector into the image plane.

% compute rotational matrix around yaw axis
R = [+cos(object.ry), -sin(object.ry), 0;
     +sin(object.ry), +cos(object.ry), 0;
     0              ,               0, 1];

arrow_angle = pi/6;
arrow_length = 0.2;

% orientation in object coordinate system
orientation_3D = [0.0, object.l, object.l - object.l * arrow_length * cos(arrow_angle), object.l - object.l * arrow_length * cos(arrow_angle)
                  0.0, 0.0, 0.0, 0.0
                  0.0, 0.0, object.l * arrow_length * sin(arrow_angle), -object.l * arrow_length * sin(arrow_angle)];

% rotate and translate in camera coordinate system, project in image
orientation_3D      = R*orientation_3D;
orientation_3D(1,:) = orientation_3D(1,:) + object.t(1);
orientation_3D(2,:) = orientation_3D(2,:) + object.t(2);
orientation_3D(3,:) = orientation_3D(3,:) + object.t(3);

% vector behind image plane?
if any(orientation_3D(2,:)<0.1)
  orientation_2D = [];
  return;
end

% project orientation into the image plane
orientation_2D = projectToImage(orientation_3D,P);
