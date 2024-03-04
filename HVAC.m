%% HVAC.m
% ***********************************************************************
% This file is part of the uibkCARNOT Blockset.
%
% Copyright (c) 2016-2019, University of Innsbruck, Unit for Energy 
% Efficient Building.
%   Dietmar Siegele     dietmar.siegele@uibk.ac.at
%   Eleonora Leonardi   eleonora.leonardi@uibk.ac.at
% Additional Copyright for this file see list auf authors.
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
%    this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright 
%    notice, this list of conditions and the following disclaimer in the 
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
%    contributors may be used to endorse or promote products derived from 
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
% THE POSSIBILITY OF SUCH DAMAGE.
% **********************************************************************
% 
%% carnotUIBK version 2.0
% Copyright (c) 2016-2019, University of Innsbruck, Unit for Energy 
% Efficient Building.
%
% Author    Date         Description
% DS,EL     2017-03-12   initial revision v1.0
% DS,EL	    2019-01-24   updates for GUI v2.0

%%
classdef HVAC
    % HVAC
    
    properties
        name = 'new HVAC';
        system = [];
    end
    
    methods
        function obj = HVAC()
            
        end
        
        function obj = add_system(obj, name, number, parameter)
            % to add a system with his parameter
            % 1 ... name of the system (for the user)
            % 2 ... number of the system, according to the SIMULINK model
            % 3 ... parameter. ... all the parameters needed in Simulink
            
            ind = [];
            for jj = 1:length(obj.system)
                if strcmp(obj.system(jj).number, number)
                    ind = strcmp(obj.structure(jj).number, number);
                    break
                end
            end
            
            if ind
                error(['system number' number ' already existing!'])
            else
                if isstr(parameter)
                    try
                        obj.system = [obj.system SYSTEM_HVAC(name, number, parameter)];
                    catch
                        try
                            obj.system = [obj.system SYSTEM_HVAC(name, number, parameter, 1)];
                        catch
                            error('Import was not possbile!')
                        end
                    end
                else
                    try
                        obj.system = [obj.system SYSTEM_HVAC(name, number, parameter, 1)];
                    catch
                        try
                            obj.system = [obj.system SYSTEM_HVAC(name, number, parameter)];
                        catch
                            error('Import was not possbile!')
                        end
                    end
                end
            end
            
        end
        
        function obj = add_system_from_PHPP(obj, name, number, name_xls_PHPP, language, version, choice_heatload)
            % to take the parameters from the PHPP (use only with the block HVAC PHPP in Simulink!!!)
            % 1 ... name of the system (for the user)
            % 2 ... number of the system, according to the SIMULINK model
            % 3 ... name of the file xls of the PHPP
            % 4 ... language: 1:german, 0:english
            % 5 ... version of PHPP used
            % 6 ... if you want to consider the heatload "limited" to the
            % heatload of the PHPP or "unlimited"
            
            ind = [];
            for jj = 1:length(obj.system)
                if strcmp(obj.system(jj).number, number)
                    ind = strcmp(obj.structure(jj).number, number);
                    break
                end
            end
            
            if ind
                error(['system number' number ' already existing!'])
            else
                
                filename = name_xls_PHPP;
                vollpfad = [pwd '\' name_xls_PHPP];
            
                    if exist(vollpfad, 'file')
                        warning('Existing Excel file used.')
                    else
                        warning('PHPP does not exist')
                    end

                Excel = actxserver('Excel.Application');
                Excel.Workbooks.Open(vollpfad);
                warning('Excel file opened! Do not interrupt this script!')

                switch version
                    case '9.1'
                        if language
                            sheet = 'Nachweis';
                        else
                            sheet = 'Verification';
                        end
                        range = 'K27:N29';
                        [~, ~, data] = xlsread1(filename, sheet, range);
                        index_raw_setpointwin = 1;
                        index_column_setpointwin = 1;
                        index_raw_setpointsum = 1;
                        index_column_setpointsum = 4;
                        index_raw_mechcool = 3;
                        index_column_mechcool = 4;
                        index_raw_intgainssum = 2;
                        index_column_intgainssum = 4;
                        index_raw_intgainswin = 2;
                        index_column_intgainswin = 1;
                        
                        if language
                            sheet = 'Lüftung';
                        else
                            sheet = 'Ventilation';
                        end
                        range = 'N27:P97';
                        [~, ~, data1] = xlsread1(filename, sheet, range);
                        index_raw_vdot = 50;
                        index_column_vdot = 3;
                        index_raw_eta = 71;
                        index_column_eta = 1;
                        
                        if language
                            sheet = 'Heizlast';
                        else
                            sheet = 'Heating load';
                        end
                        range = 'Q90';
                        [~, ~, data2] = xlsread1(filename, sheet, range);
                        data2 = {data2}; %from matlab 2023b if we import only one cell this is a structure and not a cell

                        if language
                            sheet = 'SommLuft';
                        else
                            sheet = 'SummVent';
                        end
                        range = 'L20:R63';
                        [~, ~, data3] = xlsread1(filename, sheet, range);
                        [~, ~, Vol_vent] = xlsread1(filename, sheet, 'L7'); %to be improved (include this in data3 and change the indexes)
                        index_raw_rate_s = 1;
                        index_column_rate_s = 1;
                        index_raw_vdot_s = 26;
                        index_column_vdot_s = 1;
                        index_raw_dec_no = 2:4;
                        index_raw_dec_yes = 5;
                        index_column_dec = 7;
                        index_raw_add_1 = 40;
                        index_raw_add_2 = 42;
                        index_column_add = 5;
                        if language
                            sheet = 'Kühllast';
                        else
                            sheet = 'Cooling load';
                        end
                        range = 'Q62';
                        [~, ~, data4] = xlsread1(filename, sheet, range);
                        data4 = {data4}; %from matlab 2023b if we import only one cell this is a structure and not a cell

                        
                    case '10.2'
                        if language
                            sheet = 'Nachweis';
                        else
                            sheet = 'Verification';
                        end
                        range = 'K28:N30';
                        [~, ~, data] = xlsread1(filename, sheet, range);
                        index_raw_setpointwin = 1;
                        index_column_setpointwin = 1;
                        index_raw_setpointsum = 1;
                        index_column_setpointsum = 4;
                        index_raw_mechcool = 3;
                        index_column_mechcool = 4;
                        index_raw_intgainssum = 2;
                        index_column_intgainssum = 4;
                        index_raw_intgainswin = 2;
                        index_column_intgainswin = 1;
                        
                        if language
                            sheet = 'Lüftung';
                        else
                            sheet = 'Ventilation';
                        end
                        range = 'N23:P100';
                        [~, ~, data1] = xlsread1(filename, sheet, range);
                        index_raw_vdot = 57;
                        index_column_vdot = 3;
                        index_raw_eta = 78;
                        index_column_eta = 1;
                        
                        if language
                            sheet = 'Heizlast';
                        else
                            sheet = 'Heating load';
                        end
                        range = 'Q90';
                        [~, ~, data2] = xlsread1(filename, sheet, range);
                        
                        if language
                            sheet = 'SommLuft';
                        else
                            sheet = 'SummVent';
                        end
                        range = 'L14:R57';
                        [~, ~, data3] = xlsread1(filename, sheet, range);
                        [~, ~, Vol_vent] = xlsread1(filename, sheet, 'L7'); %to be improved (include this in data3 and change the indexes)
                        index_raw_rate_s = 1;
                        index_column_rate_s = 1;
                        index_raw_vdot_s = 26;
                        index_column_vdot_s = 1;
                        index_raw_dec_no = 2:4;
                        index_raw_dec_yes = 5;
                        index_column_dec = 7;
                        index_raw_add_1 = 40;
                        index_raw_add_2 = 42;
                        index_column_add = 4;
                        if language
                            sheet = 'Kühllast';
                        else
                            sheet = 'Cooling load';
                        end
                        range = 'Q66'; 
                        [~, ~, data4] = xlsread1(filename, sheet, range);
                end
                
            Excel.Quit
            Excel.delete
            clear Excel
            warning('Excel file closed!')

            parameter.setpointwin = data{index_raw_setpointwin, index_column_setpointwin};
            parameter.setpointsum = data{index_raw_setpointsum, index_column_setpointsum};
            parameter.mechcool = data{index_raw_mechcool, index_column_mechcool};
            parameter.valves.Kp = 2.1591;
%             parameter.valves.Kp = 2.1591/2;
            parameter.valves.Tn = 418.6787;
            parameter.valves.valve_up = 1;
            parameter.valves.valve_low = 0;

            if iscell(data2(1,1))
                HL = data2{1,1};
            else
                HL = data2(1,1);
            end

            if iscell(data4(1,1))
                CL = data4{1,1};
            else
                CL = data4(1,1);
            end


            if strcmp(choice_heatload, 'limited')
                parameter.heatload = HL;
                parameter.coolload = CL;
            elseif strcmp(choice_heatload, 'unlimited')
                parameter.heatload = 2*HL;
                parameter.coolload = 2*CL;
            end

            if isnan(parameter.mechcool)
                parameter.mechcool = 0;
            else
                parameter.mechcool = 1;
            end
            
            data3(cellfun(@isempty,data3)) = {NaN};

            vdot_w = data1{index_raw_vdot, index_column_vdot};
            vdot_s = data3{index_raw_rate_s, index_column_rate_s}*data3{index_raw_vdot_s, index_column_vdot_s};
            
            hr_1 = data3{index_raw_dec_no(1), index_column_dec};
            hr_2 = data3{index_raw_dec_no(2), index_column_dec};
            hr_3 = data3{index_raw_dec_no(3), index_column_dec};
            hr_4 = data3{index_raw_dec_yes, index_column_dec};
            if ~isnan(hr_1) || ~isnan(hr_2) || ~isnan(hr_3) || (isnan(hr_1) & isnan(hr_2) & isnan(hr_3) & isnan(hr_4))
                eta_s = 0;
            elseif ~isnan(hr_4)
                eta_s = data1{index_raw_eta, index_column_eta};
            end
            eta_w = data1{index_raw_eta, index_column_eta};

            parameter.vdot_winsom.time = [0 151 243 365]*3600*24;
            parameter.vdot_winsom.duration = diff(parameter.vdot_winsom.time);
            parameter.vdot_winsom.value = [vdot_w vdot_s vdot_w];
            parameter.eta.time = [0 151 243 365]*3600*24;
            parameter.eta.duration = diff(parameter.eta.time);
            parameter.eta.value = [eta_w eta_s eta_w];

            gains_add_sum = data{index_raw_intgainssum, index_column_intgainssum} - data{index_raw_intgainswin, index_column_intgainswin};
            parameter.gainsum.time =  [0 151 243 365]*3600*24;
            parameter.gainsum.duration = diff(parameter.gainsum.time);
            parameter.gainsum.value = [0 gains_add_sum 0];

            parameter.night_vent_s.time = [0 6 22 24]*3600;
            parameter.night_vent_s.duration = diff(parameter.night_vent_s.time);
            add_1 = data3{index_raw_add_1, index_column_add};
            add_2 = data3{index_raw_add_2, index_column_add};
            if isnan(add_1)
                add_1 = 0;
            end
            if isnan(add_2)
                add_2 = 0;
            end
            add = add_1 + add_2;
            parameter.night_vent_s.value = [add 0 add]*Vol_vent;
            obj.system = [obj.system SYSTEM_HVAC(name, number, parameter, 1)];
            end
        end
        
        function system = get_system(obj, number)
            % The output is the system number "number" with all his properties
            % 1 ... number of the system
            ind = [];
            for jj = 1:length(obj.system)
                if obj.system(jj).number == number
                    ind = jj;
                    break
                end
            end
            
            %check if system is not existing
            if ind
                system = obj.system(ind);
            else
                system = SYSTEM_HVAC();
                system.name = 'not defined';
                system.number = number;
                system.parameter = [];
                warning(['system number' num2str(number) ' not existing!'])
            end
        end
        
    end
end

