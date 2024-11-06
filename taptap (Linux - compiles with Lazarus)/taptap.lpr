program taptap;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  SysUtils,
  UnitAuto in 'UnitAuto.pas',
  UnitUtils in 'UnitUtils.pas',
  UnitRen in 'UnitRen.pas',
  UnitCat in 'UnitCat.pas',
  UnitCopy in 'UnitCopy.pas',
  Unithelp in 'Unithelp.pas',
  UnitChecks in 'UnitChecks.pas',
  UnitJoin in 'UnitJoin.pas';

function checkparams_cat(var tapname:string):boolean;
begin
  tapname:='';
  result:=false;
  if ParamCount<2
  then writeln('Not enough parameters !')
  else
  begin
    tapname:=ParamStr(2);
    if not FileExists(tapname)
    then begin
           case ParamCount of
           1:writeln('Not enough parameters !');
           2:writeln('The file ',tapname,' does not exist !');
           else writeln('too many parameters !');
           end;
           result:=false;
         end
    else begin
      result:=true;
    end;
  end;
end;

function checkparams_ren(var fileindex:integer;var tapname,newname:string):boolean;
var cl:string;
    clparsed:TStringList;
    index:integer;
    FileIndexString:string;
begin
    result:=false;
    fileindex:=-1;
    tapname:='';
    newname:='';
    CL:=CmdLine;
    clparsed:=TStringList.Create;
    try
      clparsed.Delimiter:=' ';
      clparsed.DelimitedText:=CL;
      if clparsed.count<5
      then writeln('Not enough parameters !')
      else
      begin
        index:=2;
        FileIndexString:=clparsed.Strings[index];
        if UpperCase(FileIndexString)='ALL'
        then fileindex:=-2
        else fileindex:=StrToIntDef(FileIndexString,-1);

        index:=3;
        tapname:=clparsed.Strings[index];
        if UpperCase(tapname)='FROM'
        then
        begin
          inc(index);
          tapname:=clparsed.Strings[index];
        end;

        if not FileExists(tapname)
        then writeln('The file ',tapname,' does not exist !')
        else
        begin
          inc(index);
          newname:=clparsed.Strings[index];
          if UpperCase(newname)='TO'
          then
          begin
            inc(index);
            if index<clparsed.count
            then newname:=''
            else newname:=clparsed.Strings[index];;
          end;
          result:=true;
        end;
      end;
    finally
      clparsed.Free;
    end;
end;

function checkparams_auto_del(var fileindex: integer; var tapname: string): boolean;
var
  index: integer;
  FileIndexString: string;
begin
  result := false;
  fileindex := -1;
  tapname := '';
  if ParamCount < 3 then
    writeln('Not enough parameters !')
  else
  begin
    index := 2;
    FileIndexString := ParamStr(index);
    if UpperCase(FileIndexString) = 'ALL' then
      fileindex := -2
    else
    begin
      fileindex := StrToIntDef(FileIndexString, -1);
      if fileindex = -1 then
      begin
        writeln('Impossible :');
        writeln('The <FileIndex> is not valid and must be a valid integer');
        writeln('Check your syntax.');
      end;
    end;

    index := 3;
    if ParamCount < index then
      writeln('Not enough parameters !')
    else
    begin
      tapname := ParamStr(index);
      if UpperCase(tapname) = 'FROM' then
      begin
        inc(index);
        if ParamCount < index then
          writeln('Not enough parameters !')
        else
        begin
          tapname := ParamStr(index);
          if not FileExists(tapname) then
            writeln('The file ', tapname, ' does not exist !')
          else
            result := true;
        end;
      end
      else
      begin
        if not FileExists(tapname) then
          writeln('The file ', tapname, ' does not exist !')
        else
          result := true;
      end;
    end;
  end;
end;


function checkparams_copy(var fileindex:integer;var tapname,destdirectory:string):boolean;
var index:integer;
    FileIndexString:string;
begin
    result:=false;
    fileindex:=-1;
    tapname:='';
    if ParamCount<3
    then writeln('Not enough parameters !')
    else
    begin
      index:=2;
      FileIndexString:=ParamStr(index);
      if UpperCase(FileIndexString)='ALL'
      then fileindex:=-2
      else begin
              fileindex:=StrToIntDef(FileIndexString,-1);
              if fileindex=-1 then
              begin
                writeln('Impossible :');
                writeln('The <FileIndex> is not valid and must be a valid integer');
                writeln('Check your syntax.');
              end;
      end;

      index:=3;
      if ParamCount<index
      then writeln('Not enough parameters !')
      else
      begin
        tapname:=ParamStr(index);
        if UpperCase(tapname)='FROM'
        then
        begin
          inc(index);
          if ParamCount<index
          then writeln('Not enough parameters !')
          else tapname:=ParamStr(index);
        end;

        if not FileExists(tapname)
        then writeln('The file ',tapname,' does not exist !')
        else
        begin
          result:=true;
          inc(index);
          if ParamCount<index
          then destdirectory:=''
          else
          begin
             destdirectory:=ParamStr(index);
             if UpperCase(destdirectory)='TO'
             then
             begin
                inc(index);
                if ParamCount<index
                then destdirectory:=''
                else destdirectory:=ParamStr(index);
             end;
          end;

          if (destdirectory='') then destdirectory:=GetCurrentDir;
          {
          //
          if (not HasValidPathChars(destdirectory,false))
          then begin
                 writeln('The directory path is not valid !');
                 result:=false;
          end
          else}
          begin
            if (not DirectoryExists(destdirectory))
            then CreateDir(destdirectory);
          end;
        end;
      end;
    end;
end;

function checkparams_split(var tapname,destdirectory:string):boolean;
var index:integer;
begin
    result:=false;
    tapname:='';
    if ParamCount<2
    then writeln('Not enough parameters !')
    else
    begin
      index:=2;
      if ParamCount<index
      then writeln('Not enough parameters !')
      else
      begin
        tapname:=ParamStr(index);
        if UpperCase(tapname)='FROM'
        then
        begin
          inc(index);
          if ParamCount<index
          then writeln('Not enough parameters !')
          else tapname:=ParamStr(index);
        end;

        if not FileExists(tapname)
        then writeln('The file ',tapname,' does not exist !')
        else
        begin
          result:=true;
          inc(index);
          if ParamCount<index
          then destdirectory:=''
          else
          begin
             destdirectory:=ParamStr(index);
             if UpperCase(destdirectory)='TO'
             then
             begin
                inc(index);
                if ParamCount<index
                then destdirectory:=''
                else destdirectory:=ParamStr(index);
             end;
          end;

          if (destdirectory='') then destdirectory:=GetCurrentDir;
          {if (not TPath.HasValidPathChars(destdirectory,false))
          then begin
                 writeln('The directory path is not valid !');
                 result:=false;
          end
          else}
          begin
            if (not DirectoryExists(destdirectory))
            then CreateDir(destdirectory);
          end;
        end;
      end;
    end;
end;

function checkparams_join(filelist:TStringList; var tapname:string):boolean;
var i:integer;
    Adir:string;
begin
    result:=false;
    if assigned(filelist) then
    begin
      filelist.StrictDelimiter:=true;
      filelist.Delimiter:='+';
      tapname:='';
      if ParamCount<3
      then writeln('Not enough parameters !')
      else
      begin
        filelist.DelimitedText:=ParamStr(2);
        tapname:=ParamStr(3);
        {if (not TPath.HasValidFileNameChars(ExtractFileName(tapname),false))
        then
        begin
          writeln(tapname,' is not a valid file name !');
          result:=false;
        end
        else
        if (not TPath.HasValidPathChars(ExtractFilePath(tapname),false))
        then
        begin
          writeln(tapname,' has not a valid path name !');
          result:=false;
        end
        else}
        begin
          Adir:=ExtractFiledir(tapname);
          if (not DirectoryExists(Adir))
          then CreateDir(Adir);
          result:=true;
        end;

        for I := 0 to filelist.Count-1 do
        begin
          if not FileExists(filelist.Strings[i])
          then
          begin
            writeln('The file ',filelist.Strings[i],' does not exist !');
            result:=false;
          end;
        end;
      end;
    end;
end;

procedure ExecuteProgram;
var command:string;
    tapname,newname,destdirectory:string;
    fileindex:integer;
    tapList:TStringList;
begin
  if ParamCount=0
  then help_command('')
  else
  begin
    command:=uppercase(ParamStr(1));
    if command='CAT' then
    begin
      if checkparams_cat(tapname)
      then cat_command(tapname);
    end
    else if command='REN' then
    begin
      if checkparams_ren(fileindex,tapname,newname)
      then ren_command(fileindex,tapname,newname);
    end
    else if command='AUTOON' then
    begin
      if checkparams_auto_del(fileindex,tapname)
      then SetAuto_command(fileindex,tapname,true);
    end
    else if command='AUTOOFF' then
    begin
      if checkparams_auto_del(fileindex,tapname)
      then SetAuto_command(fileindex,tapname,false);
    end
    else if ((command='COPY') or (command='EXTRACT')) then
    begin
      //copy <FileIndex> [from] <TapFile> [to] [<directory>]
      if checkparams_copy(fileindex,tapname,destdirectory) then
      if command='COPY'
      then copy_command(fileindex,tapname,destdirectory,mod_copy)
      else copy_command(fileindex,tapname,destdirectory,mod_extract);
    end
    else if command='DEL' then
    begin
      if checkparams_auto_del(fileindex,tapname)
      then copy_command(fileindex,tapname,'',mod_delete);
    end
    else if command='SPLIT' then
    begin
      if checkparams_split(tapname,destdirectory)
      then
      begin
       copy_command(FI_ALL,tapname,destdirectory,mod_extract);
       if GetFileSize(tapname)=0 then DeleteFile(tapname);
      end;
    end
    else if command='JOIN' then
    begin
      //join <TapFile 1>+<TapFile 2>+..+<TapFile n>  <TapfileDest>
      tapList:=TStringList.Create;
      try
        tapList.Clear;
        if checkparams_join(tapList,tapname)
        then
        begin
          Join_command(tapList,tapname);
          writeln('Done.');
        end;
      finally
       tapList.Free;
      end;
    end
    else if command='HEADLESS' then
    begin
     //remove header
    end
    else if uppercase(command)='2BMP' then
    begin
      //extract oric screen
    end
    else if uppercase(command)='2WAV' then
    begin
      //extract oric screen
    end
    else if uppercase(command)='2BAS' then
    begin
      //extract oric screen
    end
    else if uppercase(command)='HELP' then
    begin
      if ParamCount>2 then
      begin
        writeln('Too many parameters !');
        help_command('');
      end
      else help_command(uppercase(ParamStr(2)));
    end
    else help_command('');
  end;
end;
begin
  try
    ExecuteProgram;
  except
    //Gérer la condition d'erreur
    WriteLn('Error encountered, this program terminates...');
    //Définit ExitCode <> 0 pour indiquer la condition d'erreur (par convention)
    ExitCode := 1;
  end;
end.
