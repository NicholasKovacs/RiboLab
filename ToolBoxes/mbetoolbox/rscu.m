function [RSCU,W,CD] = rscu(aln,option)
%RSCU - Calculate the Relative Synonymous Codon Usage (RSCU) value
%Relative synonymous codon usage values are estimated as the ratio of the
%observed codon usage to that value expected if there is uniform usage within
%synonymous groups
%
% Syntax:  [RSCU,W,CD] = rscu(aln,'option')
% 
% Inputs:
%    aln    - Alignment structure
%    option - (optional) 'partial'|'all'; default='notall'
%
% Outputs:
%    RSCU   - Relative Synonymous Codon Usage (RSCU) value
%    W      - w value
%    CD     - Codons
%
% Examples:
%
% >> [RSCU] = rscu(aln);
% >> [RSCU] = rscu(aln,'notall');
% >> [RSCU] = rscu(aln,'all');
%
% See also: CALCULATECAI

% Molecular Biology & Evolution Toolbox, (C) 2007
% Author: James J. Cai
% Email: jamescai@stanford.edu
% Website: http://bioinformatics.org/mbetoolbox/
% Last revision: 5/18/2007

[n,m]=size(aln.seq);
icode=aln.geneticcode;
if(nargin==1) option='notall'; end

[CodonNum,CodonFreq]=codonusage(aln);

RSCU=zeros(n,64);
W=zeros(n,64);

X='*ACDEFGHIKLMNPQRSTVWY';

[GT] = codontable;
TABLE=GT(icode,:);

for (k=1:21)
	Y=find(TABLE==X(k));
for (j=1:n)
	Z=CodonNum(j,Y);
	if (sum(Z)==0)
		RSCU(j,Y)=0;
		W(j,Y)=0;
	else
		RSCU(j,Y)=Z./(sum(Z)/size(Z,2));
		W(j,Y)=RSCU(j,Y)./max(RSCU(j,Y));
	end
end
end

CD = {'AAA' 'AAC' 'AAG' 'AAT' 'ACA' 'ACC' 'ACG' 'ACT' 'AGA' 'AGC' 'AGG' 'AGT' 'ATA' 'ATC' 'ATG' 'ATT'...
      'CAA' 'CAC' 'CAG' 'CAT' 'CCA' 'CCC' 'CCG' 'CCT' 'CGA' 'CGC' 'CGG' 'CGT' 'CTA' 'CTC' 'CTG' 'CTT'...
      'GAA' 'GAC' 'GAG' 'GAT' 'GCA' 'GCC' 'GCG' 'GCT' 'GGA' 'GGC' 'GGG' 'GGT' 'GTA' 'GTC' 'GTG' 'GTT'...
      'TAA' 'TAC' 'TAG' 'TAT' 'TCA' 'TCC' 'TCG' 'TCT' 'TGA' 'TGC' 'TGG' 'TGT' 'TTA' 'TTC' 'TTG' 'TTT'};

switch (option)
    case ('all')
         return;
    case ('notall')
         EX=find(TABLE=='M'|TABLE=='W'|TABLE=='*');
	 RSCU(:,EX)=[];
	 W(:,EX)=[];
	 CD(EX)=[];
end