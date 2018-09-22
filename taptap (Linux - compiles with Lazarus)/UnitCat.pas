unit UnitCat;

interface
procedure cat_command(TapName:string);
implementation
uses classes,sysutils,unitutils;

procedure cat_command(TapName:string);
var Catalogue:TCatalog;
    OricFile:TOricFile;
    size:integer;

    index:integer;
    AddrDeb,AddrFin:integer;
    sizeOfArray:integer;
    numelements:integer;
    sizeofelem:byte;
begin
  GetCatalogue(TapName,catalogue);
  writeln('Catalog of "',extractfilename(TapName),'"');
  if length(Catalogue)=0
  then writeln(extractfilename(TapName)+' is empty !')
  else
  for index:=0 to length(Catalogue)-1 do
  begin
    OricFile:=Catalogue[index];
    writeln('Index.... : ',index);
    if OricFile.ofq=ofq_bytes
    then begin
        writeln('No Syncronisation bytes found');
        writeln('File kind : JUNK data or headless Oric file.');
        writeln('Size............ : ',OricFile.Endpos-OricFile.Startpos+1,' bytes');
    end
    else
    begin
      case OricFile.ofk of
        ofk_junk:begin
          writeln('File kind....... : JUNK or headless data !');
          writeln('Size............ : ',OricFile.Endpos-OricFile.Startpos+1,' bytes');
        end;
        ofk_mem,ofk_basic:
        begin
          AddrDeb:=OricFile.hheader[6]*256+OricFile.hheader[7];
          AddrFin:=OricFile.hheader[4]*256+OricFile.hheader[5];
          writeln('Name............ : ',OricFile.name);
          write('File kind....... : ');
          case OricFile.ofk of
            ofk_basic:writeln('BASIC');
            ofk_mem:writeln('Machine code or memory bloc');
          end;
          write('Auto............ : ');
          if OricFile.hheader[3]=0
          then writeln('No')
          else writeln('Yes');
          writeln('byte 9.......... : #',uppercase(OricFile.hheader[8].ToHexString(2)));
          writeln('Starting Address : #',uppercase(IntToHex(AddrDeb,4)));
          writeln('Ending   Address : #',uppercase(IntToHex(AddrFin,4)));

          //data
          if OricFile.ofq=ofq_missingdata then
          begin
             writeln('File quality.... : bad. (missing data ! corrupted file ?)');
             writeln('Size of data.... : ',OricFile.EndData-OricFile.StartData+1,' bytes');
             writeln('Size expected... : ',AddrFin-AddrDeb+1,' bytes');
          end
          else begin
             writeln('Size of data.... : ',OricFile.EndData-OricFile.StartData+1,' bytes');
             writeln('File quality : good.');
          end;
        end;
        ofk_ints,ofk_reals,ofk_strings:
        begin
          sizeOfArray:=OricFile.hheader[6]*256+OricFile.hheader[7];
          AddrDeb:=OricFile.hheader[4]*256+OricFile.hheader[5];
          //size expected
          case OricFile.ofk of
            ofk_ints:sizeofelem:=2;
            ofk_reals:sizeofelem:=5;
            ofk_strings:sizeofelem:=3;
            else sizeofelem:=1;
          end;
          numelements:=(sizeOfArray-6) div sizeofelem;
          size:=numelements*sizeofelem;
          writeln('Name............ : ',OricFile.name);
          write('File kind....... : ');
          case OricFile.ofk of
            ofk_ints:writeln('Array of integers');
            ofk_reals:writeln('Array of floats');
            ofk_strings:writeln('Array of strings');
          end;
          writeln('byte 9.......... : #',uppercase(OricFile.hheader[8].ToHexString(2)));
          writeln('Starting Address : #',uppercase(IntToHex(AddrDeb,4)));
          write('Datasize indicated : ',sizeOfArray,' bytes');
          if OricFile.ofk=ofk_strings
          then writeln(' + string descriptors + strings')
          else writeln;
          write('Datasize expected. : ',size);
          if OricFile.ofk=ofk_strings
          then writeln(' + string descriptors + strings')
          else writeln;
          writeln('Number of elements expected : ',numelements);
          //data
          if OricFile.ofq=ofq_missingdata then
          begin
            writeln('Datasize found.... : ',OricFile.EndData-OricFile.StartData+1,' bytes');
            writeln('File quality...... : bad. (missing data ! corrupted file ?)');
          end
          else begin
            writeln('File quality...... : good.');
            writeln('Expected size OK, taptap can handle this file');
            if (index<(length(Catalogue)-1)) then
              writeln('warning ! next file can be unreadable...');
          end;
        end;
      end;
    end;
    writeln;
  end;
end;
end.
