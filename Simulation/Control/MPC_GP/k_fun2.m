function out1 = k_fun2(in1,in2,in3)
%K_FUN2
%    OUT1 = K_FUN2(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    17-May-2018 15:19:03

I2 = in2(1,:);
I3 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
out1 = exp((I3.*2.547212551708451-x_data2).*(I3.*4.024044859225636-x_data2.*1.579783695917584).*(-1.0./2.0)-(I2.*4.316541159748173-x_data1).*(I2.*4.409328872107956-x_data1.*1.021495847931448).*(1.0./2.0)).*5.022819012155963e-7+8.662328543760982e-9;
