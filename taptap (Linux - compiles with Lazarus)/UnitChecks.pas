unit UnitChecks;

interface
uses Unitutils;
const
     FI_ERROR=-1;
     FI_ALL=-2;
function check_1(Fileindex:integer;TapName:string;Catalogue:TCatalog):boolean;

implementation
uses sysutils;

function check_1(Fileindex:integer;TapName:string;Catalogue:TCatalog):boolean;
begin
   result:=false;
   if length(Catalogue)=0
      then begin
             writeln('Impossible :');
             writeln(extractfilename(TapName),' is an empty file.');
             writeln('Check your file.');
      end
      else if (not (Fileindex<length(Catalogue)))
      then begin
             writeln('Impossible :');
             writeln('The <FileIndex> is greater than the number of file !');
             writeln('Check your file structure with the "cat" command.');
      end
      else if (Fileindex=FI_ERROR)
      then begin
             writeln('Impossible :');
             writeln('The <FileIndex> is not valid and must be a valid integer');
             writeln('Check your syntax.');
      end
      else
      begin
        result:=true;
        if (Fileindex<>FI_ALL)
        then if (Catalogue[FileIndex].ofk=ofk_junk)
        then begin
               writeln('Impossible :');
               writeln('This Oric file is a junk file or of unknown kind');
               writeln('Check your file structure with the "cat" command.');
               result:=false;
        end;
      end;
end;

end.
