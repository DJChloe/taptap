unit UnitJoin;

interface
uses classes;

function Join_command(Files: TStringList; const DestFile: string): integer;

implementation
uses sysutils,IOUtils;

function Join_command(Files:TStringList; const DestFile: string): integer;
var
  srcFS, destFS: TFileStream;
  i: integer;
  TempFile:string;
  F: string;
begin
  result := 0;
  TempFile:=TPath.GetTempFileName;

  if (Files.Count > 0) and (DestFile <> '') then
  begin
    destFS := TFileStream.Create(TempFile, fmCreate or fmShareExclusive);
    try
      i := 0;
      while i < Files.Count do
      begin
        F := Files.Strings[i];
        Inc(i);
        if (CompareText(F, DestFile) <> 0) and (F <> '') then
        begin
          srcFS := TFileStream.Create(F, fmOpenRead or fmShareDenyWrite);
          try
            if destFS.CopyFrom(srcFS, 0) = srcFS.Size then
              Inc(result);
          finally
            srcFS.Free;
          end;
        end
        else
        begin
          { error }
        end;
      end;
    finally
      destFS.Free;
    end;
    TFile.Copy(TempFile,DestFile,true);
    TFile.Delete(TempFile);
  end;
end;
end.
