function Mooring = AddInstrumentToMooring( Mooring, NewInstr )
%function Mooring = AddInstrumentToMooring( Mooring, NewInstr )
%   adds NewInstr to Mooring and counts their number
%
%   Mooring:  original Mooring 
%   NewInstr: new instrument
% 
% see also mkMooring
%
% ZZ @ APL-UW, April 15th, 2010

%%% Comments with three leading % are annotations by B. Bloss, UW: May 2015
%% display
disp(['Calling function ' mfilename])


%% check NewInstr

%%%This checks if the second input argument exists
if ~exist( 'NewInstr', 'var' ), return; end


%% instrument name
%%% inputname is a builtin: this plucks the actual variable name you use
%%% for NewInstr. Be careful as that variable name (the string: eg
%%% 'ADCP_TOP') is used to figure out what the instrument type is.
Instrname = inputname(2);  
Instrname = upper( Instrname );


%% check which instrument it belongs to
%%% As warned above, this determines the instrument type from the string of
%%% the variable passed in as NewInstr. That is:
%%% Mooring=AddInstru...ToMooring(Mooring, ADCP_VAR_NAME) will use
%%% 'ADCP_VAR_NAME' as a string and search it for 'SBE','MP', and 'ADCP'
%%% plus any other intruments that might have been added.
%%% The InstrumentList is created in a separate function, previously.
checkList = zeros( size(Mooring.InstrumentList) );
for idx = 1 : length( Mooring.InstrumentList )
    Instrument = Mooring.InstrumentList{idx};
    IsInstrument = findstr( Instrname, Instrument);
    if ~isempty( IsInstrument ) 
       checkList(idx) = 1; 
    end
end
checkList = find( checkList == 1 );


%% it may belong to >1 instrument types: wroing!!
%%% An example of this would be passing in ...toMooring(Mooring, ADCP_SBE);
if length( checkList ) > 1
    for idx_check = 1 : length( checkList )
        idx = checkList(idx_check);
        disp(['   ' Instrname ' belongs to ' Mooring.InstrumentList{idx}])
    end
    disp(['   ' Instrname ' cannot belong to >=2 instrument types'])
    disp(['   Please change ' Instrname ' to its type name, and try'])
    error([' !! wrong !! '])
end


%% cannot find its instrument type,
% update Mooring.InstrumentList, and try again
%%% This snippet appears to append an unexpected intrument to the original instrument
%%% list and re-evaluates...
if length( checkList ) < 1
    disp(['   Updating Mooring.InstrumentList, and try again.'])
    disp(['   Or please change ' Instrname ' to its type name, and try'])
    Mooring.InstrumentList   = [Mooring.InstrumentList Instrname];
    Mooring.InstrumentNumber = [Mooring.InstrumentNumber 0]; 
    eval([Instrname '=NewInstr;'])
    eval(['Mooring = AddInstrumentToMooring( Mooring, ' Instrname ');']);
end


%% find its type, and add to mooring
if length( checkList ) == 1
    %%% This simply assigns the abbreviated instrument type to "Instrument"
    Instrument = Mooring.InstrumentList{checkList};
    disp(['   ' Instrname ' belongs to ' Instrument])

    %%  countnumber + 1
    %%%This counter is  a list used to keep track of how many of each
    %%%instrument are currently assigned, and thus this number is affixed
    %%%to the structure names (e.g. ADCP1 ADCP2 ADCP3) within the Mooring
    %%%structure.
    Mooring.InstrumentNumber(checkList) = Mooring.InstrumentNumber(checkList) + 1; 

    %% Add instrument to Mooring
    %%% Here the structure is actually named and pulled in. Note how no
    %%% modifications are made to the structure provided.
    num = Mooring.InstrumentNumber(checkList);
    Mooring.([Instrument num2str(num)]) = NewInstr;
    
    %% datanumber + 1
    %%% This is the total number of instruments
    Mooring.DataNumber = Mooring.DataNumber + 1;
    
    %% add to DataList
    %%% This adds the Whole Instrument (e.g. ADCP1) to the list of data
    %%% structures
    Mooring.DataList{Mooring.DataNumber} = [Instrument num2str(num)];
    
    %% display
    disp(['   ' Instrname ' is added to Mooring.'])
end
    
return