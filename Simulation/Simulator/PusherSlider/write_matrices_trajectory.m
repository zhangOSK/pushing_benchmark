%% Author: Francois Hogan
%% Date: 12/08/2016
%% Clear
clear all;
close all;
clc;
%Setup externals
% run('setup.m');

%% Simulation Parameters
t0 = 0;
tf = 5;
h_step = 0.01;

for lv1=1:1
%     vel = 0.01*lv1;
%     radius = 0.1+(lv1-1)*0.01;
    %% Build Simulation object
    pusher = LinePusher(.3);
%     pusher = PointPusher(0.3);
    object = Square();
    surface = Surface(0.35);
    planar_system = PlanarSystem(pusher, object, surface);
    % simulator = Simulator(planar_system, simulation_name);
%     planner = Planner(planar_system, [], [], [], [], '8Track', 0.08, radius); %8track
    planner = Planner(planar_system, [], [], [], [], 'Straight'); %8track

    jsonFile = struct('xc_star', planner.xc_star,...
                       'uc_star', planner.uc_star,...
                       'xs_star', planner.xs_star,...
                       'us_star', planner.us_star,...
                       't_star', planner.t_star...
                        );              

%     filename1 = '../../../Data/8Track_point_pusher_radius_';
%     filename2 = num2str(radius);
%     filename3 = '_vel_0.08_3_laps.json';% '../../../Data/8Track_point_pusher_radius_0_15_vel_0_01_3_laps.json'
%     file_name = strcat(filename1, filename2, filename3);
    file_name = '../../../Data/Straight_line_pusher_vel_0.05';
    JsonFile = savejson('Matrices', jsonFile, file_name);
end
% JsonFile = savejson('Matrices', jsonFile,  '../../../Data/Straight_point_pusher_vel_0_05.json');
% JsonFile = savejson('Matrices', jsonFile,  '../../../Data/Straight_line_pusher_vel_0_05.json');


json2data=loadjson(JsonFile);
