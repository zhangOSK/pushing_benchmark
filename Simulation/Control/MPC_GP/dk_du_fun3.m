function out1 = dk_du_fun3(in1,in2,in3)
%DK_DU_FUN3
%    OUT1 = DK_DU_FUN3(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    11-Apr-2018 15:51:05

ry1 = in1(4,:);
u1 = in2(1,:);
u2 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
x_data3 = in3(3,:);
t2 = ry1.*2.705829835066452e1;
t3 = t2-x_data3.*3.440360116130115e-1;
t4 = conj(ry1);
t5 = t4.*7.86496106143127e1;
t6 = conj(x_data3);
t7 = t5-t6;
t8 = u2.*1.996423986468464e1;
t9 = t8-x_data2.*5.834983029086983e-1;
t10 = conj(u2);
t11 = t10.*3.421473509890997e1;
t12 = conj(x_data2);
t13 = t11-t12;
t14 = u1.*5.542985982565435;
t15 = t14-x_data1.*3.896215634827389e-1;
t16 = conj(u1);
t17 = t16.*1.422658934227854e1;
t18 = conj(x_data1);
t19 = t17-t18;
t20 = t3.*t7.*(-1.0./2.0)-t9.*t13.*(1.0./2.0)-t15.*t19.*(1.0./2.0);
t21 = exp(t20);
out1 = [t21.*(u1.*1.422658934227854e1-x_data1).*(-2.009071877234186e-2);t21.*(u2.*3.421473509890997e1-x_data2).*(-3.008791454735988e-2)];