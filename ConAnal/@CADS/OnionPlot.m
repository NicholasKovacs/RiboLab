function [Pro,d]=OnionPlot(CADS_object,varargin)

I=1:length(CADS_object);
J=1:length(CADS_object(1).Results);
Merge=false;
bins=[];

if nargin >1
    for ind=1:length(varargin)/2
        switch varargin{2*ind-1}
            case 'CIndex'
                I=varargin{2*ind};
            case 'RIndex'
                J=varargin{2*ind};
            case 'Merge'
                Merge=varargin{2*ind};
            case 'Bins'
                if strcmpi(varargin{2*ind},'thirds')
                    [~, Bounds]=cSequenceColor(CADS_object);
                    bins=[-inf,Bounds(1)+realmin,Bounds(2)+realmin,Inf];
                else
                    bins=varargin{2*ind};
                end
        end
    end
end


if  Merge
    results=[CADS_object.Results];
    Keep=[CADS_object.Keep];
    proteins=[results.Protein];
    Pro=proteins.merge(Keep);
    d=Pro.OnionPlot(bins);
else
    for i=I
        for j=J
            CADS_object(i).Results(j).Protein.OnionPlot(bins,CADS_object(i).Keep(j));
        end
    end
end
end
