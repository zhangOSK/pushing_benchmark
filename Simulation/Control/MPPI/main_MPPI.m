clear
close all
clc

%simulation parameters
x0_c = [0.1;0.0;pi*4/4;0]*1;
tspan = 10;
dt = 0.01;
N = tspan/dt;

%Define Dynamical system
% sys = Pendulum();

pusher = PointPusher();
object = Square();
surface = Surface();
planar_system = PlanarSystem(pusher, object, surface);
planner = Planner(planar_system, 'Straight', 0.05); 
sys = Simulator(planar_system, 'Straight_line_MPPI5');

x0 = planar_system.coordinateTransformCS(x0_c);

%Define controller object
MPPI = MPPI(1.5, 0.05, 1200, .1, diag([.0005,.005]), @sys.get_next_state_b, @sys.q_cost, @sys.phi_cost, @sys.u_constraints);
x = zeros(N+1, length(x0));
x(1,:) = x0';
sys.x_star = planner.xs_star;
sys.u_star = planner.us_star;
sys.t_star = planner.t_star;
sys.initialize_plot(x0, planner.xs_star(1,:)', MPPI);
t = zeros(N+1,1);

MPC_trajectories = {};

for i=1:N
    t(i)
    [x_star, u_star] = sys.find_nominal_state(t(i));
    %get action 
    u = MPPI.controller(x(i,:), t(i));
    u = sys.u_constraints(x(i,:)', u, true);
    
    %get vector of nominal states
    x_des = zeros(floor(MPPI.T/MPPI.dt), length(x(i,:)));
    t_tmp = t(i);
    for lv1=1:floor(MPPI.T/MPPI.dt)
        [x_star, u_star] = sys.find_nominal_state(t_tmp);
        x_des(lv1,:) = x_star;
        t_tmp = t_tmp + MPPI.dt;
    end
    %get next state�
    x(i+1,:) = sys.get_next_state_b(x(i,:)', u, dt);
    t(i+1) = t(i) + dt;
    
    MPC_trajectories{i} = MPPI.X;
    MPC_best{i} = MPPI.x;
    weights{i} = MPPI.w;
    des_traj{i} = x_des;
    
    
    sys.update_plot(x(i+1,:), MPPI, x_des, t(i));
end

sys.xs_state = x;
sys.t = t;

sys.Animate1pt(planner.xs_star, MPC_trajectories, MPC_best, MPPI, weights, des_traj)