unit UnitRen;

interface
procedure ren_command(Fileindex:integer;tapname,newfilename:string);

implementation
uses classes,sysutils,windows,generics.collections,unitutils,ioutils,
     Unitchecks;

procedure ren_command(Fileindex:integer;tapname,newfilename:string);
var f1,f2:TFileStream;
    Catalogue:TList<Toricfile>;
    OricFile:TOricFile;
    b:byte;
    nname:string;
    i,j:integer;
    TempFile:string;
    BytesName:TBytes;
begin
  try
    Catalogue:=TList<Toricfile>.Create;
    try
      GetCatalogue(TapName,catalogue);
      CLNametoBytes(newfilename,BytesName);
      if (length(BytesName)>15)
      then begin
             writeln('Renaming is impossible :');
             writeln('The new name exeeds 15 bytes.');
      end
      else
      if check_1(Fileindex,TapName,Catalogue) then
      begin
        //get the name of tempfile
        TempFile:=TPath.GetTempFileName;
        f1:=TFileStream.Create(tapname,fmOpenRead);
        f2:=tfilestream.Create(TempFile,fmOpenWrite);

        try
          for i := 0 to Catalogue.Count-1 do
          begin
            OricFile:=Catalogue.Items[Fileindex];
            if ((FileIndex=i) or (FileIndex=FI_ALL)) then
            begin
              f1.position:=Catalogue.Items[Fileindex].StartHeader+3;
              // copy .tap data from start of file to name field of indextodo
              f2.CopyFrom(f1,Oricfile.StartName-f1.position+1);
              // skip source name
              f1.position:=Oricfile.StartData;

              //build target name
              nname:=BytestoName(BytesName);
              //write it
              j:=0;
              while (j<length(BytesName)) do
              begin
                b:=BytesName[j];
                f2.Write(b,1);
                inc(j);
              end;
              // Ending zero for closing file name
              b:=0;
              f2.Write(b,1);
              //name done
              writeln('File #'+FileIndex.ToString+' has been renamed to ('+nname+')');
            end
            else f2.CopyFrom(f1,OricFile.Endpos-f1.position+1);
          end;
        finally
          f1.Free;
          f2.Free;
        end;
        TFile.Copy(TempFile,tapname,true);
        TFile.Delete(TempFile);
      end;
    finally
      Catalogue.Free;
    end;
  except
    writeln('No renaming was performed');
    writeln('An unnatended error occured.');
  end;
end;
end.
