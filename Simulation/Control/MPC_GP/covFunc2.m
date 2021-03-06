function k = covFunc2(theta, xp, xq)
    ell1 = exp(theta(1));
    ell2 = exp(theta(2));
    ell3 = exp(theta(3));
    sf2 = exp(2*theta(4));
    s2 = exp(2*theta(5));
    
    P = diag([ell1^2,ell2^2,ell3^2]);
    
    delta_x = xp-xq;
    k = sf2*exp((-transpose(delta_x)*inv(P)*delta_x)/2) + 1/s2;
end