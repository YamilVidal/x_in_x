C1 = squeeze(M(:,elec,:))';

if strcmp(Measure,'SNR')
    ES = mes(C1,1,'g1');
else
    ES = mes(C1,0,'g1');
end

stat.c.posclusters(c).ES = ES; % Save effect size in the clustering stats structure

df    = size(stat.d1.individual,1)-1;
tstat = stat.c.posclusters(c).clusterstat;
p     = stat.c.posclusters(c).prob;
es    = mean(stat.c.posclusters(c).ES.g1);
ci    = mean(stat.c.posclusters(c).ES.g1Ci,2)';

s = [c, df, tstat, p, es, ci];fprintf('\nCluster %.f (cluster''s \\textit{t}\\textsubscript{(%.f)} = %.2f, \\textit{p} = %.3g, \\textit{d} = %.2f [%.2f, %.2f])\n\n',s)
