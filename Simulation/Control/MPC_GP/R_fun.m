function R = R_fun(in1)
%R_FUN
%    R = R_FUN(IN1)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    19-Apr-2018 11:36:57

xo3 = in1(3,:);
t2 = sin(xo3);
t3 = cos(xo3);
R = reshape([t3,t2,0.0,-t2,t3,0.0,0.0,0.0,1.0],[3,3]);
