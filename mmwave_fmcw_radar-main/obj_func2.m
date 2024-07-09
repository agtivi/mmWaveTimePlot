function [f] = obj_func2(x)
    centers = x;
    load('b.mat');
    fftsize = length(b);
    w = 2*pi*[0:fftsize-1].'/fftsize;
    windowsize = 512;
    A = exp(-1j.*(w-centers).*(windowsize-1)/2).*diric((w-centers), windowsize);
%     A = A .* [1 0.3];
    f = norm(b-A*pinv(A)*b)^2;
    
%     SD = zeros(N*(64), length(psis));
%     load('calibrated_H.mat');
% %     load('H.mat'); calibrated_H = H;
%     H = reshape(calibrated_H.', [64*4, 1]);
% %     H = [4.8840 + 6.5076i,  4.9248 + 6.3912i,  5.3002 + 6.5595i,  5.2194 + 6.4344i,  7.2518 + 3.2453i,  7.1481 + 2.9379i,  7.4338 + 3.3678i,  7.3815 + 3.3133i,  8.0236 + 0.0270i,  7.9145 - 0.2102i,  8.4115 - 0.0436i,  7.9375 + 0.0343i,  7.2729 - 3.2829i,  6.8461 - 3.7299i,  7.3622 - 3.5069i,  7.2902 - 3.4996i,  5.2727 - 5.7289i,  4.8659 - 5.8588i,  5.5700 - 6.2732i,  5.4270 - 5.9915i,  2.3902 - 7.2658i,  2.2953 - 7.5951i,  2.6760 - 7.6632i,  2.5663 - 7.4824i, -0.5676 - 7.4907i, -0.6141 - 7.5911i, -0.5433 - 7.9789i, -0.6402 - 7.7944i, -3.8061 - 6.4516i, -3.8697 - 6.4835i, -3.6232 - 7.1008i, -3.6273 - 6.8510i, -5.8119 - 4.7789i, -6.0687 - 4.4649i, -6.2418 - 4.8177i, -6.1114 - 4.6972i, -7.2459 - 2.0520i, -7.0873 - 1.5400i, -7.6327 - 1.9706i, -7.4254 - 1.8936i, -7.2294 + 1.2752i, -7.1656 + 1.6196i, -7.6816 + 1.4216i, -7.5001 + 1.3850i, -6.3259 + 3.8680i, -6.1327 + 4.3775i, -6.7262 + 4.1678i, -6.3397 + 4.3067i, -4.0459 + 5.9259i, -3.7944 + 6.2802i, -4.2932 + 6.3775i, -4.3031 + 6.2898i, -1.2379 + 6.8747i, -0.8068 + 7.2883i, -1.3976 + 7.7358i, -1.3202 + 7.4629i,  1.2590 + 7.0971i,  2.2295 + 6.9357i,  1.8392 + 7.6136i,  1.9769 + 7.4828i,  4.0085 + 5.9866i,  5.1464 + 5.4989i,  4.8979 + 6.1621i,  4.8424 + 5.8240i,  6.2306 + 2.9844i,  6.5088 + 2.6620i,  6.6797 + 3.4229i,  6.8389 + 3.2161i,  7.2490 + 0.4540i,  7.2419 - 0.2875i,  7.9512 + 0.2046i,  7.6565 - 0.0586i,  6.8486 - 2.3991i,  6.4575 - 3.5261i,  7.1938 - 3.3717i,  6.8617 - 3.4357i,  5.0123 - 5.2440i,  4.4446 - 5.9580i,  4.9454 - 6.2907i,  4.5679 - 6.2646i,  1.9677 - 7.0653i,  0.7636 - 7.1545i,  1.4639 - 7.6475i,  1.2734 - 7.6050i, -1.4963 - 6.5191i, -2.0666 - 6.5307i, -1.9704 - 7.3434i, -2.0193 - 7.1387i, -4.1087 - 4.8792i, -4.8624 - 4.4759i, -5.1669 - 5.2055i, -5.2933 - 5.1309i, -5.9464 - 2.4250i, -6.3807 - 1.3049i, -6.7889 - 2.0365i, -6.8315 - 1.7599i, -6.5214 + 0.3185i, -6.5825 + 1.2676i, -6.8967 + 1.3818i, -6.7207 + 1.6126i, -5.3154 + 3.0265i, -4.7996 + 4.4405i, -5.2963 + 4.4435i, -4.8238 + 4.5424i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  0.0000 + 0.0000i,  6.8141 - 1.3480i,  5.9401 - 0.3202i,  6.5185 - 0.4471i,  6.3941 - 0.1880i,  5.5881 - 4.4636i,  5.9344 - 3.2837i,  5.9448 - 3.8070i,  5.7599 - 3.4943i,  2.7061 - 6.4488i,  3.2733 - 5.7247i,  3.3359 - 5.9795i,  3.4799 - 5.7947i, -0.6843 - 7.2648i,  0.4900 - 6.6753i,  0.0335 - 7.1086i,  0.1352 - 6.8725i, -3.9704 - 6.4524i, -2.7691 - 6.3162i, -3.3189 - 6.5372i, -3.1571 - 6.4581i, -6.6125 - 4.2548i, -5.7838 - 4.5756i, -6.4065 - 4.6584i, -6.2066 - 4.5624i, -7.8689 - 0.7190i, -6.8772 - 1.7643i, -7.7922 - 1.1049i, -7.4785 - 1.3444i, -7.6561 + 2.8557i, -7.4735 + 1.6865i, -7.6504 + 2.5191i, -7.4845 + 2.2204i, -5.5713 + 5.6752i, -6.0624 + 4.7036i, -5.7438 + 5.4135i, -5.7019 + 5.2517i, -2.5392 + 7.3504i, -2.7643 + 6.9841i, -2.5241 + 7.3129i, -2.7685 + 7.1341i,  1.1935 + 7.6925i,  0.3101 + 7.2982i,  0.8296 + 7.7117i,  0.7885 + 7.5080i,  4.1174 + 6.5763i,  3.4150 + 6.3628i,  4.0461 + 6.4662i,  3.9384 + 6.1726i,  6.3040 + 3.9661i,  5.6795 + 4.5784i,  6.3308 + 4.3033i,  6.0616 + 4.3668i,  7.5804 + 1.2761i,  7.0650 + 1.8266i,  7.4782 + 1.5661i,  7.3989 + 1.6566i,  7.6033 - 1.7948i,  7.6347 - 1.0705i,  7.7220 - 1.5392i,  7.5310 - 1.4086i,  6.1474 - 4.4299i,  6.0141 - 3.7861i,  6.1050 - 4.4867i,  5.9534 - 4.3300i,  4.1456 - 6.8039i,  4.1039 - 6.2768i,  3.9412 - 6.7625i,  3.9467 - 6.5348i,  1.1673 - 7.8375i,  1.3703 - 7.4153i,  1.2106 - 7.8035i,  1.1019 - 7.6698i, -2.4254 - 7.6395i, -1.4596 - 7.4390i, -2.1035 - 7.8004i, -1.9928 - 7.5060i, -4.8805 - 6.3895i, -4.3947 - 6.3351i, -4.9486 - 6.4839i, -4.8092 - 6.3276i, -7.0064 - 3.8439i, -6.7661 - 4.0900i, -7.3233 - 3.8097i, -7.0652 - 3.9544i, -8.1652 - 0.3066i, -7.7241 - 1.0393i, -8.2892 - 0.6389i, -8.0122 - 0.9185i, -7.7049 + 2.6802i, -7.7035 + 2.6358i, -7.9389 + 2.8443i, -7.9510 + 2.6657i, -5.5186 + 5.6256i, -5.7981 + 5.3462i, -6.0599 + 5.6674i, -6.0327 + 5.6695i, -2.8493 + 7.3848i, -2.9204 + 7.3353i, -3.0564 + 7.7330i, -2.8612 + 7.4366i,  0.6878 + 8.0410i,  0.4877 + 8.0964i,  0.7979 + 8.4435i,  0.6819 + 8.1461i].';
% %     H = reshape(H(2:end, :).', [63*4, 1]);
% %     save H.mat H
%     for lamb_idx=1:64
%         lamb = lambs(lamb_idx);
%         F = exp(-1j*2*pi*spacing/lamb.*[0:N-1].' .* linspace(-1,1-2/N,N));
%         w = 2*pi*spacing/lamb.*linspace(-1,1-2/N,N).' - 2*pi*spacing/lamb.*psis;
%         S = exp(1j.*w.*(N-1)/2).*diric(w, N);
%         D = diag(exp(-1j*2*pi*tofs*3e8/lamb));
%         SD((lamb_idx-1)*N+1 : lamb_idx*N, 1:length(psis)) = S*D;
%         P((lamb_idx-1)*N+1 : lamb_idx*N) = F'*H((lamb_idx-1)*N+1 : lamb_idx*N);
%     end
%     f = norm(P-SD*pinv(SD)*P)^2;
end