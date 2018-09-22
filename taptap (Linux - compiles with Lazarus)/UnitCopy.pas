unit UnitCopy;

interface
uses unitutils;

type
    Tmode=(mod_copy,mod_delete,mod_extract);

procedure copy_command(FileIndex:integer;TapName,directory:string;mode:Tmode);
implementation
  uses classes,sysutils,Unitchecks,fileutil;

procedure copy_command(FileIndex:integer;TapName,directory:string;mode:Tmode);
var f1,f2:TFileStream;
    Catalogue:TCatalog;
    i:integer;
    sizetodo:integer;
    Tempfile:string;
    newfilename:string;
begin
  try
    GetCatalogue(TapName,catalogue);
    if check_1(Fileindex,TapName,Catalogue) then
    begin
      //on a le catalogue, go
      if FileIndex<length(Catalogue) then
      begin
        if ((mode=mod_copy) or (mode=mod_extract)) then
        begin
          f1:=TFileStream.Create(TapName,fmOpenRead);
          try
            for i := 0 to length(Catalogue)-1 do
            begin
              with catalogue[i] do sizetodo:=endpos-startpos+1;
              if ((FileIndex=i) or (FileIndex=FI_ALL)) then
              begin
                TempFile:=GetTempFileName;
                f2:=tfilestream.Create(TempFile,fmOpenWrite);
                try
                  f2.CopyFrom(f1,sizetodo);
                finally
                  f2.free;
                end;
                newfilename:=IncludeTrailingPathDelimiter(directory);
                newfilename:=newfilename+GetFileNameWithoutExtension(tapname);
                newfilename:=newfilename+'_#'+i.tostring+'.tap';
                CopyFile(TempFile,newfilename);
                DeleteFile(TempFile);
                if (mode=mod_copy) then
                   writeln('#'+i.ToString+': copy done.');
              end
              else f1.Seek(sizetodo,soFromCurrent); //skip source file copy
            end;
          finally
            f1.Free;
          end;
        end;

        if ((mode=mod_delete) or (mode=mod_extract)) then
        begin  //mode=mod_delete
          TempFile:=GetTempFileName;
          f1:=TFileStream.Create(TapName,fmOpenRead);
          f2:=tfilestream.Create(TempFile,fmOpenWrite);
          try
            for i := 0 to length(Catalogue)-1 do
            begin
              with catalogue[i] do sizetodo:=endpos-startpos+1;
              if ((fileindex=i) or (FileIndex=FI_ALL))
              then
              begin
                f1.Seek(sizetodo,soFromCurrent); //skip oric file
                write('#'+i.ToString+': ');
                case mode of
                  mod_extract:writeln('extracted.');
                  mod_delete:writeln('deleted.');
                end;
              end
              else f2.CopyFrom(f1,sizetodo);
            end
          finally
            f2.free;
            f1.Free;
            CopyFile(TempFile,TapName);
            DeleteFile(TempFile);
          end;
        end;
      end;
    end;
  except
    writeln('Nothing was performed');
    writeln('An unnatended error occured.');
  end;
end;
end.
