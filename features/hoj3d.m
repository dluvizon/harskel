function hist = hoj3d(skel)
%        File: lvz_hoj3d.m
%       Usage: hist = lvz_hoj3d(skel)
% Description: Given a skeleton (skel), compute its HOJ3D descriptor.
%      Author: Diogo Luvizon <diogo.luvizon@ensea.fr>
hist = [];
% Enforce to skel to be [3 x N], where N is the number of joints
skel = skel(1:3,:);
%% Get coordinate system from the body
center_hip = skel(:,1);
right_hip = skel(:,13);
left_hip = skel(:,17);
%% Check if the pivot hips are non zero (bad skeleton).
if sum(center_hip == 0) || sum(right_hip == 0) || sum(left_hip == 0)
    return
end
vet_alpha = right_hip - left_hip;
% Project the alpha vetor to the center hip plane (Y=0),
% i.e. to a plane parallel to X-Z plane.
vet_alpha(2) = 0;
if ~norm(vet_alpha)
    % That means the projected alpha vector is null... bad luck
    return
end
vet_alpha = vet_alpha / norm(vet_alpha);
vet_theta = [0; 1; 0];
%% Compute the orientation-independet hips
% Remap from skeleton the following parts:
% head, right elbow, left elbow, right hand, left hand,
% right knee, left knee, right feet, left feet
hips_remap = [4 6 10 8 12 14 18 16 20];
%% Compute the histogram
for i = 1:9
    rmp = hips_remap(i);
    if sum(skel(:,rmp) == 0)
        % If this skeleton joint is null, ignore it.
        continue
    else
        if isempty(hist)
            hist = zeros(7,12);
        end
    end
    vet_hips = skel(:,rmp) - center_hip;
    theta = vet_angle(vet_theta, vet_hips);
    alpha = get_alpha_ang(vet_alpha, vet_hips);
    hist = hoj3d_update_histogram(hist, theta, alpha);
end
hist = hist(:);
%% Auxiliary function lvz_get_alpha_ang
function ang = get_alpha_ang(ref, v)
    % This vector should be projected in the X-Z plane (Y=0).
    v(2) = 0;
    ang = vet_angle(ref, v);
    crs = cross(ref, v);
    if crs(2) < 0.0
        ang = 360 - ang;
    end
end
%% Auxiliary function vet_angle
function ang = vet_angle(a, b)
    cos_theta = dot(a,b) / (norm(a) * norm(b));
    ang = acos(cos_theta) * 180 / pi;
end
%% Auxiliary function hoj3d_update_histogram
% Description: Given a histogram and the angles theta and alpha, updates
%              the histogram with gaussian distribution around the given
%              point (theta, alpha).
function hist = hoj3d_update_histogram(hist, theta, alpha)
    ut = ((theta + 15) / 30) + 0.5;
    ua = (alpha / 30) + 0.5;
    t2 = int32(ut);
    t1 = t2 - 1;
    t3 = t2 + 1;
    a2 = int32(ua);
    a1 = a2 - 1;
    a3 = a2 + 1;
    T = [gaussmf(t1,ut); gaussmf(t2,ut); gaussmf(t3,ut)];
    A = [gaussmf(a1,ua)  gaussmf(a2,ua)  gaussmf(a3,ua)];
    M = T * A;
    % Take care about borders here
    if a1 < 1
        a1 = 12;
    end
    if a3 > 12;
        a3 = 1;
    end
    if t1 < 1
        t1 = 1;
    end
    if t3 > 7
        t3 = 7;
    end
    % Update histogram
    hist(t2,a1) = hist(t2,a1) + M(2,1);
    hist(t2,a2) = hist(t2,a2) + M(2,2);
    hist(t2,a3) = hist(t2,a3) + M(2,3);
    hist(t1,a1) = hist(t1,a1) + M(1,1);
    hist(t1,a2) = hist(t1,a2) + M(1,2);
    hist(t1,a3) = hist(t1,a3) + M(1,3);
    hist(t3,a1) = hist(t3,a1) + M(3,1);
    hist(t3,a2) = hist(t3,a2) + M(3,2);
    hist(t3,a3) = hist(t3,a3) + M(3,3);
end
%% Auxiliary function gaussmf
function y = gaussmf(x, u)
    % Fixed alpha, change this if needed.
    a = 0.5;
    % Enforce double vars
    x = double(x);
    u = double(u);
    a = double(a);
    % Gaussian equation
    y = (1 / (a * sqrt(2 * pi))) * exp(-(x - u)^2 / (2 * a^2));
end
end