function [fdcomm, radar, cov] = UL_subgradient(fdcomm, radar_comm, radar, cov, ii,k)
% UL subgradient method 
% update P_ui within the sub-gradient method
t_UL_max = fdcomm.t_UL_max;
t_UL = 1;
R_UL = fdcomm.R_UL; % UL minimum rate
fdcomm_temp = fdcomm; 
% radar_temp = radar;
% cov_temp = cov;
Xi_k = fdcomm.Xi_UL(k)+fdcomm.Xi_DL(k) + sum(radar.Xi_r);
lambda_i_k_t = fdcomm.lambda_UL(ii,k);
mu_i_k_t = fdcomm.mu_UL(ii,k);
P_U_i = fdcomm.ULpower(ii);
d_UL_i = fdcomm.ULstream_num(ii);
HiB = fdcomm.ULchannels{ii};
R_in_ui = cov.in_UL{ii,k};
while t_UL <= t_UL_max
    % fdcomm tracks the optimal results
    % fdcomm_temp tracks the instantaneous lambda, Piu,
%     beta_i_k_t = 1/sqrt(t_UL);
%     epsilon_i_k_t = 1/sqrt(t_UL);
    beta_i_k_t = 1/sqrt(t_UL);
    epsilon_i_k_t = 1/sqrt(t_UL);
    P_iB_k_t = fdcomm_temp.ULprecoders{ii,k}; 
%     E_iB_k_t = fdcomm_temp.UL_MMSE{ii,k};
%     % the current iterate of the UL rate
%     R_iu_k_t = abs(log2(det((E_iB_k_t)^(-1)))); 
    R_iu_k_t = log2(det(eye(d_UL_i)+P_iB_k_t'*HiB'/R_in_ui*HiB*P_iB_k_t));
    % update lambda and mu
    lambda_i_k_new = lambda_i_k_t + beta_i_k_t*(abs(trace(P_iB_k_t*P_iB_k_t'))-P_U_i);
    lambda_i_k_t = max(lambda_i_k_new,0);
    mu_i_k_new = mu_i_k_t+epsilon_i_k_t*(R_UL-R_iu_k_t); 
    mu_i_k_t = max(mu_i_k_new,0);
    fdcomm_temp.mu_UL(ii,k) = mu_i_k_t;
    fdcomm_temp.lambda_UL(ii,k) = lambda_i_k_t;
    % Update PiB with new mu_i_k_t and lambda_i_k_t
%     fdcomm_temp = UL_precoders(k, ii, fdcomm_temp, radar_temp, cov_temp);
    fdcomm_temp = UL_precoders(k, ii, fdcomm_temp, radar, cov);
    % Update covariance matrices 
%     cov_temp = covmat(fdcomm_temp,radar_temp,radar_comm); 
    % update Comm WMMSE receivers and weight matrices
    fdcomm_temp = Comm_MMSE(fdcomm_temp, radar, cov);
    % Update radar WMMSE receivers and sweight matrices
%     radar_temp = radar_MMSE(radar_temp, cov_temp);
    % update Xi_MSE
    fdcomm_temp = Xi_comm_k(fdcomm_temp, k);
%     radar_temp = Xi_radar(radar_temp);
%     Xi_temp = fdcomm_temp.Xi_UL(k)+fdcomm_temp.Xi_DL(k) + sum(radar_temp.Xi_r);
    Xi_temp = fdcomm_temp.Xi_UL(k)+fdcomm_temp.Xi_DL(k) + sum(radar.Xi_r);
    if Xi_temp < Xi_k
        fdcomm = fdcomm_temp;
        Xi_k = Xi_temp; 
    end
    % calculate the new Xi_mse
    t_UL = t_UL+1;
end
end

