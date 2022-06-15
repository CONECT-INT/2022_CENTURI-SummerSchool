% Assume you have gathered your population activity associated with one
% particular condition into a matrix [time bins x neurons], where each
% column is the trial-averaged PSTH of a neuron. The width of the time bin
% in my case was 20 ms. In addition to binning, you may want to smooth the
% PSTHs by applying a Gaussian kernel (e.g., 40 ms width), but that's not
% an obligation (it will simply make your trajectories look smoother...)
% I will call this matrix PSTH_cond1, and assume it has T x N dimension 
%
% Assume you have multiple conditions (say cond_1, _2 and _3) and you want
% to apply PCA on all your conditions simultaneously to obtain 3 neural
% trajectories in the same space, then you can simply concatenate the
% condition-specific matrices along the time dimension (rows) as follows:
PSTH_concat = [PSTH_cond1; PSTH_cond2; PSTH_cond3]; % [3T x N]
 
% Next, you compute the mean of your concatenated data matrix:
data_mean = mean(PSTH_concat, 1); % mean along the time dimension

% Next, apply PCA to your data matrix:
[coeff, ~, ~, ~, explained] = pca(PSTH_concat-data_mean);
% Here, the first output "coeff" will give you what is called the 
% "loadings" matrix: an N x N matrix whose columns represent the
% coordinates of each of your PC dimension in the original neural basis.
% That is, the first column is your PC1, the second column is PC2, etc.
% By definition of PCA, the columns of the loadings matrix are orthogonal,
% which means your PCs are orthogonal. For more info, check out the pca
% page https://fr.mathworks.com/help/stats/pca.html
%
% The second output, which here I am not outputing using ~, normally gives
% you the projection of your data onto each of the PC, aka "PC scores".
% This is what you care about if you want to see the dynamics along the
% first few PCs, but here I prefer not to use this second output because if
% you remember above, we concatenated several conditions, and so the size
% of the "score" matrix will be Tx(nb of condition) x N. Because your
% conditions may not be of the same duration, it might be tricky to chop
% the score matrix to recover each of your individual condition, and so I
% tend to do it manually (see below)
%
% The fifth output "explained" gives you the percent of variance explained
% by each PC, that is, explained(1) = variance explained by PC1 / the total
% variance across all dimensions. By definition, explained will be a
% decreasing vector, because increasing PCs explain less and less variance
%
% Finally, note that here as the input to pca(), I remove the mean to center
% the data. This is not strictly required since pca() does it for you
% inside the function, but I like to keep it apparent just to remember
% later than when I project my data onto the PCs manally, I need to center 
% it (see below)

% Now that you have computed your "loadings" matrix, you can project your
% original data onto the space spanned by the top 3 PCs
nDims = 3; % nb of PCs to keep
mat_coeff = coeff(:, 1:nDims); % select the first 3 PCs [N x 3]

% Now for each condition, center the data and project the data onto the top
% 3 PC space
score_cond1 = (PSTH_cond1-data_mean)*mat_coeff; % [T x 3]
score_cond2 = (PSTH_cond2-data_mean)*mat_coeff; % [T x 3]
score_cond3 = (PSTH_cond3-data_mean)*mat_coeff; % [T x 3]
% You can think of your scores as PSTHs, but they are now associated not
% with a single neuron, but a linear combination of your neurons. The
% weight for each neuron is given by the corresponding PC loadings.

% Now you can plot the neural trajectories in 3D
figure; 
plot3(score_cond1(:, 1), score_cond1(:, 2), score_cond1(:, 3), 'r.-', 'markersize', 12)
hold on
plot3(score_cond2(:, 1), score_cond2(:, 2), score_cond2(:, 3), 'b.-', 'markersize', 12)
hold on
plot3(score_cond3(:, 1), score_cond3(:, 2), score_cond3(:, 3), 'g.-', 'markersize', 12)
grid on
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

% Finally, you may want to plot what is called the "scree plot", that is, 
% the plot that shows the percent variance explained with increasing # of PCs)
% I typically do it up to 10 PCs, and look for how many PCs I need to
% explain let's say 80% of the total variance...
nPlotPCs = 10; 
figure; plot(cumsum(explained(1:nPlotPCs)), 'k.', 'markersize', 36)
hold on
plot(1:nPlotPCs, 100*ones(size(1:nPlotPCs)), 'k--', 'linewidth', 3)
axis([0.8 nPlotPCs 0 105]);
xticks(0:nPlotPCs)
yticks(0:20:100)
xlabel('# PCs')
ylabel('% Var')