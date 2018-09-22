unit Unithelp;

interface
procedure help_command(command:string);

implementation

const
{$REGION 'helpstring'}
  helpstring:string='Syntax :'+#13#10+
  '========'+#13#10+
  'taptap [<command> [<parameter1> <parameter1> <parameter1> <parameter1>]]'+#13#10+
  'Syntax of commands is case insensitive.'+#13#10+
  'Please, separate parameters with spaces or tabs. Use double quotation'+#13#10+
  'marks to wrap multiple words as one parameter (such as long file names'+#13#10+
  'containing spaces).'+#13#10+
  ''+#13#10+
  'List of commands :'+#13#10+
  '------------------'+#13#10+
  'help [<command>] : Without the <command> parameter, displays this help screen. '+#13#10+
  '                   With the <command> parameter, displays extended help '+#13#10+
  '                   on the specified command.'+#13#10+
  '                   example : taptap help cat'+#13#10+
  '     '+#13#10+
  'cat ............ : Displays the catalog of tape.'+#13#10+
  'ren ............ : Renames an Oric file in a .tap File.'+#13#10+
  'copy............ : Copies one or all files from a .tap file to some separate .tap file(s).4'+#13#10+
  'extract......... : Extracts one or all files from a .tap file to some separate .tap file(s).4'+#13#10+
  'del............. : Deletes a file from a .tap file.'+#13#10+
  'split........... : Splits .tap file into separate files.'+#13#10+
  'join............ : Merge several .tap Files into one .tap file.'+#13#10+
  'AutoOn ......... : Sets Auto run On'+#13#10+
  'AutoOff ........ : Sets Auto run Off';
  //+#13#10+
  //'headless........ : Removes the header of a tap file (creates a .bin file)';

{$ENDREGION}
{$REGION 'catsring'}
  catstring:string=' *******'+#13#10+
  ' * cat *'+#13#10+
  ' *******'+#13#10+
  ''+#13#10+
  'Usage :'+#13#10+
  '-------'+#13#10+
  'Used to display the catalog of a .tap file'+#13#10+
  ''+#13#10+
  'Syntax :'+#13#10+
  '--------'+#13#10+
  'taptap cat <TapFile>'+#13#10+
  '    <TapFile>.... : Tap file to be processed - mandatory'+#13#10+
  '  '+#13#10+
  ''+#13#10+
  'Example : '+#13#10+
  '---------'+#13#10+
  '    taptap cat myfile.tap';
{$ENDREGION}
{$REGION 'renstring'}
  renstring:string=' *******'+#13#10+
    ' * ren *'+#13#10+
    ' *******'+#13#10+
    #13#10+
    'Usage :'+#13#10+
    '-------'+#13#10+
    'Used to rename an Oric file in a .tap File'+#13#10+
    '!!! The New oric file name cannot exceed 15 chars/bytes !!!'+#13#10+
    #13#10+
    'Syntax :'+#13#10+
    '--------'+#13#10+
    '  taptap.exe ren <FileIndex> [from] <TapFile> [to] <Newname> '+#13#10+
    #13#10+
    '    <FileIndex> : File index in Tap File, 0 is the 1st file,'+#13#10+
    '                  index 1 the 2nd, etc - Mandatory'+#13#10+
    '    [from]..... : Optional keyword'+#13#10+
    '    <TapFile>.. : Tap file to be processed - mandatory'+#13#10+
    '    [to]....... : Optional keyword (Mandatory if the new name is "TO" !)'+#13#10+
    '    <NewName>.. : New file name of the oric file to be processed -mandatory'+#13#10+
    '                  The New oric file name can be specified'+#13#10+
    '                  in different ways'+#13#10+
    '                  - as a string : ex: PINBALL'+#13#10+
    '                    if it contains a +, a #, or a space, the string must,'+#13#10+
    '                    be quoted : "say 1+2=3","Dev c++",...'+#13#10+
    '                    And for a double quote, repeat it twice'+#13#10+
    '                    in a quoted string : "say ""hello"""'+#13#10+
    '                   "say 1+2=3","Dev c++",...'+#13#10+
    '                  - as a succession of 8 bits hexadecimal'+#13#10+
    '                    values (2 digits each), without any space'+#13#10+
    '                    It then permits to have some text attributes'+#13#10+
    '                    into the oric title : ink or paper color, blink...'+#13#10+
    '                        (please refer to Oric manual for values).'+#13#10+
    '                    In that case, the string must be preceeded by'+#13#10+
    '                    the # symbol and the null hexadecimal value (INK 0)'+#13#10+
    '                    is forbidden ( and will be omitted if found).'+#13#10+
    '                    example : #0148656C6C6F07'+#13#10+
    '                    ...will print "Hello" in red on the status line'+#13#10+
    '                       while loading.'+#13#10+
    '                  - as a mix of both, separated by the + sign : '+#13#10+
    '                       #01+1+#02+2+#03+3...' +#13#10+
    '                  - and many more : see examples below'+#13#10+
    #13#10+
    '                    The new filename will be truncated to 15 bytes'+#13#10+
    '                    if its length excedd 15 bytes. null chars will'+#13#10+
    '                    be converted to a space character.'+#13#10+
    '		    (Note : The leading null character is automatically appended'+#13#10+
    '		    to the filename in the .tap file.) '+#13#10+
    #13#10+
    'Example : '+#13#10+
    '---------'+#13#10+
    '    taptap ren 0 from myfile.tap to Pinball'+#13#10+
    '    taptap ren 1 from myfile.tap to to'+#13#10+
    '    taptap ren 0 myfile.tap "Jurassic Space"'+#13#10+
    '    taptap ren 2 myfile.tap "say 1+2=3"'+#13#10+
    '    taptap ren 1 myfile.tap "Dev c++"'+#13#10+
    '    taptap ren 1 myfile.tap "say ""hello"""'+#13#10+
    '    taptap ren 3 myfile.tap "#hashtag" 1'+#13#10+
    '    taptap ren 1 myfile.tap "say ""hello"""'+#13#10+
    '    taptap ren 2 myfile.tap #0148656C6C6F07'+#13#10+
    '    taptap ren 2 myfile.tap #01+1+#02+2+#03+3...'+#13#10+
    '    taptap ren 0 myfile.tap #0515+Hello world+#0717'+#13#10+
    '    taptap ren 1 myfile.tap "#01+1+#02+2+#03+3... Happy"'+#13#10+
    '    taptap ren 1 myfile.tap "#030C+Yellow submarine"'+#13#10+
    'Specials studies :'+#13#10+
    '    taptap ren 1 myfile.tap """# ""+#04+""1+2=three #"'+#13#10+
    '    taptap ren 3 myfile.tap """# ""+#04+""1+1=""""10""""""+#07+"" #"""'+#13#10+
    '    Of course, there simpler ways to do it :'+#13#10+
    '    taptap ren 1 myfile.tap #353204+1+#43+2=three+#3235'+#13#10+
    '    taptap ren 3 myfile.tap #353204+1+#43+1=+#34+10+#34073235';
{$ENDREGION}
{$REGION 'autostring'}
  autostring:string=' ********************'+#13#10+
  ' * AutoOn / AutoOff *'+#13#10+
  ' ********************'+#13#10+
  #13#10+
  'Usage :'+#13#10+
  '-------'+#13#10+
  'Used to set Auto run On or Off of a program file.'+#13#10+
  'Usefull to prevent autoexecution of a Basic program'+#13#10+
  #13#10+
  'Syntax :'+#13#10+
  '--------'+#13#10+
  '   taptap AutoOn <FileIndex> [from] <TapFile> '+#13#10+
  'or'+#13#10+
  '   taptap AutoOff <FileIndex> [from] <TapFile>'+#13#10+
  #13#10+
  '    <TapFile>.. : Tap file to be processed - mandatory                '+#13#10+
  '    [from]..... : Optional keyword'+#13#10+
  '    <FileIndex> : File index in Tap File, 0 is the 1st file,'+#13#10+
  '                  index 1 the 2nd, etc - Mandatory'+#13#10+
  #13#10+
  'Examples : '+#13#10+
  '---------'+#13#10+
  '    taptap autooff 0 myfile.tap';
{$ENDREGION}
{$REGION 'copystring'}
  copystring:string=' ********'+#13#10+
  ' * Copy *'+#13#10+
  ' ********'+#13#10+
  #13#10+
  'Usage :'+#13#10+
  '-------'+#13#10+
  'Used to copy one or all files from a .tap'+#13#10+
  'to some separate .tap file(s).'+#13#10+
  'created .tap files are automatically named.'+#13#10+
  ''+#13#10+
  'Syntax :'+#13#10+
  '--------'+#13#10+
  '   taptap copy <FileIndex> [from] <TapFile> [[to] <directory>] '+#13#10+
  #13#10+
  #13#10+
  '    <FileIndex> : File index in Tap File, 0 is the 1st file,'+#13#10+
  '                  index 1 the 2nd, etc - Mandatory'+#13#10+
  '   		           If instead of a number you provide ALL as a parameter'+#13#10+
  '	                 all files will be copied to separate .tap files'+#13#10+
  '		  '+#13#10+
  '    [from]..... : Optional keyword'+#13#10+
  '    <TapFile>.. : Tap file to be processed - mandatory '+#13#10+
  '    [to]....... : Optional keyword '+#13#10+
  '    <directory> : if specified, extracted files will be located there.'+#13#10+
  '		  Otherelse, they will be extracted in the currentdir.'+#13#10+
  #13#10+
  'Examples : '+#13#10+
  '----------'+#13#10+
  '    taptap copy all from tyrann.tap to "c:\OSDK\myprog"'+#13#10+
  '    taptap copy 1 mygame.tap';

{$ENDREGION}
{$REGION 'extractstring'}
  extractstring:string=' ***********'+#13#10+
    ' * Extract *'+#13#10+
    ' ***********'+#13#10+
    #13#10+
    'Usage :'+#13#10+
    '-------'+#13#10+
    'Used to extract one or all files from a .tap'+#13#10+
    'to some separate .tap file(s).'+#13#10+
    'Removes the indicated file from source .tap file.'+#13#10+
    'If the source .tap file is empty after extraction, it is not deleted.'+#13#10+
    'Created .tap files are automatically named :'+#13#10+
    '  BE VERY CAREFULL TO SUCCESSIVE "EXTRACT" from the same .tap file,'+#13#10+
    '  you could overwrite the previous extracted file !'+#13#10+
    #13#10+
    'Syntax :'+#13#10+
    '--------'+#13#10+
    '   taptap extract <FileIndex> [from] <TapFile> [[to] <directory>] '+#13#10+
    #13#10+
    '                   '+#13#10+
    '    <FileIndex> : File index in Tap File, 0 is the 1st file,'+#13#10+
    '                  index 1 the 2nd, etc - Mandatory'+#13#10+
    '   		           If instead of a number you provide ALL as a parameter'+#13#10+
    '	                 all files will be copied to separate .tap files'+#13#10+
    '		  '+#13#10+
    '    [from]..... : Optional keyword'+#13#10+
    '    <TapFile>.. : Tap file to be processed - mandatory '+#13#10+
    '    [to]....... : Optional keyword '+#13#10+
    '    <directory> : if specified, extracted files will be located there.'+#13#10+
    '		  Otherelse, they will be extracted in the currentdir.'+#13#10+
    #13#10+
    'Examples : '+#13#10+
    '----------'+#13#10+
    '    taptap extract 2 from tyrann.tap to "c:\OSDK\myprog"'+#13#10+
    '    taptap extract 1 mygame.tap';
{$ENDREGION}
{$REGION 'splitstring'}
  splitstring:string=' *********'+#13#10+
  ' * split *'+#13#10+
  ' *********'+#13#10+
  #13#10+
  'Usage :'+#13#10+
  '-------'+#13#10+
  'Used to split a .tap File into 1 .tap for each oric file it contains.'+#13#10+
  'Deletes the source file.'+#13#10+
  #13#10+
  'Syntax :'+#13#10+
  '--------'+#13#10+
  '  taptap.exe split <TapFile> [[to] <directory>]  '+#13#10+
  #13#10+
  '    <TapFile>.. : Tap file to be processed - mandatory '+#13#10+
  '    [from]..... : Optional keyword'+#13#10+
  '    <FileIndex> : File index in Tap File, 0 is the 1st file,'+#13#10+
  '                  index 1 the 2nd, etc - Mandatory'+#13#10+
  '    [to]....... : Optional keyword '+#13#10+
  '    <directory> : if specified, extracted files will be located there.'+#13#10+
  '		  Otherelse, they will be extracted in the currentdir.'+#13#10+
  #13#10+
  'Example : '+#13#10+
  '---------'+#13#10+
  '    taptap split myfile.tap'+#13#10+
  '    taptap split myfile.tap to .\sub';
{$ENDREGION}
{$REGION 'delstring'}
  delstring:string=' *******'+#13#10+
  ' * del *'+#13#10+
  ' *******'+#13#10+
  #13#10+
  'Usage :'+#13#10+
  '-------'+#13#10+
  'Used to delete an Oric file in a .tap File'+#13#10+
  #13#10+
  'Syntax :'+#13#10+
  '--------'+#13#10+
  '  taptap.exe del <FileIndex> [from] <TapFile> <Newname> '+#13#10+
  #13#10+
  '    <TapFile>.. : Tap file to be processed - mandatory '+#13#10+
  '    [from]..... : Optional keyword'+#13#10+
  '    <FileIndex> : File index in Tap File, 0 is the 1st file,'+#13#10+
  '                  index 1 the 2nd, etc - Mandatory'+#13#10+
  #13#10+
  'Example : '+#13#10+
  '---------'+#13#10+
  '    taptap del 3 myfile.tap'+#13#10+
  '    taptap del 1 from myfile.tap';
{$ENDREGION}
{$REGION 'joinstring'}
  joinstring:string=' ********'+#13#10+
  ' * join *'+#13#10+
  ' ********'+#13#10+
  #13#10+
  'Usage :'+#13#10+
  '-------'+#13#10+
  'Used to merge several .tap Files into one .tap file.'+#13#10+
  'Destination dir is automatycally created if it does not exist.'+#13#10+
  ''+#13#10+
  'Syntax :'+#13#10+
  '--------'+#13#10+
  '  taptap.exe join <TapFile 1>+<TapFile 2>+..+<TapFile n>  <TapfileDest>  '+#13#10+
  #13#10+
  '    <TapFile n> : Tap files to be merged - mandatory '+#13#10+
  '    <TapfileDest> : File index in Tap File, 0 is the 1st file,'+#13#10+
  '                  index 1 the 2nd, etc - Mandatory'+#13#10+
  #13#10+
  'Example : '+#13#10+
  '---------'+#13#10+
  '    taptap join a.tab+"c:\a directory path\b.tap"+c.tap 3 myfile.tap'+#13#10+
  '    taptap join myfile.tap+appended.tap myfile.tap'+#13#10+
  '    taptap join inserted.tap+myfile.tap myfile.tap';

{$ENDREGION}
headless:string='';

procedure help_command(command:string);
begin
  if ((command='') or (command='HELP'))
  then writeln(helpstring)
  else if command='CAT'
  then writeln(catstring)
  else if command='REN'
  then writeln(renstring)
  else if ((command='AUTOON') or (command='AUTOOFF'))
  then writeln(autostring)
  else if command='COPY'
  then writeln(copystring)
  else if command='EXTRACT'
  then writeln(extractstring)
  else if command='DEL'
  then writeln(delstring)
  else if command='SPLIT'
  then writeln(splitstring)
  else if command='JOIN'
  then writeln(joinstring);
end;

end.
