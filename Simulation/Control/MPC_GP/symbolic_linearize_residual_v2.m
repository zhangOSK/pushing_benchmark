function [Linear] = symbolic_linearize_residual_v2(filename)

    pusher_gp = PointPusher(.3);
    object_gp = Square();
    surface_gp = Surface(.35);
    planar_system_gp = PlanarSystem(pusher_gp, object_gp, surface_gp);
    load(filename);

    % load('trained_new_inputs_outputs_validation_side_0_only_5000.mat');
    %build variables
    xo = sym('xo', [3,1]);
    rx = -object_gp.b/2;
    ry = sym('ry', [1,1]);
    x = [xo;ry];
    v = sym('v', [2,1]);
    u = sym('u', [3,1]);
    I = sym('I', [3,1]);
    x_data = sym('x_data', [2,1]);
    gp_input = [I(2);I(3)];
    theta = sym('theta', [4,1]);

    %Build symbolic functions
    for lv1=1:3
        %build symbolic derivatives of kernel
        [k_sym{lv1} dk_sym{lv1}] = covFunc_data(data.theta1{lv1}, x_data, gp_input./exp(data.lengthscales{lv1}(:)), exp(data.lengthscales{lv1}(:)));
    %     [k_sym{lv1} dk_sym{lv1}] = covFunc(theta, x_data, gp_input);
        dk_dc_sym{lv1} = dk_sym{lv1}(1,:);
        dk_dphi_sym{lv1} = dk_sym{lv1}(2,:);

    %     dk_dx_sym_test{lv1} = jacobian(k_sym{lv1}, x);
    %     dk_dv_sym_test{lv1} = jacobian(k_sym{lv1}, v);
        %convert to matlab function
        Linear.k_fun{lv1}=matlabFunction(k_sym{lv1}, 'Vars', {x,gp_input,x_data}, 'File',strcat('k_fun', num2str(lv1)));
        Linear.dk_fun{lv1}=matlabFunction(dk_sym{lv1}, 'Vars', {x,gp_input,x_data}, 'File',strcat('dk_fun', num2str(lv1)));
        Linear.dk_dphi_fun{lv1}=matlabFunction(dk_dphi_sym{lv1}, 'Vars', {x,gp_input,x_data}, 'File', strcat('dk_dx_fun', num2str(lv1)));
        Linear.dk_dc_fun{lv1}=matlabFunction(dk_dc_sym{lv1}, 'Vars', {x,gp_input,x_data}, 'File', strcat('dk_dv_fun', num2str(lv1)));
    %     Linear.dk_dx_fun_test{lv1}=matlabFunction(dk_dx_sym_test{lv1}, 'Vars', {x,v,x_data}, 'File', strcat('dk_dx_fun_test', num2str(lv1)));
    %     Linear.dk_dv_fun_test{lv1}=matlabFunction(dk_dv_sym_test{lv1}, 'Vars', {x,v,x_data}, 'File', strcat('dk_dv_fun_test', num2str(lv1)));
    end

    %rotational kinematics
    Cbi = Helper.C3_2d(x(3));
    Rib = [transpose(Cbi) [0; 0];0 0 1];
    Rib_fun = matlabFunction(Rib,  'Vars', {x});
    dR_dtheta = diff(Rib, x(3));
    Linear.dRib_dtheta_fun = matlabFunction(dR_dtheta,  'Vars', {x});
    %diff dxb relative to I
    Ccb = Helper.C3_2d(I(3));
    Rbc = [transpose(Ccb) [0; 0];0 0 1];
    Rbc=transpose(Rbc);%temporary hack as delta_y is not defined properly
    dRbc_dphi = diff(Rbc, I(3));
    Linear.Rbc_fun = matlabFunction(Rbc,  'Vars', {gp_input});
    Linear.dRbc_dphi_fun = matlabFunction(dRbc_dphi,  'Vars', {gp_input});
    %convert I to v
    h = [sqrt(v(1)^2+v(2)^2); 1/2-ry/object_gp.a; atan(v(2)/v(1))];
    dI_dv = jacobian(h,v);
    dI_dx = jacobian(h,x);
    Linear.dI_dv_fun = matlabFunction(dI_dv,'Vars', {v});
    Linear.dI_dx = dI_dx;
    %convert v to u
    v_var = planar_system_gp.Gc_fun(x)*u;
    dv_dx = jacobian(v_var, x);
    dv_du = jacobian(v_var, u);
    Linear.dv_dx_fun = matlabFunction(dv_dx,'Vars', {x,u});
    Linear.dv_du_fun = matlabFunction(dv_du,'Vars', {x});
    Linear.Gc_fun = planar_system_gp.Gc_fun;
end
%     return
%     [A,B] = GP_linearization_residual([0;0;0;0.009], [.32;0;0], Linear, data, object_gp);
    % % return
    % 
    %     rx = -object_gp.a/2;
    %     %Build A and B matrices
    %     x_star = [0;0;0;0];
    %     u_star = [.327;0;0];
    %     v_star = [.05;0];%Linear.Gc_fun(x_star)*u_star;
    %     
    %     V_nom = .2*.02;
    %     V_star = 0.05;
    %     phi_star = 0;
    %     c_star = .5;
    %     I_star = [V_star, c_star, phi_star];
    %     gp_input_star = [c_star; phi_star];
    % 
    %     %build large derivative matrices and gp function output
    %     N = length(data.X{1});
    %     D = 4;
    %     g = [];
    %     dg_dx = [];
    %     dg_dv = [];
    %     dg_dI=[];
    %     dg_dphi=[];
    %     dg_dc=[];
    %     for lv1=1:3
    %         %initialize
    %         dK_dx{lv1} = zeros(N,4);
    %         dK_dv{lv1} = zeros(N,2);
    %         k_star{lv1} = zeros(N,1);
    %         K1_star_sym{lv1}=[];
    %         dK1_dx_star_sym{lv1}=[];
    %         dK1_dv_star_sym{lv1}=[];
    %         tic
    % 
    %         k_star{lv1}=Linear.k_fun{lv1}(x_star,gp_input_star,data.X{lv1}');
    %         dK_dc{lv1}=Linear.dk_dc_fun{lv1}(x_star,gp_input_star,data.X{lv1}');
    %         dK_dphi{lv1}=Linear.dk_dphi_fun{lv1}(x_star,gp_input_star,data.X{lv1}');
    %         
    % %         dK_dx{lv1}=[zeros(3,length(dK_ry{lv1}));dK_ry{lv1}];
    % %         dK_dv{lv1}=Linear.dk_dv_fun{lv1}(x_star,v_star,data.X{lv1}');
    %     %     for n=1:N
    %     %         n;
    %     %         %build k_star column matrix with equilibrium data 
    %     %         k_star{lv1}(n) = Linear.k_fun{lv1}(x_star,v_star,data.X{lv1}(n,:)');
    %     %         %concat kernel derivatives and sub in equilibrium numbers
    %     %         dK_dx{lv1}(n,:) = Linear.dk_dx_fun{lv1}(x_star,v_star,data.X{lv1}(n,:)');
    %     %         dK_dv{lv1}(n,:) = Linear.dk_du_fun{lv1}(x_star,v_star,data.X{lv1}(n,:)');
    %     %     end
    %     %     [~, K1star] = feval(data.covfunc1{lv1}{:}, data.theta1{lv1}, data.X{lv1}, [1 2 3]./exp(data.lengthscales{lv1}(:)'));
    %     %     twist_b = [twist_b;K1star'*obj.data.alpha{lv1}];
    %         %concat gp output into a numerical column vector
    %         g = [g;k_star{lv1}*data.alpha{lv1}];
    %         dg_dphi_tmp = dK_dphi{lv1}*data.alpha{lv1};
    %         dg_dc_tmp = dK_dc{lv1}*data.alpha{lv1};
    %         dg_dphi = [dg_dphi;dg_dphi_tmp];
    %         dg_dc = [dg_dc;dg_dc_tmp];
    %         dg_dI = [dg_dI;0 dg_dc_tmp dg_dphi_tmp];
    % 
    %         %concat gp derivatives together
    % %         dg_dx_tmp = dg_dI
    % %         dg_dx = [dg_dx;transpose(dK_dx{lv1}*data.alpha{lv1})];
    % %         dg_dv = [dg_dv;transpose(dK_dv{lv1}*data.alpha{lv1})];
    % 
    %     end
    %     
    % %     dg_dx = double(dg_dI*Linear.dI_dx);
    % %     dg_dv = double(dg_dI*Linear.dI_dv_fun(v_star));
    % 
    %     %compute partial derivatives
    %     dxb_dV = (1/V_nom)*Linear.Rbc_fun(x_star)*g;
    %     dxb_dphi = (V_star/V_nom)*(Linear.dRbc_dphi_fun(x_star)*g+Linear.Rbc_fun(x_star)*dg_dphi);
    %     dxb_dc = (V_star/V_nom)*(Linear.Rbc_fun(x_star)*dg_dc);
    %     dxb_dI = [dxb_dV dxb_dc dxb_dphi];
    %     
    %     dg_dv = double(dxb_dI*Linear.dI_dv_fun(v_star)*Linear.Gc_fun(x_star));
    %     dg_dx = double(dxb_dI*Linear.dI_dx + dxb_dI*Linear.dI_dv_fun(v_star)*Linear.dv_dx_fun(x_star, u_star));
    %     g = (V_star/V_nom)*g;
    % 
    %     %build expression for dry=dx(4) (note: dry = vt-)
    % 
    %     %% Need to account for missing expression
    % %     vbpi=v_star;
    %     % vbbi=g();
    %     % dry_dx = 0 - 0 - 0;
    %     % dry_dv = 1 - dgp2_u - diff(gp(3)xrbpb. u);
    %     % dg_gx2 = [dK1_dx_star_Fun{1}(x_star, v_star)'*data.alpha{1}, dK1_dx_star_Fun{2}(x_star, v_star)'*data.alpha{2}, dK1_dx_star_Fun{3}(x_star, v_star)'*data.alpha{3}]';
    %     dry_dx = [0, 0, 0, -dg_dx(2,4)-rx*dg_dx(3,4)];
    %     dry_dv = [0-dg_dv(2,1)-rx*dg_dv(3,1), 1-dg_dv(2,2)-rx*dg_dv(3,2)];
    % 
    %     dR_dx = [zeros(size(Linear.dRib_dtheta_fun(x_star)))*g zeros(size(Linear.dRib_dtheta_fun(x_star)))*g Linear.dRib_dtheta_fun(x_star)*g zeros(size(Linear.dRib_dtheta_fun(x_star)))*0*g];
    % 
    %     A1 = [dR_dx + R_fun(x_star)*(dg_dx); dry_dx*0];
    %     B1 = [R_fun(x_star)*dg_dv; zeros(1,3)];
% 
%     return
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % V_new =I(1);%
%     % c_new = I(2);
%     % phi_new = I(3);%
%     % 
%     % V_new =sqrt(v(1)^2+v(2)^2);%sqrt(v(1)^2+v(2)^2);%I(1);%
%     % c_new = 1/2-ry/object_gp.a;
%     % phi_new = atan(v(2)/v(1));;%atan(v(2)/v(1));%I(3);%
%     V_nom = .2*.02;
%     V_new =sqrt(v_var(1)^2+v_var(2)^2);%sqrt(v(1)^2+v(2)^2);%I(1);%
%     c_new = 1/2-ry/object_gp.a;
%     phi_new = atan(v_var(2)/v_var(1));;%atan(v(2)/v(1));%I(3);%
% 
%     gp_input_new = [c_new;phi_new];%gp_input;%
% 
%     Ccb = Helper.C3_2d(phi_new);
%     Cbi = Helper.C3_2d(x(3));
%     Rbc = [(Ccb) [0; 0];0 0 1];
%     Rib = [transpose(Cbi) [0; 0];0 0 1];
%     fc = twist_b_gp_residual(gp_input_new)*(V_new/V_nom);
%     fb = Rbc*fc;
%     fi = Rib*fb;
% 
%     % dfc_dI = jacobian(fc, v);
%     % dfc_dI_fun = matlabFunction(dfc_dI, 'Vars', {x,v});
%     fc_fun = matlabFunction(fc, 'Vars', {x,u});
%     fb_fun = matlabFunction(fb, 'Vars', {x,u});
%     fi_fun = matlabFunction(fi, 'Vars', {x,u});
%     dfc_dI = jacobian(fc, I);
%     dfb_dx = jacobian(fb, x);
%     dfb_dI = jacobian(fb, I);
%     dfb_du = jacobian(fb, u);
%     dfb_dx_fun = matlabFunction(dfb_dx, 'Vars', {x,u});
%     dfb_du_fun = matlabFunction(dfb_du, 'Vars', {x,u});
%     dfi_dx = jacobian(fi, x);
%     dfi_du = jacobian(fi, u);
%     dfi_dx_fun = matlabFunction(dfi_dx, 'Vars', {x,u});
%     dfi_du_fun = matlabFunction(dfi_du, 'Vars', {x,u});
%     f_non = [fi;0];
%     A_fun = jacobian(f_non, x);
%     B_fun = jacobian(f_non, u);
%     f_non_fun = matlabFunction(f_non, 'Vars', {x,u});
%     A_fun = matlabFunction(A_fun, 'Vars', {x,u});
%     B_fun = matlabFunction(B_fun, 'Vars', {x,u});
%     A3 = A_fun(x_star, u_star);
%     B3 = B_fun(x_star, u_star);

    % % dfc_dI = jacobian(fc, v);
    % % dfc_dI_fun = matlabFunction(dfc_dI, 'Vars', {x,v});
    % fc_fun = matlabFunction(fc, 'Vars', {x,v});
    % fb_fun = matlabFunction(fb, 'Vars', {x,v});
    % fi_fun = matlabFunction(fi, 'Vars', {x,v});
    % dfc_dI = jacobian(fc, I);
    % dfb_dx = jacobian(fb, x);
    % dfb_dI = jacobian(fb, I);
    % dfb_dv = jacobian(fb, v);
    % dfb_dx_fun = matlabFunction(dfb_dx, 'Vars', {x,v});
    % dfb_dv_fun = matlabFunction(dfb_dv, 'Vars', {x,v});
    % dfi_dx = jacobian(fi, x);
    % dfi_dv = jacobian(fi, v);
    % dfi_dx_fun = matlabFunction(dfi_dx, 'Vars', {x,v});
    % dfi_dv_fun = matlabFunction(dfi_dv, 'Vars', {x,v});
    % vbpi_test = v;
    % vbbi_test = fb(1:2);
    % vbpb_test = vbpi_test-vbbi_test-Helper.cross3d(fi(3), [rx;ry]);
    % dry_test = vbpb_test(2);
    % dry_dx_test = jacobian(dry_test,x);
    % dry_dv_test = jacobian(dry_test,v);
    % dry_dx_fun_test = matlabFunction(dry_dx_test, 'Vars', {x,v});
    % dry_dv_fun_test = matlabFunction(dry_dv_test, 'Vars', {x,v});
    % f_non = [fi;dry_test];
    % A_fun = jacobian(f_non, x);
    % B_fun = jacobian(f_non, v);
    % f_non_fun = matlabFunction(f_non, 'Vars', {x,v});
    % A_fun = matlabFunction(A_fun, 'Vars', {x,v});
    % B_fun = matlabFunction(B_fun, 'Vars', {x,v});
    % A3 = A_fun(x_star, v_star);
    % B3 = B_fun(x_star, v_star);