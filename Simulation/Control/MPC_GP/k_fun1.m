function out1 = k_fun1(in1,in2,in3)
%K_FUN1
%    OUT1 = K_FUN1(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 7.1.
%    06-Jun-2018 07:48:27

I2 = in2(1,:);
I3 = in2(2,:);
x_data1 = in3(1,:);
x_data2 = in3(2,:);
out1 = exp((I3.*1.286970097009704-x_data2.*8.594556907312019e-1).*(I3.*1.49742460360555-x_data2).*(-1.0./2.0)-(I2.*1.776040042837371e1-x_data1).*(I2.*1.325228930247021e1-x_data1.*7.461706370819535e-1).*(1.0./2.0)).*1.108415662102631e-6+1.35191819153981e-6;
