function out1 = dk_dv_fun3(in1,in2,in3)
%DK_DV_FUN3
%    OUT1 = DK_DV_FUN3(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    15-Jun-2018 13:32:40

I2 = in2(1,:);
I3 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
out1 = exp((I2.*8.728485847928009-x_data1).*(I2.*8.828282922617175-x_data1.*1.011433492180417).*(-1.0./2.0)-(I3.*1.654205704624664-x_data2.*1.006422907272001).*(I3.*1.643648701427649-x_data2).*(1.0./2.0)).*(I2.*1.745697169585602e1-x_data1.*2.0).*(-2.168143391337487e-3);
