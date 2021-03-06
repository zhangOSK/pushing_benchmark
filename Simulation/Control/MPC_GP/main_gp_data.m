%% Author: Francois Hogan
%% Date: 07/03/2018
%--------------------------------------------------------
% Description:
% This script simulaLtes the motion of a square object subject to robot
% velocites. The simulation total time (line 18), object and robot initial
% configurations (line 24), and robot applied velocities (line 40)
%--------------------------------------------------------
clear
clc
close all

run(strcat(getenv('HOME'),'/pushing_benchmark/Simulation/Simulator/setup.m'));

gp_model_name = 'trained_new_inputs_outputs_validation_side_0_only_5000';
Linear = symbolic_linearize_data(gp_model_name);

%% Simulation data and video are stored in /home/Data/<simulation_name>
simulation_name = 'gp_data_2_on_analytical';
%% Simulation time
sim_time = 40;

%% Initial conditions 
% x0 = [x;y;theta;xp;yp]
% x: x position of object, y: y position of object, theta: orientation of object
% xp: x position of pusher, yp: y position of pusher
% x0_c = [-.198674;0;0;-.00];
x0_c = [-0.0;0.00;5*pi/180;-.009];
%%Initiaze system
is_gp=true;
initialize_system();
% load('learning_output_model_from_train_size_4000');
load(gp_model_name);
simulator.data = data;
des_velocity=0.05;
des_radius=0.05;
des_dist=0.15;
num_laps=1;
planner = Planner(planar_system, simulator, Linear, data, object, 'SquareCurved_gp', des_velocity, des_radius,num_laps,des_dist); %8track

% planner = Planner(planar_system, simulator, Linear, data, object, 'Square_gp', 0.05, 0.15, 1); %8track
planner.ps.num_ucStates = 2;
%Controller setup
Q = 10*diag([1,1,.01,5]);
Qf=  1*1000*diag([1,1,.1,5]);
R = .1*diag([1,1]);
mpc = MPC(planner, Q, Qf, R, Linear, data, object);
%send planned trajectory to simulator for plotting
simulator.x_star = planner.xs_star;
simulator.u_star = planner.us_star;
simulator.t_star = planner.t_star;

[xs_d,us_d] = simulator.find_nominal_state(0);
simulator.initialize_plot(x0, xs_d, sim_time);
%% Perform Simulation
for i1=1:simulator.N
        %display current time 
        disp(simulator.t(i1));
        
        %Define loop variables
        xs = simulator.xs_state(i1,:)';
        
        %apply lqr controller
        xc = planar_system.coordinateTransformSC(xs);
        uc = mpc.solveMPC(xc, simulator.t(i1));
%          uc
        us = mpc.get_robot_vel(xc, uc);
% us = [.05;0];
        %simulate forward
        %1. analytical model
%         xs_next = simulator.get_next_state_i(xs, us, simulator.h);
        %2. gp model
        xs_next = simulator.get_next_state_gpData_i(xs, us, simulator.h);
        %update plot
        simulator.update_plot(xs_next, simulator.t(i1));
%       %Perform Euler Integration
        if i1<simulator.N
            simulator.t(i1+1)  = simulator.t(i1) + simulator.h;
            simulator.xs_state(i1+1, :) = xs_next;%simulator.xs_state(i1, :) + simulator.h*dxs';       
        end
        %Save data 
        simulator.us_state(i1,:) = us;
%          pause(.1);
end

%% Graphics
% simulator.Animate1pt(simulator.x_star)
close(simulator.v);
%% Post-Processing
save(simulator.FileName, 'simulator');