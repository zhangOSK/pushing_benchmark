function out1 = dk_dx_fun1(in1,in2,in3)
%DK_DX_FUN1
%    OUT1 = DK_DX_FUN1(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    19-Apr-2018 11:36:54

ry1 = in1(4,:);
v1 = in2(1,:);
v2 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
x_data3 = in3(3,:);
out1 = exp((ry1.*3.840965706304202e1-x_data3).*(ry1.*3.577987925366698e1-x_data3.*9.315334212680221e-1).*(-1.0./2.0)-(v2.*5.145095506448498-x_data2.*6.22520831728876e-1).*(v2.*8.264937081959888-x_data2).*(1.0./2.0)-(v1.*1.128986101693944-x_data1.*1.751017565305308e-1).*(v1.*6.447600093018446-x_data1).*(1.0./2.0)).*(ry1.*7.681931412608403e1-x_data3.*2.0).*(-4.378090564196671e-2);
