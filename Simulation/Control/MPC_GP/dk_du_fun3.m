function out1 = dk_du_fun3(in1,in2,in3)
%DK_DU_FUN3
%    OUT1 = DK_DU_FUN3(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.1.
%    16-Apr-2018 15:05:28

ry1 = in1(4,:);
v1 = in2(1,:);
v2 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
x_data3 = in3(3,:);
t2 = ry1.*2.705829835066452e1;
t3 = t2-x_data3.*3.440360116130115e-1;
t4 = ry1.*7.86496106143127e1;
t5 = t4-x_data3;
t6 = v2.*1.996423986468464e1;
t7 = t6-x_data2.*5.834983029086983e-1;
t8 = v2.*3.421473509890997e1;
t9 = t8-x_data2;
t10 = v1.*5.542985982565435;
t11 = t10-x_data1.*3.896215634827389e-1;
t12 = v1.*1.422658934227854e1;
t13 = t12-x_data1;
t14 = t3.*t5.*(-1.0./2.0)-t7.*t9.*(1.0./2.0)-t11.*t13.*(1.0./2.0);
t15 = exp(t14);
out1 = [t15.*(v1.*2.845317868455708e1-x_data1.*2.0).*(-1.42911202782657e-1);t15.*(v2.*6.842947019781993e1-x_data2.*2.0).*(-5.14725012958279e-1)];
