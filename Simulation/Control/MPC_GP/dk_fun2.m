function out1 = dk_fun2(in1,in2,in3)
%DK_FUN2
%    OUT1 = DK_FUN2(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    15-May-2018 17:42:06

I2 = in2(1,:);
I3 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
t2 = I2.*4.498143168940612;
t3 = t2-x_data1;
t4 = I2.*3.746301566624442;
t5 = t4-x_data1.*8.32855119528523e-1;
t6 = I3.*1.462871941321432;
t7 = t6-x_data2;
t8 = I3.*1.464226310164034;
t9 = t8-x_data2.*1.000925828710187;
t10 = t3.*t5.*(-1.0./2.0)-t7.*t9.*(1.0./2.0);
t11 = exp(t10);
out1 = [t11.*(I2.*8.996286337881223-x_data1.*2.0).*(-1.06288416992492e-6);t11.*(I3.*2.925743882642864-x_data2.*2.0).*(-4.154238356372401e-7)];
