unit UnitUtils;

interface
  uses sysutils,classes;
  type
    Tofkind=(ofk_junk,ofk_mem,ofk_basic,ofk_ints,
             ofk_reals,ofk_strings, ofk_unknown);
    Tofquality=(ofq_none,ofq_bytes,ofq_synchro,ofq_header,ofq_name,ofq_missingdata, ofq_ok);
    TOricFile=record
        Startpos,Endpos:integer;
        ofk:Tofkind;
        ofq:Tofquality;
        hheader:array[0..8] of byte;
        name:string;
        StartHeader:integer;
        StartName:integer;
        StartData,EndData:integer;
        ExpectedDataSize:integer;
    end;
    TCatalog=array of TOricFile;
    procedure AddOricFile(var Acatalog:TCatalog;ofile:TOricFile);
    function GetFileNameWithoutExtension(const FileName: string): string;
    function Ishex(c: Char): Boolean;
    function BytestoName(var BytesName:TBytes):string;
    procedure InitOfFile(var OFile:TOricFile);
    procedure GetCatalogue(tapname:string;var Acatalog:TCatalog);
    procedure CLNametoBytes(CLName:string;var BytesName:TBytes);
    function GetFileSize(const APath: string): int64;
implementation

procedure AddOricFile(var Acatalog:TCatalog;ofile:TOricFile);
begin
  SetLength(Acatalog, length(Acatalog)+1);
  Acatalog[length(Acatalog)-1]:=ofile;
end;


function GetFileNameWithoutExtension(const FileName: string): string;
var
   i:integer;
begin
  i:=LastDelimiter('.'+PathDelim+DriveDelim,FileName);
  if ((i=0)  or  (FileName[i] <> '.'))
  then i:=MaxInt;
  Result:=ExtractFileName(Copy(FileName,1,I-1));
end;

function GetFileSize(const APath: string): int64;
var
  Sr : TSearchRec;
begin
  if FindFirst(APath,faAnyFile,Sr)=0 then
  try
    Result := Sr.size;
  finally
    FindClose(Sr);
  end
  else
    Result := -1;
end;

procedure AddByte(var ByteArray:TBytes;b:byte);
begin
  SetLength(ByteArray, length(ByteArray)+1);
  ByteArray[length(ByteArray)-1]:=b;
end;

function Ishex(c: Char): Boolean;
begin
  case c of
        'a'..'f':
        	result := true;
        'A'..'F':
        	result := true;
        '0'..'9':
        	result := true;
        else
        	result := False;
        end;
end;

procedure InitOfFile(var OFile:TOricFile);
var i:byte;
begin
  with OFile do
    begin
      Startpos:=0;
      Endpos:=0;
      ofk:=ofk_unknown;
      ofq:=ofq_none;
      for i:= 0 to 8 do hheader[i]:=0;
      name:='';
      StartHeader:=0;
      StartName:=0;
      StartData:=0;
      EndData:=0;
    end;
end;

function BytestoName(var BytesName:TBytes):string;
var nname:string;
    lastregular:boolean;
    b:byte;
    i:integer;
begin
  nname:='';
  lastregular:=true;
  i:=0;
  while (i<Length(BytesName)) do
  begin
    b:=BytesName[i];
    if b>0 then
    begin
      if ((b>=32) and (b<128)) then
      begin
        if (not lastregular) then nname:=nname+'|';
        nname:=nname+chr(b);
        lastregular:=true;
      end
      else
      begin
        if ((length(nname)>0) and (lastregular)) then nname:=nname+'|';
          nname:=nname+'#'+b.ToHexString(2);
          lastregular:=false;
      end;
    end;
    inc(i);
  end;
  result:=nname;
end;

//build the tap file catalog (useful positions in the tap file and data)
procedure GetCatalogue(tapname:string;var Acatalog:TCatalog);
var f1:TFileStream;
    b:byte;
    size:integer;
    hheader:array[0..8] of byte;
    name:string;
    i:integer;
    AddrDeb,AddrFin:integer;
    countbytes:integer;
    r,j:integer;
    lname,sizeOfArray:integer;
    numelements:integer;
    sizeofelem:byte;
    stringdatasize:integer;
    OFile:Toricfile;
    BytesName:TBytes;
begin
  Setlength(Acatalog,0);
  f1:=TFileStream.Create(TapName,fmOpenRead);
  try
    f1.Position:=0;
    InitOfFile(Ofile);

    while (f1.Position<f1.size) do
    begin
      InitOfFile(Ofile);
      OFile.Startpos:=f1.Position;
      OFile.ofq:=ofq_bytes;

      repeat
         r:=f1.Read(b,1);
      until (r=0) or (b<>$16);
      if ((r=0) or(b<>$24)) then begin
                     OFile.ofk:=ofk_junk;
                     OFile.Endpos:=f1.Position;
                  end
      else begin
        OFile.ofq:=ofq_synchro;
        OFile.StartHeader:=f1.Position;
        //header
        r:=f1.Read(hheader,9);
        if r<9 then begin
                       OFile.ofk:=ofk_junk;
                       OFile.Endpos:=f1.Position;
                    end
        else begin
          OFile.ofq:=ofq_header;
          for i:=0 to 8 do OFile.hheader[i]:=hheader[i];
          OFile.StartName:=f1.Position;
          //Name
          lname:=0;
          name:='';
          setlength(BytesName,0);
          repeat
            r:=f1.Read(b,1);
            inc(lname,r);
            if ((r=0) or (lname>16))
            then OFile.ofk:=ofk_junk;

            if ((b<>0) and (OFile.ofk<>ofk_junk))
            then AddByte(BytesName,b);
          until ((b=0) or (OFile.ofk=ofk_junk));
          if OFile.ofk=ofk_junk then OFile.Endpos:=f1.Position
          else
          begin
            OFile.ofq:=ofq_name;
            OFile.name:=BytestoName(BytesName);
            OFile.StartData:=f1.Position;
            case hheader[2] of
               $00:OFile.ofk:=ofk_basic;
               $80:OFile.ofk:=ofk_mem;
               $40:begin
                 case hheader[1] of
                    $FF:OFile.ofk:=ofk_strings;
                    $00:begin
                      case hheader[0] of
                        $00:OFile.ofk:=ofk_reals;
                        $80:OFile.ofk:=ofk_ints;
                        else OFile.ofk:=ofk_junk;
                      end;
                    end
                    else OFile.ofk:=ofk_junk;
                 end
               end
               else OFile.ofk:=ofk_junk;
            end;
            if OFile.ofk=ofk_junk then OFile.Endpos:=f1.Position
            else
            begin
              OFile.StartData:=f1.Position;
              //data
              case OFile.ofk of
                ofk_basic, ofk_mem:
                begin
                  AddrDeb:=hheader[6]*256+hheader[7];
                  AddrFin:=hheader[4]*256+hheader[5];
                  size:=AddrFin-AddrDeb+1;

                  //data
                  if ((f1.Size-f1.Position)<(size-1)) then
                  begin
                     OFile.ofq:=ofq_missingdata;
                     OFile.Endpos:=f1.size-1;
                     OFile.EndData:=f1.size-1;
                     f1.Position:=f1.Size;
                  end
                  else begin
                     OFile.ofq:=ofq_ok;
                     f1.Seek(size,soCurrent);
                     OFile.Endpos:=f1.position-1;
                     OFile.EndData:=f1.position-1;
                  end;
                end;

                ofk_ints,ofk_reals,ofk_strings:
                begin
                  sizeOfArray:=hheader[6]*256+hheader[7];
                  //size expected
                  case OFile.ofk of
                    ofk_ints:sizeofelem:=2;
                    ofk_reals:sizeofelem:=5;
                    ofk_strings:sizeofelem:=3;
                    else sizeofelem:=1;
                  end;
                  numelements:=(sizeOfArray-6) div sizeofelem;
                  size:=numelements*sizeofelem;
                  case OFile.ofk of
                    ofk_ints,ofk_reals:
                    begin
                      countbytes:=0;
                      repeat
                        r:=f1.Read(b,1);
                        inc(countbytes,r);
                      until (r=0) or (countbytes=size);
                      if r=0 then
                      begin
                        OFile.ofq:=ofq_missingdata;
                        OFile.Endpos:=f1.size-1;
                        OFile.EndData:=f1.size-1;
                        f1.Position:=f1.Size;
                      end
                      else begin
                        OFile.ofq:=ofq_ok;
                        OFile.Endpos:=f1.position-1;
                        OFile.EndData:=f1.position-1;
                      end;
                    end;
                    ofk_strings:
                    begin
                      stringdatasize:=0;
                      countbytes:=0;
                      j:=0;
                      repeat
                        r:=f1.Read(b,1);
                        inc(countbytes,r);
                        inc(j,r);
                        if j=1 then inc(stringdatasize,b);
                        if j=3 then j:=0;
                      until (r=0) or (countbytes=size);
                      if r=0 then
                      begin
                        OFile.ofq:=ofq_missingdata;
                        OFile.Endpos:=f1.size-1;
                        OFile.EndData:=f1.size-1;
                      end
                      else
                      begin
                        countbytes:=0;
                        repeat
                          r:=f1.Read(b,1);
                          inc(countbytes,r);
                        until (r=0) or (countbytes=stringdatasize);
                        if r=0 then
                        begin
                          OFile.ofq:=ofq_missingdata;
                          OFile.Endpos:=f1.size-1;
                          OFile.EndData:=f1.size-1;
                        end
                        else begin
                          OFile.ofq:=ofq_ok;
                          Ofile.EndData:=f1.Position;
                          OFile.Endpos:=f1.Position;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
              //end data
            end;
          end;
        end;
      end;
      AddOricFile(ACatalog,OFile);
    end;
  finally
    f1.Free;
  end;
end;

procedure CLNametoBytes(CLName:string;var BytesName:TBytes);
var s1,s2:TstringList;
i,j,jj:integer;
b:byte;
st1,st2,cc:string;
begin
  s1:=TStringList.Create;
  s2:=TStringList.Create;
  try
    s1.StrictDelimiter:=true;
    s1.Delimiter:='+';
    s1.DelimitedText:=CLName;
    s2.StrictDelimiter:=true;
    s2.Delimiter:='+';
    s2.QuoteChar:=#0;
    s2.DelimitedText:=CLName;
    setlength(BytesName,0);
    for I := 0 to s1.Count-1 do
    begin
      st1:=s1.Strings[i];
      st2:=s2.Strings[i];
      if st1<>st2 //chaine ASCII
      then BytesName:=BytesOf(st1)
      else
      begin
        if length(st1)>0 then
        begin
          if st1[1]='#' then
          begin
            jj:=(length(st1)-1) div 2;
            j:=1;
            while j<=jj do
            begin
              cc:='$'+st1[2*j]+st1[2*j+1];
              b:=StrToIntdef(cc,0);
              AddByte(BytesName,b);
              inc(j);
            end;
          end
          else BytesName:=BytesOf(st1);
        end;
      end;
    end;
  finally
    s1.Free;
    s2.Free;
  end;
end;


end.
