function out1 = dk_dx_fun1(in1,in2,in3)
%DK_DX_FUN1
%    OUT1 = DK_DX_FUN1(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.1.
%    16-Apr-2018 18:24:08

ry1 = in1(4,:);
v1 = in2(1,:);
v2 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
x_data3 = in3(3,:);
out1 = exp((v2.*3.220462369253751e1-x_data2).*(v2.*1.432390008203596e1-x_data2.*4.447777505114929e-1).*(-1.0./2.0)-(v1.*1.035950944065296e1-x_data1).*(v1.*1.56437043117676e1-x_data1.*1.510081573011394).*(1.0./2.0)-(ry1.*5.025257293700998e1-x_data3).*(ry1.*3.505865122236155e1-x_data3.*6.976488799151929e-1).*(1.0./2.0)).*(ry1.*1.0050514587402e2-x_data3.*2.0).*(-2.455834570286248e-3);
