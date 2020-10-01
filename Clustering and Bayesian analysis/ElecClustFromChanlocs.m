function [ Elec ] = ElecClust( Chanlocs, c, n )
%ELECCLUST Pick a ROI of electrodes

coor = nan(length(Chanlocs),3);

for e = 1:length(Chanlocs)
    if ~isempty(Chanlocs(e).X)
        coor(e,1) = Chanlocs(e).X;
        coor(e,2) = Chanlocs(e).Y;
        coor(e,3) = Chanlocs(e).Z;
    end
end

D = squareform(pdist(coor));

D = D(c,:);

[~,I] = sort(D);

Elec = I(1:n);
end