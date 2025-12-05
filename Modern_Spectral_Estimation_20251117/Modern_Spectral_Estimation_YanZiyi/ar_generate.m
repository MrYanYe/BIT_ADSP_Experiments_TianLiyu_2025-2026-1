function x = ar_generate(N,p,ar_coeffs,sigma)
    w0 = 5*randn(1,p);
    s = 2*N;
    x = zeros(1,N+p);
    x(1:p) = w0;
    for k = p+1:N+p+s
        x(k) = ar_coeffs * flip((x(k-p:k-1)))'+ sigma * randn(1,1);
    end
    x = x(end-N+1:end);
end