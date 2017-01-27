function dataout = extraDataEditting(datain, datatype)
% dataout = EXTRADATAEDITTING(datain, datatype)
%
%   inputs:
%       - datain: data structure.
%       - datatype: type of instrument, as defined by the script with
%                   info for all instruments on the mooring.
%
%   outputs:
%       - dataout: data structure with additional editting/processing.
%
% Function EXTRADATAEDITTING does some minor editting such as
% transposing and renaming variables, removing NaNs and
% Estimating depth from pressure.
%
% Olavo Badaro Marques.


%% Load the data:

switch instrtype

    case 'SBE37'

        SBE_S37=load('./T7_Mooring_Data/SBE37/3638/SBE37_SN3638.mat');
        SBE_S37=SBE_S37.dat;
        SBE_S37.yday=datenum2yday(SBE_S37.time(:));
        SBE_S37.t=SBE_S37.T;
        %SBE_S37.s= some function of SBE_S37.C;
        SBE_S37.z=SBE_S37.P; %I'm making an assumption here for shallow depth
        SBE_S37.z=z_1m_perturb(86,:)+86;
        SBE_S37.z=interp1(datenum2yday(time_2min),SBE_S37.z,SBE_S37.yday);
                  
    case 'SBE39'
        SBE_S39_3253.z=z_1m_perturb(1103,:)+1103;
        SBE_S39_3253.t=SBE_S39_3253.temp';
        SBE_S39_3253.yday=SBE_S39_3253.yday';
        
	case 'SBE56'

        SBE_S56=SBE_S56.dat;
        SBE_S56.yday=datenum2yday(SBE_S56.time(:));
        SBE_S56.t=SBE_S56.T;
        SBE_S56.z=z_1m_perturb(50,:)+50;
        SBE_S56.z=interp1(datenum2yday(time_2min),SBE_S56.z,SBE_S56.yday);
                                         
    case 'RBRSolo'

        
    
    case 'RBRConcerto'

     

    case 'RDIadcp'

      
        
    case 'MP'
        
        
    otherwise
        
        warning(['Data of type ' instrtype ' has not been implemented' ...
                 ' ' mfilename '. Add a new case block in this function.'])

end