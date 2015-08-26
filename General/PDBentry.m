classdef PDBentry < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        ID
        PDB
        UniqueResSeq
        AtomSerNo
        UniqueAtomNames
        ChainID
        thermal_factor
        variability
    end
    
    methods
        function pdb_obj = PDBentry(name)
            if nargin < 1
                name='un-named';
            end
            pdb_obj.Name  = name;
        end
        
        function ImportPDB(pdb_obj,select)
            switch select
                case 'gui'
                    [FileName,PathName] = uigetfile({'*.pdb';'*.*'},...
                        'Select the PDF File','MultiSelect', 'off');
                    if isequal(FileName,0) || isequal(PathName,0)
                        skip=true;
                    else
                        skip=false;
                    end
                    gui=true;
                otherwise
                    skip=false;
                    file=select;
                    gui=false;
                    if ispc()
                        slash=strfind(file,'\');
                    else
                        slash=strfind(file,'/');
                    end
                    if ~isempty(slash)
                        PathName=file(1:slash(end));
                        FileName=file(slash(end)+1:end);
                    else
                        PathName=[];
                        FileName=file;
                    end
            end
            if ~skip
                if gui
                    h=PleaseWait();
                end
                newID=[PathName,FileName(1:end-4)];
                file=strcat(PathName,FileName);
                if exist([newID,'.mat'],'file') == 2
                    load([newID,'.mat'])
                else
                    pdb=importdata(file);
                    save([newID,'.mat'],'pdb','-v7')
                end
                if isfield(pdb.Model,'AnisotropicTemp')
                    pdb.Model.AnisotropicTemp=[];
                    pdb.Model=rmfield(pdb.Model,'AnisotropicTemp');
                    save([newID,'.mat'],'pdb','-v7');
                end
                pdb_obj.PDB=pdb;
                pdb_obj.ID=newID;
                if gui
                    delete(h)
                end
            end
            
        end
        
        function PDBfromStruct(pdb_obj,pdb,newID)
            if nargin < 3
                newID='none';
            end
            
            pdb_obj.PDB=pdb;
            pdb_obj.ID=newID;
        end
        
        function Process(pdb_obj,het)
            if nargin == 1 || het
                if isfield(pdb_obj.PDB.Model,'HeterogenAtom')                           % If HeterogenAtoms are found in the pdb structure, include them
                    pdb_obj.PDB.Model.Atom=[pdb_obj.PDB.Model.Atom pdb_obj.PDB.Model.HeterogenAtom];
                    pdb_obj.PDB.Model=rmfield(pdb_obj.PDB.Model,'HeterogenAtom');
                else
                end
            end
            resnum=cellstr(num2str([pdb_obj.PDB.Model.Atom.resSeq]'));
            try
                reschain=cellstr([pdb_obj.PDB.Model.Atom.chainID]');
            catch
                reschain={''};
            end
            resiCode={pdb_obj.PDB.Model.Atom.iCode}';
            altLoc={pdb_obj.PDB.Model.Atom.altLoc}';
            pdb_obj.UniqueResSeq=strcat(reschain,'_',resnum,resiCode);
            pdb_obj.ChainID=reschain;
            pdb_obj.AtomSerNo=[pdb_obj.PDB.Model.Atom.AtomSerNo]';
            pdb_obj.UniqueAtomNames=strcat(reschain,'_',strtrim(resnum),resiCode,'_',{pdb_obj.PDB.Model.Atom.AtomName}',regexprep(altLoc,'.','_$0'));
        end
        
        function NewPDBentry=SubsetbyName(pdb_obj,subset_names,varargin)
            disp(42)
            NewPDBentry = PDBentry([pdb_obj.Name,'_cut']);
            NewPDBentry.PDBfromStruct(pdb_obj.PDB,pdb_obj.ID);

            d=char(pdb_obj.UniqueResSeq);
            ResidueNames=strtrim(cellstr(d(:,3:end)));
            
            y=ismember(ResidueNames,subset_names);
            NewPDBentry.PDB.Model.Atom=NewPDBentry.PDB.Model.Atom(y); 
            NewPDBentry.Process();
        end
        
        function NewPDB_Entries=SplitByChain(pdb_obj)
%             MolIDRows=(regexp(reshape(pdb_obj.PDB.Compound',1,[]),'MOL_ID')-1)/...
%                 size(pdb_obj.PDB.Compound,2) + 1 ;
%             MolIDRows=[MolIDRows,size(pdb_obj.PDB.Compound,1)+1];
%             ChainIDList=strtrim(regexp(reshape(pdb_obj.PDB.Compound',1,[]),'CHAIN: ([^;]+)','tokens'));
%             for i=1:length(ChainIDList)
%                 x(i)=strtrim(regexp(ChainIDList{i},',','split'));
%             end
%             y=ismember([x{:}],unique({pdb_obj.PDB.Model.Atom.chainID}));
%             keepChains=x(y);
%             %come back to make L,M work
%             
%             [~,I]=ismember([keepChains{:}],[ChainIDList{:}]);
% %             for j=1:length(keepChains)
% %                 [~,I]=i
% % 
% %             en
            
            ChainIDList=unique({pdb_obj.PDB.Model.Atom.chainID});
%             HeteroIDList=unique({pdb_obj.PDB.Model.HeterogenAtom.chainID});
     
%             MoleculeNames=regexp(reshape(pdb_obj.PDB.Compound',1,[]),'MOLECULE: ([^;]+)','tokens');
%             MoleculeNames=MoleculeNames(I);
%             MolIDRows=MolIDRows(I);
%             MolIDRows=[MolIDRows,size(pdb_obj.PDB.Compound,1)+1];
%             ChainIDList=ChainIDList(I);
            numChains=length(ChainIDList);
%             TF=cell(numChains,1);
            NewPDB(numChains)=pdb_obj.PDB;
            for chain_ind=numChains:-1:1
                NewPDB(chain_ind)=pdb_obj.PDB;
                %                 NewPDB(chain_id).Header=pdb_obj.PDB.Header;
                %                 NewPDB(chain_id).Title=pdb_obj.PDB.Title;
                %fix up compound wrong lines
%                 NewPDB(mol_id).Compound=pdb_obj.PDB.Compound(colon(MolIDRows(mol_id),MolIDRows(mol_id + 1) - 1),:);
                %                 NewPDB(chain_id).Source=pdb_obj.PDB.Source; % can split up later if wanted, by molID
                %                 NewPDB(chain_id).Keywords=pdb_obj.PDB.Keywords;
                %                 NewPDB(chain_id).ExperimentData=pdb_obj.PDB.ExperimentData;
                %                 NewPDB(chain_id).Authors=pdb_obj.PDB.Authors;
                %                 NewPDB(chain_id).RevisionDate=pdb_obj.PDB.RevisionDate;
                %                 NewPDB(chain_id).Title=pdb_obj.PDB.Title;
%                 x=strtrim(regexp(ChainIDList{chain_ind},',','split'));
                
%                 for j=1:length(x{1})
%                     TF{chain_ind}(j,:)=strcmp(x{1}{j},chainIDs);
%                 end
%                 keep=logical(sum(TF{chain_ind},1));
                keep=ismember({NewPDB(chain_ind).Model.Atom.chainID},ChainIDList{chain_ind});
                
                NewPDB(chain_ind).Model.Atom=NewPDB(chain_ind).Model.Atom(keep);
%                 name=[MoleculeNames{chain_ind}{1},': Chain(s) ',ChainIDList{chain_ind}{:}];
                NewPDB_Entries(chain_ind) = PDBentry([pdb_obj.Name,'_',ChainIDList{chain_ind}]);
                NewPDB_Entries(chain_ind).PDBfromStruct(NewPDB(chain_ind),pdb_obj.ID);
                
            end
        end
        
        function NewPDB_Entries=SplitByMolID(pdb_obj)
            MolIDRows=(regexp(reshape(pdb_obj.PDB.Compound',1,[]),'MOL_ID')-1)/...
                size(pdb_obj.PDB.Compound,2) + 1 ;
            MolIDRows=[MolIDRows,size(pdb_obj.PDB.Compound,1)+1];
            ChainIDList=strtrim(regexp(reshape(pdb_obj.PDB.Compound',1,[]),'CHAIN: ([^;]+)','tokens'));
            for i=1:length(ChainIDList)
                %x(i)=strtrim(regexp(ChainIDList{i},',','split'));
                x(i)=strtrim(ChainIDList{i});
            end
            y=ismember(x,unique({pdb_obj.PDB.Model.Atom.chainID}));
            keepChains=x(y);
            %come back to make L,M work
            
            [~,I]=ismember(keepChains,[ChainIDList{:}]);
%             for j=1:length(keepChains)
%                 [~,I]=i
% 
%             end
            
            chainIDs={pdb_obj.PDB.Model.Atom.chainID};
            try 
                heteroIDs={pdb_obj.PDB.Model.HeterogenAtom.chainID};
            catch
                heteroIDs={''};
            end
     
            MoleculeNames=regexp(reshape(pdb_obj.PDB.Compound',1,[]),'MOLECULE: ([^;]+)','tokens');
            MoleculeNames=MoleculeNames(I);
            MolIDRows=MolIDRows(I);
            MolIDRows=[MolIDRows,size(pdb_obj.PDB.Compound,1)+1];
            ChainIDList=ChainIDList(I);
            numMolIDs=length(MolIDRows)-1;
            TF=cell(numMolIDs,1);
            TFH=cell(numMolIDs,1);
            NewPDB(numMolIDs)=pdb_obj.PDB;
            for mol_id=numMolIDs:-1:1
                NewPDB(mol_id)=pdb_obj.PDB;
                %                 NewPDB(chain_id).Header=pdb_obj.PDB.Header;
                %                 NewPDB(chain_id).Title=pdb_obj.PDB.Title;
                %fix up compound wrong lines
                NewPDB(mol_id).Compound=pdb_obj.PDB.Compound(colon(MolIDRows(mol_id),MolIDRows(mol_id + 1) - 1),:);
                %                 NewPDB(chain_id).Source=pdb_obj.PDB.Source; % can split up later if wanted, by molID
                %                 NewPDB(chain_id).Keywords=pdb_obj.PDB.Keywords;
                %                 NewPDB(chain_id).ExperimentData=pdb_obj.PDB.ExperimentData;
                %                 NewPDB(chain_id).Authors=pdb_obj.PDB.Authors;
                %                 NewPDB(chain_id).RevisionDate=pdb_obj.PDB.RevisionDate;
                %                 NewPDB(chain_id).Title=pdb_obj.PDB.Title;
                x=strtrim(regexp(ChainIDList{mol_id},',','split'));
                
                for j=1:length(x{1})
                    TF{mol_id}(j,:)=strcmp(x{1}{j},chainIDs);
                    TFH{mol_id}(j,:)=strcmp(x{1}{j},heteroIDs);
                end
                keep=logical(sum(TF{mol_id},1));
               
                keepH=logical(sum(TFH{mol_id},1));
                NewPDB(mol_id).Model.Atom=NewPDB(mol_id).Model.Atom(keep);
                try
                    NewPDB(mol_id).Model.HeterogenAtom=NewPDB(mol_id).Model.HeterogenAtom(keepH);
                catch
                end
                name=[MoleculeNames{mol_id}{1},': Chain(s) ',ChainIDList{mol_id}{:}];
                NewPDB_Entries(mol_id) = PDBentry(name);
                NewPDB_Entries(mol_id).PDBfromStruct(NewPDB(mol_id),pdb_obj.ID);
                
            end
        end
        
    end
end