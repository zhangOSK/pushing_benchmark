function out1 = dk_dx_fun3(in1,in2,in3)
%DK_DX_FUN3
%    OUT1 = DK_DX_FUN3(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    11-Apr-2018 15:51:05

ry1 = in1(4,:);
u1 = in2(1,:);
u2 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
x_data3 = in3(3,:);
out1 = exp((ry1.*2.705829835066452e1-x_data3.*3.440360116130115e-1).*(conj(ry1).*7.86496106143127e1-conj(x_data3)).*(-1.0./2.0)-(u2.*1.996423986468464e1-x_data2.*5.834983029086983e-1).*(conj(u2).*3.421473509890997e1-conj(x_data2)).*(1.0./2.0)-(u1.*5.542985982565435-x_data1.*3.896215634827389e-1).*(conj(u1).*1.422658934227854e1-conj(x_data1)).*(1.0./2.0)).*(ry1.*7.86496106143127e1-x_data3).*(-1.774011349651947e-2);