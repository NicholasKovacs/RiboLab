function [ output_args ] = RiboVision_Species_Convert( rv_file, prefix, speciesCodes, newMoleculeName, Alignment, ItemListA, ItemListB )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

textfile=fileread(rv_file);
ParsedSelections=regexp(textfile,'(?<resNum>[^,]+),(?<helixName>[^\W]+)','names');
if strcmp(ParsedSelections(1).resNum,'resNum');
    ParsedSelections(1)=[];
end
% if isempty(ParsedSelections)
%     % May mean no color specified
%     ParsedSelections=regexp(textfile,'create (?<seleName>[^,]+), (?<moleName>[^\W]+) and \((?<resi>[^\)]+)\)','names');
%     nocolors=true;
% else
%     nocolors=false;
% end

IndicesA=regexp(Alignment(1).Sequence,'[^-~]');
IndicesB=regexp(Alignment(2).Sequence,'[^-~]');

[~,corename]=fileparts(rv_file);

fid=fopen([corename,'_',speciesCodes{2},'.csv'],'wt');
%fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s\n',RV_Lab_Struct(i).Conservation_Table{1,:});

for i=1:length(ParsedSelections)
    SeleSplits=strsplit(ParsedSelections(i).resNum,';');
    OutputSelections(i)=ParsedSelections(i);
    OutputResidue=cell(1,length(SeleSplits));
    for j=1:length(SeleSplits)
%         x=strcat(prefix{1},SeleSplits{j});
          resplit=strsplit(strtrim(SeleSplits{j}),':')
        [~,I]=ismember(x,ItemListA);
        Pos=IndicesA(I);
        [~,II]=ismember(Pos,IndicesB);
        if II <=0
            % If do not find an exact match, just take the previous
            % nucleotide
            PrevNuc=find(IndicesB<Pos, 1, 'last' );
            OutputResidue{j}=regexprep(ItemListB(PrevNuc),prefix{2},'');
            %OutputResidue{j}='x';
        else
            OutputResidue{j}=regexprep(ItemListB(II),prefix{2},'');
        end
        OutputSelections(i).resi=regexprep(OutputSelections(i).resi,OriginalResidue{j},OutputResidue{j});
        if nocolors
            ParsedSelections(i).color='red';
            OutputSelections(i).color='blue';
        end
    end
    OutputSelections(i).moleName=newMoleculeName;
    OutputSelections(i).seleName=regexprep(OutputSelections(i).seleName,speciesCodes{1},speciesCodes{2});
    %OutputSelections(i).color=['n_',OutputSelections(i).color];
    
    %Print original in new file
    fprintf(fid,'create %s, %s and (%s)\n',ParsedSelections(i).seleName,ParsedSelections(i).moleName,ParsedSelections(i).resi);
    fprintf(fid,'color %s, %s\n',ParsedSelections(i).color,ParsedSelections(i).seleName);
    fprintf(fid,'show cartoon, %s\n',ParsedSelections(i).seleName);
    fprintf(fid,'#show surface, %s\n\n\n',ParsedSelections(i).seleName);
    
    %Print converted in new file
    fprintf(fid,'create %s, %s and (%s)\n',OutputSelections(i).seleName,OutputSelections(i).moleName,OutputSelections(i).resi);
    fprintf(fid,'color %s, %s\n',OutputSelections(i).color,OutputSelections(i).seleName);
    fprintf(fid,'show cartoon, %s\n',OutputSelections(i).seleName);
    fprintf(fid,'#show surface, %s\n\n\n',OutputSelections(i).seleName);
    
end


fclose(fid);
end

