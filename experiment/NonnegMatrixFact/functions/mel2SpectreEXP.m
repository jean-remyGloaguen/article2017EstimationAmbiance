function Y = mel2SpectreEXP(X,sr,nfft)

if iscell(X)
    Y = cell(size(X,1),size(X,2));
    for ii = 1:size(X,1)
        for jj = 1:size(X,2)
            [Y{ii,jj}] = invaudspec(X{ii,jj}, sr, nfft, 'mel', 0, sr/2, 0, 1);
        end
        
    end
else
    [Y] = invaudspec(X, sr, nfft, 'mel', 0, sr/2, 0, 1);
end