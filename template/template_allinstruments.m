%% Template of all instruments script
% Example for mooring T4, TTIDE-2015.
%
% This script creates a structure variable that is used by the
% gridMooringData toolbox.
%
% Each structure field is a list of { Serial Number (SN) , Nominal Depth }
% of all instruments deployed of a certain type in that mooring (e.g.
% SBE56). For each field, SNs are sorted from the top to the bottom of the
% mooring -- this is not a requirement, but it is good practice. If
% for whatever reason you DO NOT want to include data from one
% instrument (e.g. because the instrument did not work), comment the
% correspondent line.
%
% Note that the Serial Numbers are specified as strings (that is why each
% field is a cell array). This makes sense because they are IDs rather
% than numbers which will go into math calculations. More importantly,
% there are a few instruments (such as some McLane Profilers) that have
% SN number with letters.
%
% Check the function loadMooringData.m to see all the possible instrument
% types supported by the toolbox, as well as what variable names the code
% uses to reference them.
%
% Nominal depths in a script like this usually come from the mooring
% diagram. The nominal depths are ESSENTIAL for the instruments that
% do NOT record pressure and are later used for processing the mooring
% data. If data comes from a profiling platform, insert NaN as the nominal
% depth.
%
% If there are lots of instruments of one type, I suggest skipping some
% lines with a comment. This improves readability.
%
% OBM, Feb/2017.


%% RBR Solo (Temp. only)

T4sensors.RBRSolo = {'76598', 172 ; ...
                     '72130', 187 ; ...
                     '72112', 202 ; ...
                     '72113', 222 ; ...
                     '72114', 242 ; ...
                     '72115', 262 ; ...
                     '72116', 282 ; ...
%         
%                      '72117', 322 ; ...
%                      '72118', 342 ; ...
%                      '72119', 362 ; ...
                     '72120', 382 ; ...
                     '72147', 392 ; ...
%
                     '72121', 404 ; ...
                     '72122', 413 ; ...
                     '72135', 423 ; ...
                     '72136', 433 ; ...
                     '72137', 443 ; ...
%
                     '72138', 454 ; ...
%
                     '76286', 462 };
       
           
%% RBR Concerto (CTD):

T4sensors.RBRConcerto = {'60165',  77 ; ...
                         '60183', 157 ; ...
                         '60094', 302 }; % mooring diagram has 60194 instead.
                                         % I'm assuming the diagram is wrong
                                         % and the data file name is correct.
       
%% SBE 56 (Temp. only):

T4sensors.SBE56 = {'1556', 43
                   '1653', 57  ; ...
                   '1654', 67  ; ...
                    '561', 87  ; ...
                    '563', 97  ; ...
                    '565', 112 ; ...
                    '573', 127 ; ...
                    '581', 142 };
          
%% SBE 37 (CTD):

T4sensors.SBE37 = {... % '4922',  45 ; ...% this instrument likely has a bias
                                          % in the conductivity measurements
                    '8724', 402 };
                   %'2533', 453 }; % when loading this data, the serial
                                     % number that is in the data structure
                                     % is 8722. In addition, temperature
                                     % looks alright, but density is weird.
                                     % so conductivity may have a bias.

%% RDI ADCP:

T4sensors.RDIadcp = {'15339', 42 ; ...
                      '9408', 43 };
         