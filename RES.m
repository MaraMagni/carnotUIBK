%% RES.m
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
classdef RES
    % RES
    % analysis of the results
    %
    % funcion save(name, number_result): to save the result number 
    %       "number_result" under the name "name", it sets the units and 
    %       the dates to plot time series
    %
    % function info(number_result, build): % obtain information about the result 
    %       number "number_result" (list of the zones with characteristics,
    %       summary of the energy balance)
    %
    % function plot(number_result, build): % obtain all the general plots of the 
    %       result number "number_result"
    %
    % function [temperature_s temperature_r temperature_c humidity CO2] = 
    %        plot_zones_thC(number_result, build, choice_abs_rel_hum, 
    %        choice_ppm, plot_extra)
    %        plot the temperatures of the result number "number_result", the
    %        humidity "choice_abs_rel_hum" ('rel' or 'abs') and the CO2
    %        level ('ppm' or 'abs') and save the result in 
    %        "temperature_s" "temperature_r" "temperature_c" "humidity"
    %        "CO2", it can be set also only the number_result and te
    %        building object
    %
    % function [heating_demand cooling_demand] = energy_demand(number_result, build)
    %       plot and display the heating and cooling domand for every zone
    %       and for every month
    %
    % function [En Pow area] = different_monthly_energies(number_result, build) 
    %       plot the balances of the losses and the gains for the result 
    %       number "number_result"
    %
    % function plot_heat_temp_hours(number_result, build) plots the heat load
    %       sorted by ambient temperature and by hours for the result 
    %       number "number_result"
    %
    % function plot_temp_amb_buil_soil(number_result, build) plots the ambient 
    %       temperature, a mean temperature of the building and the 
    %       tempeature of the ground for the result number
    %       "number_result"
    %
    % function plot_temperature_arranged_hours(number_result, build) plots the
    %       temperature arranged by the hours for the result number
    %       "number_result"
    %
    % function plot_monthly_losses_gains(number_result, build) plots the monthly 
    %       losses and gains for every zone for the result number
    %       "number_result"
    %
    % function plot_heat_cool_power(number_result, build) plots the heating and
    %       cooling power in the year
    %
    % function compare_with_PHPP(number_result, build, name_xls_PHPP, language,
    %       version) to show the comparison between the PHPP 
    %       ("name_xls_PHPP") and the simulation for the result 
    %       "number_result"
    
    properties
        number = 0;
        building_saved = [];
        results_AIB = [];
        results_BDB = [];
        results_BOUNDARY = [];
        results_HVAC = [];
        date_of_sim = '';
        description = '';
        time_sim = 0;
        list_zones = [];            %list of the zones (number) that are present in the model
        PHPP = [];
        EXCEL = [];
        variant_geometry = 1;
        variant_construction = 1;
        variant_thermalzone = 1;
        variant_boundary = 1;
        variant_gains = 1;
        variant_hvac = 1;
    end
    
    methods
        function obj = RES(number, building_saved, results_AIB, results_BDB, results_BOUNDARY, results_HVAC, date_of_sim, time_sim, description, PHPP, EXCEL, variant_geometry, variant_construction, variant_thermalzone, variant_boundary, variant_gains, variant_hvac)
            if nargin == 0
            else
                obj.number = number;
                obj.building_saved = building_saved;
                obj.results_AIB = results_AIB;
                obj.results_BDB = results_BDB;
                obj.results_BOUNDARY = results_BOUNDARY;
                obj.results_HVAC = results_HVAC;
                obj.date_of_sim = date_of_sim;
                obj.time_sim = time_sim;
                obj.description = description;
                obj.PHPP = PHPP;
                obj.EXCEL = EXCEL;
                obj.variant_geometry = variant_geometry;
                obj.variant_construction = variant_construction;
                obj.variant_thermalzone = variant_thermalzone;
                obj.variant_boundary = variant_boundary;
                obj.variant_gains = variant_gains;
                obj.variant_hvac = variant_hvac;
            end
        end
        
        function obj = save(obj, name, number_result)
            % to save the result number "number_result" under the name
            % "name", it sets the units and the dates to plot time series
            % 1 ... name: name of the result (for the user), can be set
            %               with the date and hour
            % 2 ... number_result :number of the result
            ind = [];
            for ii = 1:length(obj)
                if obj(1,ii).number == number_result
                    ind = ii;
                    break
                end
            end
            if ind
                list_zones = [];
                for jj = 1:size(obj(1,number_result).building_saved.thermalzone.zone,2)
                    if (length(obj(1,number_result).building_saved.thermalzone.zone(1,jj).name)>4 && strcmp (obj(1,number_result).building_saved.thermalzone.zone(1,jj).name(1:5), 'EMPTY'))
                    else 
                        list_zones = [list_zones jj];
                    end
                end
                obj(1,number_result).list_zones = list_zones;
                for jj = 1:length(obj(1,number_result).list_zones)
                    for ll = 1:10
                        if obj(1,number_result).list_zones(jj) == ll
                            AIB(ll) = eval(['obj(1,' num2str(number_result) ').results_AIB.z' num2str(ll)]);
                            BDB_power(ll) = eval(['obj(1,' num2str(number_result) ').results_BDB.power.z' num2str(ll)]);
                            BDB_energy(ll) = eval(['obj(1,' num2str(number_result) ').results_BDB.energy.z' num2str(ll)]);
                        end
                    end
                    AIB(obj(1,number_result).list_zones(jj)).Ts.DataInfo.Units = '°C';
                    AIB(obj(1,number_result).list_zones(jj)).Tc.DataInfo.Units = '°C';
                    AIB(obj(1,number_result).list_zones(jj)).Tr.DataInfo.Units = '°C';
                    AIB(obj(1,number_result).list_zones(jj)).x_H2O.DataInfo.Units = 'kgw/kga';
                    AIB(obj(1,number_result).list_zones(jj)).x_CO2.DataInfo.Units = 'kgCO2/kga';
                    AIB(obj(1,number_result).list_zones(jj)).x_VOC.DataInfo.Units = 'kgVOC/kga';
                    AIB(obj(1,number_result).list_zones(jj)).rho.DataInfo.Units = 'kg/m³';
                    AIB(obj(1,number_result).list_zones(jj)).cp.DataInfo.Units = 'J/(kg*K)';
                    AIB(obj(1,number_result).list_zones(jj)).p.DataInfo.Units = 'Pa';

                    AIB(obj(1,number_result).list_zones(jj)).Ts.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).Tc.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).Tr.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).x_H2O.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).x_CO2.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).x_VOC.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).rho.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).cp.TimeInfo.StartDate = '01-01-2014';
                    AIB(obj(1,number_result).list_zones(jj)).p.TimeInfo.StartDate = '01-01-2014';

                    AIB(obj(1,number_result).list_zones(jj)).Ts.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).Tc.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).Tr.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).x_H2O.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).x_CO2.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).x_VOC.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).rho.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).cp.TimeInfo.Format = 'dd-mmm HH:MM';
                    AIB(obj(1,number_result).list_zones(jj)).p.TimeInfo.Format = 'dd-mmm HH:MM';

                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_opaque.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_ground.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_neighbour.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_window.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_mech.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_window.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_infiltration.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_S.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_person.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_light.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_electricity.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_H.DataInfo.Units = 'W';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_C.DataInfo.Units = 'W';

                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_opaque.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_ground.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_neighbour.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_window.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_mech.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_window.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_infiltration.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_S.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_person.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_light.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_electricity.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_H.TimeInfo.StartDate = '01-01-2014';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_C.TimeInfo.StartDate = '01-01-2014';

                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_opaque.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_ground.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_neighbour.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_T_window.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_mech.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_window.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_V_infiltration.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_S.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_person.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_light.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_I_electricity.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_H.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_power(obj(1,number_result).list_zones(jj)).Qdot_C.TimeInfo.Format = 'dd-mmm HH:MM';

                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_opaque_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_ground_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_neighbour_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_window_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_mech_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_window_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_infiltration_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_S_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_person_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_light_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_electricity_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_H_energy.DataInfo.Units = 'kWh';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_C_energy.DataInfo.Units = 'kWh';

                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_opaque_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_ground_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_neighbour_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_window_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_mech_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_window_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_infiltration_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_S_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_person_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_light_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_electricity_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_H_energy.TimeInfo.StartDate = '01-01-2014';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_C_energy.TimeInfo.StartDate = '01-01-2014';

                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_opaque_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_ground_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_neighbour_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_T_window_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_mech_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_window_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_V_infiltration_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_S_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_person_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_light_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_I_electricity_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_H_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    BDB_energy(obj(1,number_result).list_zones(jj)).Qdot_C_energy.TimeInfo.Format = 'dd-mmm HH:MM';
                    for ll = 1:10
                        if obj(1,number_result).list_zones(jj) == ll
                            eval(['obj(1,' num2str(number_result) ').results_AIB.z' num2str(ll) '= AIB(' num2str(ll) ');']);
                            eval(['obj(1,' num2str(number_result) ').results_BDB.power.z' num2str(ll) ' = BDB_power(' num2str(ll) ');']);
                            eval(['obj(1,' num2str(number_result) ').results_BDB.energy.z' num2str(ll) ' = BDB_energy(' num2str(ll) ');']);
                        end
                    end
                end
                obj(1,number_result).results_BOUNDARY.power.WDB.TimeValueComment.DataInfo.Units = 's';
                obj(1,number_result).results_BOUNDARY.power.WDB.Zenith_Angle.DataInfo.Units = '°';
                obj(1,number_result).results_BOUNDARY.power.WDB.Azimuth_Angle.DataInfo.Units = '°';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_beam_normal.DataInfo.Units = 'W/m²';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_diffuse_horizontal.DataInfo.Units = 'W/m²';
                obj(1,number_result).results_BOUNDARY.power.WDB.Temperature_Ambient.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.WDB.Temperature_Sky_Radiation.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.WDB.Relative_Humidity.DataInfo.Units = '%';
                obj(1,number_result).results_BOUNDARY.power.WDB.Precipitation.DataInfo.Units = 'm/s';
                obj(1,number_result).results_BOUNDARY.power.WDB.Cloud_Index.DataInfo.Units = '-'; % 0=no cloud, 1=covered sky
                obj(1,number_result).results_BOUNDARY.power.WDB.Station_Pressure.DataInfo.Units = 'Pa';
                obj(1,number_result).results_BOUNDARY.power.WDB.Wind_Speed.DataInfo.Units = 'm/s';
                obj(1,number_result).results_BOUNDARY.power.WDB.Wind_Direction.DataInfo.Units = '°';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_sun.DataInfo.Units = '°';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_longitudinal.DataInfo.Units = '°';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_transversal.DataInfo.Units = '°';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_direct_surface.DataInfo.Units = 'W/m²';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_diffuse_surface.DataInfo.Units = 'W/m²';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_1.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_2.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_3.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_4.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_5.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_6.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_1.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_2.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_3.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_4.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_5.DataInfo.Units = '°C';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_6.DataInfo.Units = '°C';

                obj(1,number_result).results_BOUNDARY.power.WDB.TimeValueComment.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Zenith_Angle.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Azimuth_Angle.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_beam_normal.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_diffuse_horizontal.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Temperature_Ambient.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Temperature_Sky_Radiation.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Relative_Humidity.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Precipitation.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Cloud_Index.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Station_Pressure.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Wind_Speed.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Wind_Direction.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_sun.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_longitudinal.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_transversal.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_direct_surface.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_diffuse_surface.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_1.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_2.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_3.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_4.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_5.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_6.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_1.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_2.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_3.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_4.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_5.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_6.TimeInfo.StartDate = '01-01-2014';

                obj(1,number_result).results_BOUNDARY.power.WDB.TimeValueComment.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Zenith_Angle.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Azimuth_Angle.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_beam_normal.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_diffuse_horizontal.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Temperature_Ambient.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Temperature_Sky_Radiation.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Relative_Humidity.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Precipitation.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Cloud_Index.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Station_Pressure.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Wind_Speed.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Wind_Direction.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_sun.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_longitudinal.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Incidence_Angle_transversal.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_direct_surface.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.WDB.Solar_Radiation_diffuse_surface.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_1.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_2.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_3.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_4.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_5.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.GDB.ground_6.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_1.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_2.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_3.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_4.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_5.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.power.NDB.neighbour_6.TimeInfo.Format = 'dd-mmm HH:MM';

                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_beam_normal_Energy.DataInfo.Units = 'kWh';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_diffuse_horizontal_Energy.DataInfo.Units = 'kWh';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_direct_surface_Energy.DataInfo.Units = 'kWh';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_diffuse_surface_Energy.DataInfo.Units = 'kWh';

                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_beam_normal_Energy.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_diffuse_horizontal_Energy.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_direct_surface_Energy.TimeInfo.StartDate = '01-01-2014';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_diffuse_surface_Energy.TimeInfo.StartDate = '01-01-2014';

                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_beam_normal_Energy.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_diffuse_horizontal_Energy.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_direct_surface_Energy.TimeInfo.Format = 'dd-mmm HH:MM';
                obj(1,number_result).results_BOUNDARY.energy.Solar_Radiation_diffuse_surface_Energy.TimeInfo.Format = 'dd-mmm HH:MM';

                results_building = obj(1,number_result);
                save(name,'results_building');
            else
                error(['result number ' num2str(number_result) ' does not exists!'])
            end
        end
        
        function info(obj, number_result, build)
            % obtain information about the result number "number_result" 
            % (list of the zones with characteristics, summary of the energy balance)
            % 1 ... number of the result
            % 2 ... building object
            [En Pow area] = different_monthly_energies(obj, number_result, build, 1, 1);
            disp(['Result number ' num2str(number_result) ': INFORMATION'])
            loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
            if exist(loaddir, 'file') == 2
                resultfile = load(loaddir);
                disp (['Zones number = ' num2str(length(resultfile.results_building.list_zones))])
                for ii = 1:length(resultfile.results_building.list_zones)
                    name_rooms = '';
                    if resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 0
                        mod = 'none/temperature';
                    elseif resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 1
                        mod = 'ideal';
                    elseif resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 2
                        mod = '1-node';
                    elseif resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 3
                        mod = '2-node';
                    end

                    for jj = 1:length(resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).rooms)
                        name_rooms = [name_rooms strjoin(resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).rooms(jj)) '   '];
                    end
                    disp ([(resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).name) ' ->  HEATED AREA:  ' num2str(resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).heated_area) ' m²,  HEATED VOLUME:  ' num2str(resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).heated_volume)  ' m³,  ROOMS:  ' name_rooms ', MODEL :  '  mod])
                end
                disp(['Pre Run Time:  ' num2str(round(resultfile.results_building.building_saved.preruntime/3600/24)) ' days'])
                disp(['Run Time:  ' num2str(round(resultfile.results_building.building_saved.runtime/3600/24)) ' days'])
                                
                for ii = 1:length(resultfile.results_building.list_zones)
                    for jj = 1:10
                        if resultfile.results_building.list_zones(ii) == jj
                            AIB(jj) = eval(['resultfile.results_building.results_AIB.z' num2str(jj)]);
                        end
                    end
                end
                
                Temperature_Area = 0;
                Area = 0;
                for ii = 1:length(resultfile.results_building.list_zones)
                    Temperature_Area = Temperature_Area + (AIB(resultfile.results_building.list_zones(ii)).Ts.Data) * (resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                    Area = Area + (resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                    Temperature_mean_building = timeseries(Temperature_Area/Area, AIB(resultfile.results_building.list_zones(ii)).Ts.Time, 'Name', 'Temperature_mean_building');
                end
                    
                teta_uh = 25;
                teta_overheating = 0;

                k = length(Temperature_mean_building.Data);
                for ii = 1:k
                    if Temperature_mean_building.Data(ii) > teta_uh
                        teta_overheating = teta_overheating + 1;
                    end
                end
                teta_overheating = teta_overheating / (3600/(Temperature_mean_building.Time(2)-Temperature_mean_building.Time(1)));

                teta_overheating_kelvin = 0;
                ii = 1; k = length(Temperature_mean_building.Data);
                while ii < k
                    if Temperature_mean_building.Data(ii) > teta_uh;
                        teta_overheating_kelvin = teta_overheating_kelvin + (Temperature_mean_building.Data(ii) - teta_uh);
                    end

                    ii = ii + round((3600/(Temperature_mean_building.Time(2)-Temperature_mean_building.Time(1))));
                end
                    
                disp('')
                disp('')
                disp('----------------------------------------------------------------')
                disp('|                         Results                               |')
                disp('----------------------------------------------------------------')
                
                q_HEATING_A = sum(En.H_M_A_tot);
                q_HEATING = sum(En.H_M_tot);
                    disp(['    En_H = ' num2str(q_HEATING) ' kWh/(m^2 a)         En_H = ' num2str(q_HEATING_A) ' kWh/(a)'])
                    
                q_COOLING_A = sum(En.C_M_A_tot);
                q_COOLING = sum(En.C_M_tot);
                    disp(['    En_C = ' num2str(q_COOLING) ' kWh/(m^2 a)         En_C = ' num2str(q_COOLING_A) ' kWh/(a)'])

                q_INTERNAL_A = sum(En.I_M_A_tot);
                q_INTERNAL = sum(En.I_M_tot);
                    disp(['    En_I = ' num2str(q_INTERNAL) ' kWh/(m^2 a)        En_I = ' num2str(q_INTERNAL_A) ' kWh/(a)'])

                q_SOLAR_A = sum(En.S_M_A_tot);
                q_SOLAR = sum(En.S_M_tot);
                    disp(['    En_S = ' num2str(q_SOLAR) ' kWh/(m^2 a)           En_S = ' num2str(q_SOLAR_A) ' kWh/(a)'])

                q_AIR_A = sum(En.V_M_A_tot);
                q_AIR = sum(En.V_M_tot);
                    disp(['    En_V = ' num2str(q_AIR) ' kWh/(m^2 a)             En_V = ' num2str(q_AIR_A) ' kWh/(a)'])

                q_TRANS_o_A = sum(En.T_o_M_A_tot);
                q_TRANS_o = sum(En.T_o_M_tot);
                    disp(['    En_T_o = ' num2str(q_TRANS_o) ' kWh/(m^2 a)       En_T_o = ' num2str(q_TRANS_o_A) ' kWh/(a) '])
                q_TRANS_g_A = sum(En.T_g_M_A_tot);
                q_TRANS_g = sum(En.T_g_M_tot);
                    disp(['    En_T_g = ' num2str(q_TRANS_g) ' kWh/(m^2 a)       En_T_g = ' num2str(q_TRANS_g_A) ' kWh/(a)'])
                q_TRANS_w_A = sum(En.T_w_M_A_tot);
                q_TRANS_w = sum(En.T_w_M_tot);
                    disp(['    En_T_w = ' num2str(q_TRANS_w) ' kWh/(m^2 a)       En_T_w = ' num2str(q_TRANS_w_A) ' kWh/(a)'])
                q_TRANS_n_A = sum(En.T_n_M_A_tot);
                q_TRANS_n = sum(En.T_n_M_tot);
                    disp(['    En_T_n = ' num2str(q_TRANS_n) ' kWh/(m^2 a)       En_T_n = ' num2str(q_TRANS_n_A) ' kWh/(a)'])

                Pow.H_tot = Pow.H_tot.Data(Pow.H_tot.Time>365*3600*24);

                disp('-------------------------------------------------------------------------')
                disp(['  q_H = ' num2str(sum(En.H_M_tot),'%6.2f') ' kWh/(m^2 a) ' ])
                disp(['  Qdot_h = ' num2str(max(Pow.H_tot),'%6.2f') ' W' ', qdot_h = ' num2str(max(Pow.H_tot/sum(area))) ' W/m^2'])
                disp(['  Übertemperaturhäufigkeit: ' num2str(teta_overheating*100,'%6.1f') ' %']);
                disp(['  Übertemperaturhäufigkeit: ' num2str(teta_overheating_kelvin,'%6.1f') ' K']);
                disp('-------------------------------------------------------------------------')
            else
                error(['result number ' num2str(number_result) ' does not exist' ])
            end
        end
        
        function [temperature_s temperature_r temperature_c humidity CO2] = plot_zones_thC(obj, number_result, build, choice_abs_rel_hum, choice_ppm, plot_extra)
            % plot the temperatures of the result number "number_result", the
            % humidity "choice_abs_rel_hum" ('rel' or 'abs') and the CO2
            % level ('ppm' or 'abs') and save the result in 
            % "temperature_s" "temperature_r" "temperature_c" "humidity"
            % "CO2", it can be set also only the number_result
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... 'rel' or 'abs'
            % 4 ... 'ppm' or 'abs'
            % 5 ... to plot only the general values and not every room
            if nargin == 5
                disp(' ')
                disp(['Result number ' num2str(number_result) ': PLOT TEMPERATURE, HUMIDITY AND CO2'])
            end
            nargin_temp = nargin;
            if nargin == 3
                choice_abs_rel_hum  = 'rel';
                choice_ppm = 'ppm';
                nargin_temp = 5;
            end
            if nargin_temp == 5 || nargin_temp == 6
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    for ii = 1:length(resultfile.results_building.list_zones)
                        for jj = 1:10
                            if resultfile.results_building.list_zones(ii) == jj
                                AIB(jj) = eval(['resultfile.results_building.results_AIB.z' num2str(jj)]);
                            end
                        end
                        if strcmp(choice_ppm, 'ppm')
                            AIB(resultfile.results_building.list_zones(ii)).x_CO2.Data = 10^6/1.529*AIB(resultfile.results_building.list_zones(ii)).x_CO2.Data;
                            AIB(resultfile.results_building.list_zones(ii)).x_CO2.DataInfo.Units = 'ppm';
                        end
                        pressure = 101325; %Pa
                        if strcmp(choice_abs_rel_hum, 'rel')
                            rH = eval(['AIB(resultfile.results_building.list_zones(ii)).x_H2O']);
                            rH.Name = 'rH';
                            rH.Data = (obj.fun_rel_hum(AIB(resultfile.results_building.list_zones(ii)).Tc.Data , AIB(resultfile.results_building.list_zones(ii)).x_H2O.Data, pressure))*100;
                            rH.DataInfo.Units = '%';
                        end
                        if nargin_temp ==5
                            figure
                            subplot(3,1,1)
                            plot(AIB(resultfile.results_building.list_zones(ii)).Ts)
                            grid on
                            title(['Sensitive Temperature, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            ylabel('T_s [°C]')
                            xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                            temperature_s(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).Ts']);
                            temperature_r(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).Tr']);
                            temperature_c(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).Tc']);

                            subplot(3,1,2)
                            pressure = 101325; %Pa
                            humidity(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).x_H2O']);
                            if strcmp(choice_abs_rel_hum, 'abs')
                                plot(AIB(resultfile.results_building.list_zones(ii)).x_H2O)
                                title(['Absolute Humidity, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                                xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                                grid on
                            elseif strcmp(choice_abs_rel_hum, 'rel')
                                plot(rH)
                                xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                                grid on
                                title(['Relative Humidity, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            end

                            subplot(3,1,3)
                            CO2(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).x_CO2']);
                            plot(AIB(resultfile.results_building.list_zones(ii)).x_CO2)
                            xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                            grid on
                            if strcmp(choice_ppm, 'abs')
                                title(['x CO2, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            elseif strcmp(choice_ppm, 'ppm')
                                title(['ppm CO2, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            end
                            
                            figure                            
                            plot(AIB(resultfile.results_building.list_zones(ii)).Ts, 'b'), hold all 
                            plot(AIB(resultfile.results_building.list_zones(ii)).Tr, 'r')
                            plot(AIB(resultfile.results_building.list_zones(ii)).Tc, 'c')
                            xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                            title(['Sensitive, Radiative and Convective Temperature, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            grid on
                            legend('T_s', 'T_r', 'T_c','Orientation','horizontal')
                            ylabel('Temperature [°C]')
                            
                            figure
                            pressure = 101325; %Pa
                            humidity(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).x_H2O']);
                            if strcmp(choice_abs_rel_hum, 'abs')
                                plot(AIB(resultfile.results_building.list_zones(ii)).x_H2O)
                                xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                                title(['Absolute Humidity, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                                grid on
                            elseif strcmp(choice_abs_rel_hum, 'rel')
                                plot(rH)
                                xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                                grid on
                                title(['Relative Humidity, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            end
                            
                            figure
                            CO2(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).x_CO2']);
                            plot(AIB(resultfile.results_building.list_zones(ii)).x_CO2)
                            xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                            if strcmp(choice_ppm, 'abs')
                                title(['x CO2, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            elseif strcmp(choice_ppm, 'ppm')
                                title(['ppm CO2, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            end
                            grid on
                        end
                    end
                    
                    % legends for all plots
                    text_legend = {};
                    for jjk = 1:length(resultfile.results_building.list_zones)
                        text_legend{jjk} = resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(jjk)).name;
                        text_legend{jjk} = strrep(text_legend{jjk},'_',' ');
                    end
                    
                    % initialize plots
                    scrsz = get(0,'ScreenSize');
                    if nargin_temp == 6
                        f1=figure('Position',[scrsz(3)*0/4+10 scrsz(4)*2/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                        f2=figure('Position',[scrsz(3)*1/4+10 scrsz(4)*2/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                        f3=figure('Position',[scrsz(3)*2/4+10 scrsz(4)*2/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                    else
                        f1=figure;clf;
                    end
                    
                    % hold first figure
                    figure(f1)
                    
                    % plot 
                    for ii = 1:length(resultfile.results_building.list_zones)
                        plot(AIB(resultfile.results_building.list_zones(ii)).Ts);  hold all
                    end
                    
                    xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                    ylabel('Temperature [°C]')
                    grid on
                    title ('Sensitive Temperature, every zone')
                    legend(text_legend,'Orientation','horizontal')
                    
                    if nargin_temp == 6
                        figure(f2)
                    else
                        figure
                    end
                    name_zone = [];
                    for ii = 1:length(resultfile.results_building.list_zones)
                        pressure = 101325; %Pa
                        humidity(:,ii) = eval(['AIB(resultfile.results_building.list_zones(ii)).x_H2O']);
                        if strcmp(choice_abs_rel_hum, 'abs')
                            plot(AIB(resultfile.results_building.list_zones(ii)).x_H2O); hold all
                            xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                            ylabel('aH (kgw/kga)')
                            grid on
                        elseif strcmp(choice_abs_rel_hum, 'rel')
                            rH = eval(['AIB(resultfile.results_building.list_zones(ii)).x_H2O']);
                            rH.Name = 'rH';
                            rH.Data = (obj.fun_rel_hum(AIB(resultfile.results_building.list_zones(ii)).Tc.Data , AIB(resultfile.results_building.list_zones(ii)).x_H2O.Data, pressure))*100;
                            plot(rH);  hold all
                            xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                            ylabel('rH (%)')
                            grid on
                        end
                        title('Humidity, every zone');
                        legend(text_legend,'Orientation','horizontal')
                    end
                    
                    if nargin_temp == 6
                        figure(f3)
                    else
                        figure
                    end
                    name_zone = [];
                    for ii = 1:length(resultfile.results_building.list_zones)
                        plot(AIB(resultfile.results_building.list_zones(ii)).x_CO2); hold all
                        xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                        if strcmp(choice_ppm, 'abs')
                            ylabel('x CO2 (kgCO2/kgw)')
                            title('x CO2, every zone');
                            grid on
                        elseif strcmp(choice_ppm, 'ppm')
                            title('ppm CO2, every zone');
                            ylabel('CO2 (ppm)')
                            grid on
                        end
                        legend(text_legend, 'Orientation','horizontal')
                    end

                else
                    error(['Result number ' num2str(number_result) ' not existing!'])
                end
            end
            
            if nargin_temp == 5 || nargin_temp == 6 || nargin_temp == 3
                T_m = {'01-Jan-2015 00:00:00', '31-Jan-2015 23:50:00', '01-Feb-2015 00:00:00', '28-Feb-2015 23:50:00', '01-Mar-2015 00:00:00', '31-Mar-2015 23:50:00', '01-Apr-2015 00:00:00', '30-Apr-2015 23:50:00', '01-May-2015 00:00:00', '31-May-2015 23:50:00', '01-Jun-2015 00:00:00', '30-Jun-2015 23:50:00', '01-Jul-2015 00:00:00', '31-Jul-2015 23:50:00', '01-Aug-2015 00:00:00', '31-Aug-2015 23:50:00', '01-Sep-2015 00:00:00', '30-Sep-2015 23:50:00', '01-Oct-2015 00:00:00', '31-Oct-2015 23:50:00', '01-Nov-2015 00:00:00', '30-Nov-2015 23:50:00', '01-Dec-2015 00:00:00', '31-Dec-2015 23:50:00'};
                for ii = 1:length(resultfile.results_building.list_zones)
                    rH = eval(['AIB(resultfile.results_building.list_zones(ii)).x_H2O']);
                    rH.Name = 'rH';
                    rH.Data = (obj.fun_rel_hum(AIB(resultfile.results_building.list_zones(ii)).Tc.Data , AIB(resultfile.results_building.list_zones(ii)).x_H2O.Data, pressure))*100;
                    
                    for jj = 1:12
                        Temp_s(ii,jj) = mean(getsampleusingtime(AIB(resultfile.results_building.list_zones(ii)).Ts, T_m{jj*2-1}, T_m{jj*2}));
                        x_H2O(ii,jj) = mean(getsampleusingtime(AIB(resultfile.results_building.list_zones(ii)).x_H2O, T_m{jj*2-1}, T_m{jj*2})) * 1000;
                        rH_m(ii,jj) = mean(getsampleusingtime(rH, T_m{jj*2-1}, T_m{jj*2}));
                    end
                    
                    fprintf('ZONE %d: \n',ii)
                    fprintf('   sensitive mean temperature each month: \t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t \n',Temp_s(ii,1),Temp_s(ii,2),Temp_s(ii,3),Temp_s(ii,4),Temp_s(ii,5),Temp_s(ii,6),Temp_s(ii,7),Temp_s(ii,8),Temp_s(ii,9),Temp_s(ii,10),Temp_s(ii,11),Temp_s(ii,12))
                    fprintf('   absolute mean humidity each month: \t \t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t \n',x_H2O(ii,1),x_H2O(ii,2),x_H2O(ii,3),x_H2O(ii,4),x_H2O(ii,5),x_H2O(ii,6),x_H2O(ii,7),x_H2O(ii,8),x_H2O(ii,9),x_H2O(ii,10),x_H2O(ii,11),x_H2O(ii,12))
                    fprintf('   relative mean humidity each month: \t \t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t %4.2f\t \n\n',rH_m(ii,1),rH_m(ii,2),rH_m(ii,3),rH_m(ii,4),rH_m(ii,5),rH_m(ii,6),rH_m(ii,7),rH_m(ii,8),rH_m(ii,9),rH_m(ii,10),rH_m(ii,11),rH_m(ii,12))
                end
            end
        end

        function [heating_demand cooling_demand] = energy_demand(obj, number_result, build, plot_extra, plot_air_energy)
            % plot and display the heating and cooling domand for every zone
            % and for every month
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... to plot only the general values and not every room
            % 4 ... plot enegy demand for heating on the air
            [En Pow area] = different_monthly_energies(obj, number_result, build, 1, 1);
            if nargin == 3
                disp(' ')
                disp(['Result number ' num2str(number_result) ': ENERGY DEMAND'])
            end
            if nargin == 3 || nargin == 4 || nargin == 5
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        heating_demand = [];
                        cooling_demand = [];
                        area =[];
                        disp('    ')
                        if nargin == 3
                            disp('   ENERGY DEMAND EACH ZONE    ')
                        elseif nargin == 5
                            disp('   ENERGY DEMAND EACH ZONE (NOT AIR HEATING SYSTEM)    ')
                        end
                        for ii = 1:length(resultfile.results_building.list_zones)
                            for jj = 1:10
                                if resultfile.results_building.list_zones(ii) == jj
                                    BDB_power(jj) = eval(['resultfile.results_building.results_BDB.power.z' num2str(jj)]);
                                    BDB_energy(jj) = eval(['resultfile.results_building.results_BDB.energy.z' num2str(jj)]);
                                end
                            end

                            time_1year = (resultfile.results_building.building_saved.preruntime/resultfile.results_building.building_saved.sampletime_1) :(resultfile.results_building.building_saved.preruntime/resultfile.results_building.building_saved.sampletime_1+ 365*24*3600/resultfile.results_building.building_saved.sampletime_1) ;
                            heating_demand(resultfile.results_building.list_zones(ii)) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_H_energy.Data(time_1year(end))-BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_H_energy.Data(time_1year(1));
                            cooling_demand(resultfile.results_building.list_zones(ii)) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_C_energy.Data(time_1year(end))-BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_C_energy.Data(time_1year(1));
                            if resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).model~=0 && resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).model~=1
                                area(resultfile.results_building.list_zones(ii)) = resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area;
                            else
                                area(resultfile.results_building.list_zones(ii)) = 0;
                            end
                            if nargin ==3 || nargin == 5
                                disp(num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name))
                                disp(['Total Energy 1 year (cooling + heating), ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str((heating_demand(resultfile.results_building.list_zones(ii))+cooling_demand(resultfile.results_building.list_zones(ii)))/1000) ' MWh/y'])
                                disp(['Total Heating Energy 1 year, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str((heating_demand(resultfile.results_building.list_zones(ii)))/1000) ' MWh/y'])
                                disp(['Total Cooling Energy 1 year, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str((cooling_demand(resultfile.results_building.list_zones(ii)))/1000) ' MWh/y'])
                                disp(['Specific Energy 1 year, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str(heating_demand(resultfile.results_building.list_zones(ii))/area(resultfile.results_building.list_zones(ii))+cooling_demand(resultfile.results_building.list_zones(ii))/area(resultfile.results_building.list_zones(ii))) ' kWh/(m²y)'])
                                disp(['Specific Heating Energy 1 year, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str(heating_demand(resultfile.results_building.list_zones(ii))/area(resultfile.results_building.list_zones(ii))) ' kWh/(m²y)'])
                                disp(['Specific Cooling Energy 1 year, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str(cooling_demand(resultfile.results_building.list_zones(ii))/area(resultfile.results_building.list_zones(ii))) ' kWh/(m²y)'])
                                disp('   ')
                            end
                        end
                        if nargin == 3 || nargin == 4
                            if nargin == 4
                                scrsz = get(0,'ScreenSize');

                                f11=figure('Position',[scrsz(3)*0/4+10 scrsz(4)*1/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                                f12=figure('Position',[scrsz(3)*1/4+10 scrsz(4)*1/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                                f13=figure('Position',[scrsz(3)*2/4+10 scrsz(4)*1/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;

                                figure(f11)
                            else
                                figure
                            end
                            hold on
                            bar_H = bar(1:length(heating_demand), heating_demand/1000, 'stack');
                            set(bar_H, 'BarWidth',.75)
                            bar_C = bar(1:length(cooling_demand), cooling_demand/1000, 'stack');
                            set(bar_C, 'BarWidth',.4)
                            legend('En_H','En_C','Orientation','horizontal')
                            set(gca,'XTick',1:12)
                            set(gca,'xlim',[0.5,12.5])
                            title('Total Heating and Cooling Energy Demand for every zone')
                            ylabel('Energy (MWh)')
                            xlabel('Zones')
                            grid on

                            text_legend = {};
                            for jjk = 1:length(resultfile.results_building.list_zones)
                                text_legend{jjk} = resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(jjk)).name;
                                text_legend{jjk} = strrep(text_legend{jjk},'_',' ');
                            end

                            if nargin == 4
                                figure(f12)
                            else 
                                figure
                            end
                            hold on
                            plot_values = [heating_demand/1000
                                cooling_demand/1000];
                            bar_H = bar(1:2, plot_values, 'stacked');
                            set(bar_H, 'BarWidth',.75)
                            set(gca,'XTick',1:2);
                            set(gca,'XTickLabel',{'En_H','En_c'});
                            legend(text_legend,'Orientation','horizontal')
                            title('Total Heating and Cooling Energy Demand for every zone')
                            ylabel('Energy (MWh)')
                            grid on                 

                            if nargin == 4
                                figure(f13)
                            else 
                                figure
                            end
                            hold on
                            bar_H = bar(1:length(heating_demand), heating_demand./area, 'stack');
                            set(bar_H, 'BarWidth',.75)
                            bar_C = bar(1:length(cooling_demand), cooling_demand./area, 'stack');
                            set(bar_C, 'BarWidth',.4)
                            set(bar_H,'FaceColor','red');
                            set(bar_C,'FaceColor','cyan');
                            set(gca,'XTick',1:12);
                            set(gca,'xlim',[0.5,12.5])
                            legend('En_H','En_C','Orientation','horizontal','Orientation','horizontal')
                            title('Specific Heating and Cooling Energy Demand for every zone')
                            ylabel('Energy (kWh/m²)')
                            xlabel('Zones')
                            grid on
                        end
                        
                        disp('    ')
                        if nargin == 3 || nargin == 4
                            disp('   ENERGY DEMAND TOTAL BUILDING   ')
                        elseif nargin == 5
                            disp('   ENERGY DEMAND TOTAL BUILDING (NOT AIR HEATING SYSTEM)   ')
                        end
                        disp(['Total Energy 1 year: ' num2str((sum(heating_demand)+sum(cooling_demand))/1000) ' MWh/y'])
                        disp(['Total Heating Energy 1 year: ' num2str((sum(heating_demand))/1000) ' MWh/y'])
                        disp(['Total Cooling Energy 1 year: ' num2str((sum(cooling_demand))/1000) ' MWh/y'])
                        disp('    ')
                        disp(['Specific Energy 1 year: ' num2str(sum(heating_demand)/sum(area)+sum(cooling_demand)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Heating Energy 1 year: ' num2str(sum(heating_demand)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Cooling Energy 1 year: ' num2str(sum(cooling_demand)/sum(area)) ' kWh/(m²y)'])
                    end 
                end
            end
            if nargin == 5
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        if size(resultfile.results_building.results_HVAC.Data,2)==4
                            heating_energy = resultfile.results_building.results_HVAC.Data(:,3)/(1000*3600);
                            heating_power = resultfile.results_building.results_HVAC.Data(:,1)/(1000);
                            fan_energy = resultfile.results_building.results_HVAC.Data(:,4)/(1000*3600);
                            fan_power = resultfile.results_building.results_HVAC.Data(:,2)/(1000);
                            heating_demand_sec = 0;
                            heating_demand_hp_electr = 0;
                            heating_demand_bu = 0;
                            heating_demand_hp = 0;
                            hp_power = 0;
                            bu_power = 0;
                        elseif size(resultfile.results_building.results_HVAC.Data,2)==6
                            heating_energy = resultfile.results_building.results_HVAC.Data(:,4)/(1000*3600);
                            heating_power = resultfile.results_building.results_HVAC.Data(:,1)/(1000)+resultfile.results_building.results_HVAC.Data(:,3)/(1000); % supply air + secondary air
                            fan_energy = resultfile.results_building.results_HVAC.Data(:,5)/(1000*3600);
                            fan_power = resultfile.results_building.results_HVAC.Data(:,2)/(1000);
                            sec_energy = resultfile.results_building.results_HVAC.Data(:,6)/(1000*3600);
                            sec_power = resultfile.results_building.results_HVAC.Data(:,3)/(1000);
                            heating_demand_sec = sec_energy(time_1year(end))- sec_energy(time_1year(1));
                            heating_demand_hp_electr = 0;
                            heating_demand_bu = 0;
                            heating_demand_hp = 0;
                            hp_power = 0;
                            bu_power = 0;
                        elseif size(resultfile.results_building.results_HVAC.Data,2)==12
                            fan_power = resultfile.results_building.results_HVAC.Data(:,2)/(1000);
                            sec_power = resultfile.results_building.results_HVAC.Data(:,3)/(1000);
                            hp_electr_power = resultfile.results_building.results_HVAC.Data(:,4)/(1000);
                            bu_power = resultfile.results_building.results_HVAC.Data(:,5)/(1000);
                            hp_power = resultfile.results_building.results_HVAC.Data(:,6)/(1000);
                            heating_power = resultfile.results_building.results_HVAC.Data(:,1)/(1000)+sec_power/(1000)+hp_power/(1000)+bu_power/(1000); % supply air + secondary air
                            heating_energy = resultfile.results_building.results_HVAC.Data(:,7)/(1000*3600);
                            fan_energy = resultfile.results_building.results_HVAC.Data(:,8)/(1000*3600);
                            sec_energy = resultfile.results_building.results_HVAC.Data(:,9)/(1000*3600);
                            hp_electr_energy = resultfile.results_building.results_HVAC.Data(:,10)/(1000*3600);
                            bu_energy = resultfile.results_building.results_HVAC.Data(:,11)/(1000*3600);
                            hp_energy = resultfile.results_building.results_HVAC.Data(:,12)/(1000*3600);
                            heating_demand_sec = sec_energy(time_1year(end))- sec_energy(time_1year(1));
                            heating_demand_hp_electr = hp_electr_energy(time_1year(end))- hp_electr_energy(time_1year(1));
                            heating_demand_bu = bu_energy(time_1year(end))- bu_energy(time_1year(1));
                            heating_demand_hp = hp_energy(time_1year(end))- hp_energy(time_1year(1));
                        end
                        
                        heating_demand_air = heating_energy(time_1year(end))-heating_energy(time_1year(1));
                        heating_demand_fans = fan_energy(time_1year(end))-fan_energy(time_1year(1));
                        heating_power_year = heating_power(time_1year);
                        
                        disp('    ')
                        disp('   ENERGY DEMAND TOTAL BUILDING (AIR HEATING SYSTEM)')
                        disp(['Total Heating Energy (SUPPLY AIR) 1 year: ' num2str((sum(heating_demand_air))/1000)  ' MWh/y'])
                        disp(['Total Heating Energy (FANS) 1 year: ' num2str((sum(heating_demand_fans))/1000)  ' MWh/y'])
                        disp(['Total Heating Energy (SECONDARY AIR) 1 year: ' num2str((sum(heating_demand_sec))/1000)  ' MWh/y'])
                        disp(['Total Heating Energy (HEAT PUMP ELECTRIC) 1 year: ' num2str((sum(heating_demand_hp_electr))/1000)  ' MWh/y'])
                        disp(['Total Heating Energy (BU) 1 year: ' num2str((sum(heating_demand_bu))/1000)  ' MWh/y'])
                        disp(['Total Heating Energy (HEAT PUMP) 1 year: ' num2str((sum(heating_demand_hp))/1000)  ' MWh/y'])
                        disp(['Specific Heating Energy (SUPPLY AIR) 1 year: ' num2str(sum(heating_demand_air)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Heating Energy (FANS) 1 year: ' num2str(sum(heating_demand_fans)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Heating Energy (SECONDARY AIR) 1 year: ' num2str(sum(heating_demand_sec)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Heating Energy (HEAT PUMP ELECTRIC) 1 year: ' num2str(sum(heating_demand_hp_electr)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Heating Energy (BU) 1 year: ' num2str(sum(heating_demand_bu)/sum(area)) ' kWh/(m²y)'])
                        disp(['Specific Heating Energy (HEAT PUMP) 1 year: ' num2str(sum(heating_demand_hp)/sum(area)) ' kWh/(m²y)'])
                        disp('    ')
                        disp('   ENERGY DEMAND TOTAL BUILDING (WHOLE HEATING ENERGY)')
                        disp(['Total Energy Demand 1 year: ' num2str((heating_demand_fans+heating_demand_bu+heating_demand_hp_electr)/1000)  ' MWh/y'])
                        disp(['Specific Energy Demand 1 year: ' num2str((heating_demand_fans+heating_demand_bu+heating_demand_hp_electr)/sum(area)) ' kWh/(m²y)'])
                        disp(['Heat Load (whole heating system): ' num2str(max(heating_power_year+Pow.H_tot.Data(time_1year)/1000)*1000) ' W'])
                        disp(['Heat Load (only Air heating system): ' num2str(max(heating_power_year)*1000) ' W'])
                        disp(['Heat Load (only HP+BU): ' num2str(max(bu_power+hp_power)*1000) ' W'])
                        disp(['Heat Load (only HP): ' num2str(max(hp_power)*1000) ' W'])
                        disp('    ')
                        disp(['Used area: ' num2str(sum(area)) ' m²'])
                        
                    end
                end
            end
        end
        
        function [En Pow area] = different_monthly_energies(obj, number_result, build, plot_extra, no_plot)
            % plot the balances of the losses and the gains for the result number "number_result"
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... to plot only the general values and not every room
            % 4 ... to save only the results and not plot
            if nargin == 3
                disp(' ')
                disp(['Result number ' num2str(number_result) ': PLOT THE MONTHLY BALANCES'])
            end
            if nargin == 3 || nargin == 4 || nargin == 5
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        area = [];
                        for ii = 1:length(resultfile.results_building.list_zones)
                            for jj = 1:10
                                if resultfile.results_building.list_zones(ii) == jj
                                    BDB_power(resultfile.results_building.list_zones(ii)) = eval(['resultfile.results_building.results_BDB.power.z' num2str(jj)]);
                                    BDB_energy(resultfile.results_building.list_zones(ii)) = eval(['resultfile.results_building.results_BDB.energy.z' num2str(jj)]);
                                end
                            end
                            heating_demand = [];
                            cooling_demand = [];
                            En.T_o(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_opaque_energy);
                            En.T_g(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_ground_energy);
                            En.T_w(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_window_energy);
                            En.T_n(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_neighbour_energy);
                            En.V_m(ii) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_V_mech_energy;
                            En.V_w(ii) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_V_window_energy;
                            En.V_i(ii) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_V_infiltration_energy;
                            En.V(ii) = En.V_m(ii) + En.V_w(ii) + En.V_i(ii);
                            En.S(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_S_energy);
                            En.I_p(ii) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_I_person_energy;
                            En.I_l(ii) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_I_light_energy;
                            En.I_e(ii) = BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_I_electricity_energy;
                            En.I(ii) = (En.I_p(ii) + En.I_l(ii) + En.I_e(ii));
                            En.H(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_H_energy);
                            Pow.H((resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_H);
                            Pow.C((resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_C);
                            Pow.H_hourly((resultfile.results_building.list_zones(ii))) = obj.preparedata(Pow.H((resultfile.results_building.list_zones(ii))),4);
                            Pow.C_hourly((resultfile.results_building.list_zones(ii))) = obj.preparedata(Pow.C((resultfile.results_building.list_zones(ii))),4);
                            
                            En.C(ii) = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_C_energy);
                            
                            En.T_o_M(:,(resultfile.results_building.list_zones(ii))) = (obj.energy2months(En.T_o(ii)))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.T_g_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.T_g(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.T_w_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.T_w(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.T_n_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.T_n(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area); 
                            En.V_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.V_m_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V_m(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.V_w_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V_w(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.V_i_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V_i(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);                            
                            En.S_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.S(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);                            
                            En.I_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);                            
                            En.I_p_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I_p(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.I_l_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I_l(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.I_e_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I_e(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);                            
                            En.H_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.H(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En.C_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.C(ii))'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);

                            En.T_o_M_A(:,(resultfile.results_building.list_zones(ii))) = (obj.energy2months(En.T_o(ii)))';
                            En.T_g_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.T_g(ii))';
                            En.T_w_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.T_w(ii))';
                            En.T_n_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.T_n(ii))';                            
                            En.V_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V(ii))';                            
                            En.V_m_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V_m(ii))';
                            En.V_w_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V_w(ii))';
                            En.V_i_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.V_i(ii))';  
                            En.S_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.S(ii))';                            
                            En.I_p_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I_p(ii))';
                            En.I_l_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I_l(ii))';
                            En.I_e_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I_e(ii))';
                            En.I_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.I(ii))';  
                            En.H_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.H(ii))';
                            En.C_M_A(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En.C(ii))';
                                                        
                            if nargin == 3
                                en_T_o_M_onlyheat = 0;
                                en_T_g_M_onlyheat = 0;
                                en_T_w_M_onlyheat = 0;
                                en_T_n_M_onlyheat = 0;
                                en_V_m_M_onlyheat = 0;
                                en_V_w_M_onlyheat = 0;
                                en_V_i_M_onlyheat = 0;
                                en_S_M_onlyheat = 0;
                                en_I_p_M_onlyheat = 0;
                                en_I_l_M_onlyheat = 0;
                                en_I_e_M_onlyheat = 0;
                                en_T_o_M_A_onlyheat = 0;
                                en_T_g_M_A_onlyheat = 0;
                                en_T_w_M_A_onlyheat = 0;
                                en_T_n_M_A_onlyheat = 0;
                                en_V_m_M_A_onlyheat = 0;
                                en_V_w_M_A_onlyheat = 0;
                                en_V_i_M_A_onlyheat = 0;
                                en_S_M_A_onlyheat = 0;
                                en_I_p_M_A_onlyheat = 0;
                                en_I_l_M_A_onlyheat = 0;
                                en_I_e_M_A_onlyheat = 0;
                                for lll = 1:12
                                    if En.H_M(lll,(resultfile.results_building.list_zones(ii)))~=0
                                        en_T_o_M_onlyheat = en_T_o_M_onlyheat + En.T_o_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_g_M_onlyheat = en_T_g_M_onlyheat + En.T_g_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_w_M_onlyheat = en_T_w_M_onlyheat + En.T_w_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_n_M_onlyheat = en_T_n_M_onlyheat + En.T_n_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_V_m_M_onlyheat = en_V_m_M_onlyheat + En.V_m_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_V_w_M_onlyheat = en_V_w_M_onlyheat + En.V_w_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_V_i_M_onlyheat = en_V_i_M_onlyheat + En.V_i_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_S_M_onlyheat = en_S_M_onlyheat + En.S_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_I_p_M_onlyheat = en_I_p_M_onlyheat + En.I_p_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_I_l_M_onlyheat = en_I_l_M_onlyheat + En.I_l_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_I_e_M_onlyheat = en_I_e_M_onlyheat + En.I_e_M(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_o_M_A_onlyheat = en_T_o_M_A_onlyheat + En.T_o_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_g_M_A_onlyheat = en_T_g_M_A_onlyheat + En.T_g_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_w_M_A_onlyheat = en_T_w_M_A_onlyheat + En.T_w_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_T_n_M_A_onlyheat = en_T_n_M_A_onlyheat + En.T_n_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_V_m_M_A_onlyheat = en_V_m_M_A_onlyheat + En.V_m_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_V_w_M_A_onlyheat = en_V_w_M_A_onlyheat + En.V_w_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_V_i_M_A_onlyheat = en_V_i_M_A_onlyheat + En.V_i_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_S_M_A_onlyheat = en_S_M_A_onlyheat + En.S_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_I_p_M_A_onlyheat = en_I_p_M_A_onlyheat + En.I_p_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_I_l_M_A_onlyheat = en_I_l_M_A_onlyheat + En.I_l_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                        en_I_e_M_A_onlyheat = en_I_e_M_A_onlyheat + En.I_e_M_A(lll,(resultfile.results_building.list_zones(ii)));
                                    end
                                end
                                
                                disp('  ')
                                disp(['Energy balance (energy calculated only for the heating period): ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)])
                                fprintf('Transmission Losses Opaque: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_o_M_onlyheat, en_T_o_M_A_onlyheat)
                                fprintf('Transmission Losses Ground: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_g_M_onlyheat, en_T_g_M_A_onlyheat)
                                fprintf('Transmission Losses Window: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_w_M_onlyheat, en_T_w_M_A_onlyheat)
                                fprintf('Transmission Losses Neighbour: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_n_M_onlyheat, en_T_n_M_A_onlyheat)
                                fprintf('Ventilation Losses Mechanical: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_V_m_M_onlyheat, en_V_m_M_A_onlyheat)
                                fprintf('Ventilation Losses Window: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_V_w_M_onlyheat, en_V_w_M_A_onlyheat)
                                fprintf('Ventilation Losses Infiltration: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_V_i_M_onlyheat, en_V_i_M_A_onlyheat)
                                fprintf('Solar Gains: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_S_M_onlyheat, en_S_M_A_onlyheat)
                                fprintf('Internal Gains People: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_I_p_M_onlyheat, en_I_p_M_A_onlyheat)
                                fprintf('Internal Gains Lights: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_I_l_M_onlyheat, en_I_l_M_A_onlyheat)
                                fprintf('Internal Gains Electricity: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_I_e_M_onlyheat, en_I_e_M_A_onlyheat)
                                fprintf('Heating Energy: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', sum(En.H_M(:,(resultfile.results_building.list_zones(ii)))), sum(En.H_M_A(:,(resultfile.results_building.list_zones(ii)))))
                                fprintf('Cooling Energy: \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', sum(En.C_M(:,(resultfile.results_building.list_zones(ii)))), sum(En.C_M_A(:,(resultfile.results_building.list_zones(ii)))))
                                
                                % each zone specific balance (kWh/m²)
                                
                                En_T_o_M_neg = En.T_o_M(:,ii);
                                En_T_o_M_pos = En.T_o_M(:,ii);
                                En_T_o_M_neg(find(En.T_o_M(:,ii)>=0)) = 0;
                                En_T_o_M_pos(find(En.T_o_M(:,ii)<0)) = 0;
                                
                                En_T_g_M_neg = En.T_g_M(:,ii);
                                En_T_g_M_pos = En.T_g_M(:,ii);
                                En_T_g_M_neg(find(En.T_g_M(:,ii)>=0)) = 0;
                                En_T_g_M_pos(find(En.T_g_M(:,ii)<0)) = 0;
                                
                                En_T_w_M_neg = En.T_w_M(:,ii);
                                En_T_w_M_pos = En.T_w_M(:,ii);
                                En_T_w_M_neg(find(En.T_w_M(:,ii)>=0)) = 0;
                                En_T_w_M_pos(find(En.T_w_M(:,ii)<0)) = 0;
                                
                                En_T_n_M_neg = En.T_n_M(:,ii);
                                En_T_n_M_pos = En.T_n_M(:,ii);
                                En_T_n_M_neg(find(En.T_n_M(:,ii)>=0)) = 0;
                                En_T_n_M_pos(find(En.T_n_M(:,ii)<0)) = 0;
                                
                                En_V_m_M_neg = En.V_m_M(:,ii);
                                En_V_m_M_pos = En.V_m_M(:,ii);
                                En_V_m_M_neg(find(En.V_m_M(:,ii)>=0)) = 0;
                                En_V_m_M_pos(find(En.V_m_M(:,ii)<0)) = 0;
                                
                                En_V_w_M_neg = En.V_w_M(:,ii);
                                En_V_w_M_pos = En.V_w_M(:,ii);
                                En_V_w_M_neg(find(En.V_w_M(:,ii)>=0)) = 0;
                                En_V_w_M_pos(find(En.V_w_M(:,ii)<0)) = 0;
                                
                                En_V_i_M_neg = En.V_i_M(:,ii);
                                En_V_i_M_pos = En.V_i_M(:,ii);
                                En_V_i_M_neg(find(En.V_i_M(:,ii)>=0)) = 0;
                                En_V_i_M_pos(find(En.V_i_M(:,ii)<0)) = 0;
                                
                                En_H_M_neg = En.H_M(:,ii);
                                En_H_M_pos = En.H_M(:,ii);
                                En_H_M_neg(find(En.H_M(:,ii)>=0)) = 0;
                                En_H_M_pos(find(En.H_M(:,ii)<0)) = 0;
                                
                                En_C_M_neg = En.C_M(:,ii);
                                En_C_M_pos = En.C_M(:,ii);
                                En_C_M_neg(find(En.C_M(:,ii)>=0)) = 0;
                                En_C_M_pos(find(En.C_M(:,ii)<0)) = 0;
                                
                                En_S_M_neg = En.S_M(:,ii);
                                En_S_M_pos = En.S_M(:,ii);
                                En_S_M_neg(find(En.S_M(:,ii)>=0)) = 0;
                                En_S_M_pos(find(En.S_M(:,ii)<0)) = 0;
                                
                                En_I_p_M_neg = En.I_p_M(:,ii);
                                En_I_p_M_pos = En.I_p_M(:,ii);
                                En_I_p_M_neg(find(En.I_p_M(:,ii)>=0)) = 0;
                                En_I_p_M_pos(find(En.I_p_M(:,ii)<0)) = 0;
                                
                                En_I_l_M_neg = En.I_l_M(:,ii);
                                En_I_l_M_pos = En.I_l_M(:,ii);
                                En_I_l_M_neg(find(En.I_l_M(:,ii)>=0)) = 0;
                                En_I_l_M_pos(find(En.I_l_M(:,ii)<0)) = 0;
                                
                                En_I_e_M_neg = En.I_e_M(:,ii);
                                En_I_e_M_pos = En.I_e_M(:,ii);
                                En_I_e_M_neg(find(En.I_e_M(:,ii)>=0)) = 0;
                                En_I_e_M_pos(find(En.I_e_M(:,ii)<0)) = 0;
                                
                                En_N = [-En_T_o_M_neg -En_T_g_M_neg -En_T_w_M_neg -En_T_n_M_neg -En_V_m_M_neg -En_V_w_M_neg -En_V_i_M_neg -En_H_M_neg -En_C_M_neg -En_S_M_neg -En_I_p_M_neg -En_I_l_M_neg -En_I_e_M_neg];
                                En_P = [En_H_M_pos En_C_M_pos En_S_M_pos En_I_p_M_pos En_I_l_M_pos En_I_e_M_pos En_T_o_M_pos En_T_g_M_pos En_T_w_M_pos En_T_n_M_pos En_V_m_M_pos En_V_w_M_pos En_V_i_M_pos];
                                
                                figure
                                hold on
                                bar_N = bar(1:12, En_N, 'stack');
                                set(bar_N, 'BarWidth',.75)
                                bar_P = bar(1:12, En_P, 'stack');
                                set(bar_P, 'BarWidth',.4)
                                set(bar_P(1),'FaceColor','red'); 
                                set(bar_P(2),'FaceColor','blue');  
                                set(bar_P(3),'FaceColor','yellow');  
                                set(bar_P(4),'FaceColor','green');  
                                set(bar_P(5),'FaceColor', [101/255 206/255 139/255]);  
                                set(bar_P(6),'FaceColor', [88/255 165/255 116/255]);  
                                set(bar_P(7),'FaceColor',[.5 .5 .5]);  
                                set(bar_P(8),'FaceColor',[.6 .6 .6]);  
                                set(bar_P(9),'FaceColor',[.7 .7 .7]);  
                                set(bar_P(10),'FaceColor',[.8 .8 .8]);  
                                set(bar_P(11),'FaceColor',[.9 1 1]);  
                                set(bar_P(12),'FaceColor',[.1 1 1]);
                                
                                set(bar_N(1),'FaceColor',[.5 .5 .5]);  
                                set(bar_N(2),'FaceColor',[.6 .6 .6]);  
                                set(bar_N(3),'FaceColor',[.7 .7 .7]);  
                                set(bar_N(4),'FaceColor',[.8 .8 .8]);  
                                set(bar_N(5),'FaceColor',[.9 1 1]);  
                                set(bar_N(6),'FaceColor',[.7 1 1]);  
                                set(bar_P(7),'FaceColor',[.1 1 1]);
                                set(bar_N(8),'FaceColor','red');  
                                set(bar_N(9),'FaceColor','blue');  
                                set(bar_N(10),'FaceColor','yellow');  
                                set(bar_N(11),'FaceColor','green');  
                                set(bar_N(12),'FaceColor', [101/255 206/255 139/255]);  
                                set(bar_N(13),'FaceColor', [88/255 165/255 116/255]);  
                                legend('En_T_{e,o}','En_T_g','En_T_{e,w}','En_T_{n}','En_{V,mech}','En_{V,win}','En_{V,inf}','En_H','En_C','En_S','En_{I,per}','En_{I,lig}','En_{I,elec}','Location','NE','Orientation','horizontal','Orientation','horizontal')
                                title(['Monthly Energy Balance, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)])
                                ylabel('Energy (kWh/m²)')
                                xlabel('Time (M)')
                                set(gca,'XTick',1:12);
                                set(gca,'xlim',[0.5,12.5])
                                grid on
                                hold off
                            end
                            
                            % each zone total balance (kWh)
                            
                            En_T_o_M_A_neg = En.T_o_M_A(:,ii);
                            En_T_o_M_A_pos = En.T_o_M_A(:,ii);
                            En_T_o_M_A_neg(find(En.T_o_M_A(:,ii)>=0)) = 0;
                            En_T_o_M_A_pos(find(En.T_o_M_A(:,ii)<0)) = 0;

                            En_T_g_M_A_neg = En.T_g_M_A(:,ii);
                            En_T_g_M_A_pos = En.T_g_M_A(:,ii);
                            En_T_g_M_A_neg(find(En.T_g_M_A(:,ii)>=0)) = 0;
                            En_T_g_M_A_pos(find(En.T_g_M_A(:,ii)<0)) = 0;

                            En_T_w_M_A_neg = En.T_w_M_A(:,ii);
                            En_T_w_M_A_pos = En.T_w_M_A(:,ii);
                            En_T_w_M_A_neg(find(En.T_w_M_A(:,ii)>=0)) = 0;
                            En_T_w_M_A_pos(find(En.T_w_M_A(:,ii)<0)) = 0;

                            En_T_n_M_A_neg = En.T_n_M_A(:,ii);
                            En_T_n_M_A_pos = En.T_n_M_A(:,ii);
                            En_T_n_M_A_neg(find(En.T_n_M_A(:,ii)>=0)) = 0;
                            En_T_n_M_A_pos(find(En.T_n_M_A(:,ii)<0)) = 0;

                            En_V_m_M_A_neg = En.V_m_M_A(:,ii);
                            En_V_m_M_A_pos = En.V_m_M_A(:,ii);
                            En_V_m_M_A_neg(find(En.V_m_M_A(:,ii)>=0)) = 0;
                            En_V_m_M_A_pos(find(En.V_m_M_A(:,ii)<0)) = 0;

                            En_V_w_M_A_neg = En.V_w_M_A(:,ii);
                            En_V_w_M_A_pos = En.V_w_M_A(:,ii);
                            En_V_w_M_A_neg(find(En.V_w_M_A(:,ii)>=0)) = 0;
                            En_V_w_M_A_pos(find(En.V_w_M_A(:,ii)<0)) = 0;

                            En_V_i_M_A_neg = En.V_i_M_A(:,ii);
                            En_V_i_M_A_pos = En.V_i_M_A(:,ii);
                            En_V_i_M_A_neg(find(En.V_i_M_A(:,ii)>=0)) = 0;
                            En_V_i_M_A_pos(find(En.V_i_M_A(:,ii)<0)) = 0;

                            En_H_M_A_neg = En.H_M_A(:,ii);
                            En_H_M_A_pos = En.H_M_A(:,ii);
                            En_H_M_A_neg(find(En.H_M_A(:,ii)>=0)) = 0;
                            En_H_M_A_pos(find(En.H_M_A(:,ii)<0)) = 0;

                            En_C_M_A_neg = En.C_M_A(:,ii);
                            En_C_M_A_pos = En.C_M_A(:,ii);
                            En_C_M_A_neg(find(En.C_M_A(:,ii)>=0)) = 0;
                            En_C_M_A_pos(find(En.C_M_A(:,ii)<0)) = 0;

                            En_S_M_A_neg = En.S_M_A(:,ii);
                            En_S_M_A_pos = En.S_M_A(:,ii);
                            En_S_M_A_neg(find(En.S_M_A(:,ii)>=0)) = 0;
                            En_S_M_A_pos(find(En.S_M_A(:,ii)<0)) = 0;

                            En_I_p_M_A_neg = En.I_p_M_A(:,ii);
                            En_I_p_M_A_pos = En.I_p_M_A(:,ii);
                            En_I_p_M_A_neg(find(En.I_p_M_A(:,ii)>=0)) = 0;
                            En_I_p_M_A_pos(find(En.I_p_M_A(:,ii)<0)) = 0;

                            En_I_l_M_A_neg = En.I_l_M_A(:,ii);
                            En_I_l_M_A_pos = En.I_l_M_A(:,ii);
                            En_I_l_M_A_neg(find(En.I_l_M_A(:,ii)>=0)) = 0;
                            En_I_l_M_A_pos(find(En.I_l_M_A(:,ii)<0)) = 0;

                            En_I_e_M_A_neg = En.I_e_M_A(:,ii);
                            En_I_e_M_A_pos = En.I_e_M_A(:,ii);
                            En_I_e_M_A_neg(find(En.I_e_M_A(:,ii)>=0)) = 0;
                            En_I_e_M_A_pos(find(En.I_e_M_A(:,ii)<0)) = 0;

                            En_N = [-En_T_o_M_A_neg -En_T_g_M_A_neg -En_T_w_M_A_neg -En_T_n_M_A_neg -En_V_m_M_A_neg -En_V_w_M_A_neg -En_V_i_M_A_neg -En_H_M_A_neg -En_C_M_A_neg -En_S_M_A_neg -En_I_p_M_A_neg -En_I_l_M_A_neg -En_I_e_M_A_neg];
                            En_P = [En_H_M_A_pos En_C_M_A_pos En_S_M_A_pos En_I_p_M_A_pos En_I_l_M_A_pos En_I_e_M_A_pos En_T_o_M_A_pos En_T_g_M_A_pos En_T_w_M_A_pos En_T_n_M_A_pos En_V_m_M_A_pos En_V_w_M_A_pos En_V_i_M_A_pos];

                            if nargin == 3
                                figure
                                hold on
                                bar_N = bar(1:12, En_N, 'stack');
                                set(bar_N, 'BarWidth',.75)
                                bar_P = bar(1:12, En_P, 'stack');
                                set(bar_P, 'BarWidth',.4)
                                set(bar_P(1),'FaceColor','red'); 
                                set(bar_P(2),'FaceColor','blue');  
                                set(bar_P(3),'FaceColor','yellow');  
                                set(bar_P(4),'FaceColor','green');  
                                set(bar_P(5),'FaceColor', [101/255 206/255 139/255]);  
                                set(bar_P(6),'FaceColor', [88/255 165/255 116/255]);  
                                set(bar_P(7),'FaceColor',[.5 .5 .5]);  
                                set(bar_P(8),'FaceColor',[.6 .6 .6]);  
                                set(bar_P(9),'FaceColor',[.7 .7 .7]);  
                                set(bar_P(10),'FaceColor',[.8 .8 .8]);  
                                set(bar_P(11),'FaceColor',[.9 1 1]);  
                                set(bar_P(12),'FaceColor',[.1 1 1]);
                                
                                set(bar_N(1),'FaceColor',[.5 .5 .5]);  
                                set(bar_N(2),'FaceColor',[.6 .6 .6]);  
                                set(bar_N(3),'FaceColor',[.7 .7 .7]);  
                                set(bar_N(4),'FaceColor',[.8 .8 .8]);  
                                set(bar_N(5),'FaceColor',[.9 1 1]);  
                                set(bar_N(6),'FaceColor',[.7 1 1]);  
                                set(bar_P(7),'FaceColor',[.1 1 1]);
                                set(bar_N(8),'FaceColor','red');  
                                set(bar_N(9),'FaceColor','blue');  
                                set(bar_N(10),'FaceColor','yellow');  
                                set(bar_N(11),'FaceColor','green');  
                                set(bar_N(12),'FaceColor', [101/255 206/255 139/255]);  
                                set(bar_N(13),'FaceColor', [88/255 165/255 116/255]);  
                                legend('En_T_{e,o}','En_T_g','En_T_{e,w}','En_T_{n}','En_{V,mech}','En_{V,win}','En_{V,inf}','En_H','En_C','En_S','En_{I,per}','En_{I,lig}','En_{I,elec}','Location','NE','Orientation','horizontal','Orientation','horizontal')
                                title(['Monthly Energy Balance, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)])
                                ylabel('Energy (kWh)')
                                xlabel('Time (M)')
                                set(gca,'XTick',1:12);
                                set(gca,'xlim',[0.5,12.5])
                                grid on
                                hold off
                            end
                            if resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).model~=0 && resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).model~=1
                                area(resultfile.results_building.list_zones(ii)) = (resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            else
                                area(resultfile.results_building.list_zones(ii)) = 0;
                            end
                        end
                        
                        % calculation energies for the total building
                        Pow.H_tot = Pow.H(1);
                        Pow.C_tot = Pow.C(1);
                        Pow.H_tot_hourly = Pow.H_hourly(1);
                        Pow.C_tot_hourly = Pow.C_hourly(1);
                        Pow.H_tot.Data = zeros(size(Pow.H_tot.Data));
                        Pow.C_tot.Data = zeros(size(Pow.C_tot.Data));
                        Pow.H_tot_hourly.Data = zeros(size(Pow.H_tot_hourly.Data));
                        Pow.C_tot_hourly.Data = zeros(size(Pow.C_tot_hourly.Data));
                        for ii = 1:size(Pow.H,2)
                            Pow.H_tot.Data = Pow.H_tot.Data + Pow.H(ii).Data;
                            Pow.C_tot.Data = Pow.C_tot.Data + Pow.C(ii).Data;
                            Pow.H_tot_hourly.Data = Pow.H_tot_hourly.Data + Pow.H_hourly(ii).Data;
                            Pow.C_tot_hourly.Data = Pow.C_tot_hourly.Data + Pow.C_hourly(ii).Data;
                        end
                        
                        En.T_o_M_tot = sum(En.T_o_M_A,2)/sum(area);
                        En.T_g_M_tot = sum(En.T_g_M_A,2)/sum(area);
                        En.T_w_M_tot = sum(En.T_w_M_A,2)/sum(area);
                        En.T_n_M_tot = sum(En.T_n_M_A,2)/sum(area);
                        En.V_m_M_tot = sum(En.V_m_M_A,2)/sum(area);
                        En.V_w_M_tot = sum(En.V_w_M_A,2)/sum(area);
                        En.V_i_M_tot = sum(En.V_i_M_A,2)/sum(area);
                        En.V_M_tot = sum(En.V_M_A,2)/sum(area);
                        En.S_M_tot = sum(En.S_M_A,2)/sum(area);
                        En.I_l_M_tot = sum(En.I_l_M_A,2)/sum(area);
                        En.I_p_M_tot = sum(En.I_p_M_A,2)/sum(area);
                        En.I_e_M_tot = sum(En.I_e_M_A,2)/sum(area);
                        En.I_M_tot = sum(En.I_M_A,2)/sum(area);
                        En.H_M_tot = sum(En.H_M_A,2)/sum(area);
                        En.C_M_tot = sum(En.C_M_A,2)/sum(area);
                        En.T_o_M_A_tot = sum(En.T_o_M_A,2);
                        En.T_g_M_A_tot = sum(En.T_g_M_A,2);
                        En.T_w_M_A_tot = sum(En.T_w_M_A,2);
                        En.T_n_M_A_tot = sum(En.T_n_M_A,2);
                        En.V_M_A_tot = sum(En.V_M_A,2);
                        En.V_m_M_A_tot = sum(En.V_m_M_A,2);
                        En.V_i_M_A_tot = sum(En.V_i_M_A,2);
                        En.V_w_M_A_tot = sum(En.V_w_M_A,2);
                        En.S_M_A_tot = sum(En.S_M_A,2);
                        En.I_p_M_A_tot = sum(En.I_p_M_A,2);
                        En.I_l_M_A_tot = sum(En.I_l_M_A,2);
                        En.I_e_M_A_tot = sum(En.I_e_M_A,2);
                        En.I_M_A_tot = sum(En.I_M_A,2);
                        En.H_M_A_tot = sum(En.H_M_A,2);
                        En.C_M_A_tot = sum(En.C_M_A,2);
                        
                        en_T_o_M_tot_onlyheat = 0;
                        en_T_g_M_tot_onlyheat = 0;
                        en_T_w_M_tot_onlyheat = 0;
                        en_T_n_M_tot_onlyheat = 0;
                        en_V_m_M_tot_onlyheat = 0;
                        en_V_w_M_tot_onlyheat = 0;
                        en_V_i_M_tot_onlyheat = 0;
                        en_S_M_tot_onlyheat = 0;
                        en_I_p_M_tot_onlyheat = 0;
                        en_I_l_M_tot_onlyheat = 0;
                        en_I_e_M_tot_onlyheat = 0;
                        en_T_o_M_A_tot_onlyheat = 0;
                        en_T_g_M_A_tot_onlyheat = 0;
                        en_T_w_M_A_tot_onlyheat = 0;
                        en_T_n_M_A_tot_onlyheat = 0;
                        en_V_m_M_A_tot_onlyheat = 0;
                        en_V_w_M_A_tot_onlyheat = 0;
                        en_V_i_M_A_tot_onlyheat = 0;
                        en_S_M_A_tot_onlyheat = 0;
                        en_I_p_M_A_tot_onlyheat = 0;
                        en_I_l_M_A_tot_onlyheat = 0;
                        en_I_e_M_A_tot_onlyheat = 0;
                        for lll = 1:12
                            if En.H_M_tot(lll) ~= 0
                                en_T_o_M_tot_onlyheat = en_T_o_M_tot_onlyheat + En.T_o_M_tot(lll);
                                en_T_g_M_tot_onlyheat = en_T_g_M_tot_onlyheat + En.T_g_M_tot(lll);
                                en_T_w_M_tot_onlyheat = en_T_w_M_tot_onlyheat + En.T_w_M_tot(lll);
                                en_T_n_M_tot_onlyheat = en_T_n_M_tot_onlyheat + En.T_n_M_tot(lll);
                                en_V_m_M_tot_onlyheat = en_V_m_M_tot_onlyheat + En.V_m_M_tot(lll);
                                en_V_w_M_tot_onlyheat = en_V_w_M_tot_onlyheat + En.V_w_M_tot(lll);
                                en_V_i_M_tot_onlyheat = en_V_i_M_tot_onlyheat + En.V_i_M_tot(lll);
                                en_S_M_tot_onlyheat = en_S_M_tot_onlyheat + En.S_M_tot(lll);
                                en_I_p_M_tot_onlyheat = en_I_p_M_tot_onlyheat + En.I_p_M_tot(lll);
                                en_I_l_M_tot_onlyheat = en_I_l_M_tot_onlyheat + En.I_l_M_tot(lll);
                                en_I_e_M_tot_onlyheat = en_I_e_M_tot_onlyheat + En.I_e_M_tot(lll);
                                en_T_o_M_A_tot_onlyheat = en_T_o_M_A_tot_onlyheat + En.T_o_M_A_tot(lll);
                                en_T_g_M_A_tot_onlyheat = en_T_g_M_A_tot_onlyheat + En.T_g_M_A_tot(lll);
                                en_T_w_M_A_tot_onlyheat = en_T_w_M_A_tot_onlyheat + En.T_w_M_A_tot(lll);
                                en_T_n_M_A_tot_onlyheat = en_T_n_M_A_tot_onlyheat + En.T_n_M_A_tot(lll);
                                en_V_m_M_A_tot_onlyheat = en_V_m_M_A_tot_onlyheat + En.V_m_M_A_tot(lll);
                                en_V_w_M_A_tot_onlyheat = en_V_w_M_A_tot_onlyheat + En.V_w_M_A_tot(lll);
                                en_V_i_M_A_tot_onlyheat = en_V_i_M_A_tot_onlyheat + En.V_i_M_A_tot(lll);
                                en_S_M_A_tot_onlyheat = en_S_M_A_tot_onlyheat + En.S_M_A_tot(lll);
                                en_I_p_M_A_tot_onlyheat = en_I_p_M_A_tot_onlyheat + En.I_p_M_A_tot(lll);
                                en_I_l_M_A_tot_onlyheat = en_I_l_M_A_tot_onlyheat + En.I_l_M_A_tot(lll);
                                en_I_e_M_A_tot_onlyheat = en_I_e_M_A_tot_onlyheat + En.I_e_M_A_tot(lll);
                            end
                        end
                        disp('  ')
                        disp('Energy balance:            Total Building')
                        fprintf('Transmission Losses Opaque:        \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_o_M_tot_onlyheat, en_T_o_M_A_tot_onlyheat)
                        fprintf('Transmission Losses Ground:        \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_g_M_tot_onlyheat, en_T_g_M_A_tot_onlyheat)
                        fprintf('Transmission Losses Window:        \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_w_M_tot_onlyheat, en_T_w_M_A_tot_onlyheat)
                        fprintf('Transmission Losses Neighbour:     \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_T_n_M_tot_onlyheat, en_T_n_M_A_tot_onlyheat)
                        fprintf('Ventilation Losses Mechanical:     \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_V_m_M_tot_onlyheat, en_V_m_M_A_tot_onlyheat)
                        fprintf('Ventilation Losses Window:         \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_V_w_M_tot_onlyheat, en_V_w_M_A_tot_onlyheat)
                        fprintf('Ventilation Losses Infiltration:   \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_V_i_M_tot_onlyheat, en_V_i_M_A_tot_onlyheat)
                        fprintf('Solar Gains:                       \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_S_M_tot_onlyheat, en_S_M_A_tot_onlyheat)
                        fprintf('Internal Gains People:             \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_I_p_M_tot_onlyheat, en_I_p_M_A_tot_onlyheat)
                        fprintf('Internal Gains Lights:             \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_I_l_M_tot_onlyheat, en_I_l_M_A_tot_onlyheat)
                        fprintf('Internal Gains Electricity:        \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', en_I_e_M_tot_onlyheat, en_I_e_M_A_tot_onlyheat)
                        fprintf('Heating Energy:                    \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', sum(En.H_M_tot), sum(En.H_M_A_tot))
                        fprintf('Cooling Energy:                    \t %4.3f \t kWh/m² \t  %4.3f \t kWh \t \n', sum(En.C_M_tot), sum(En.C_M_A_tot))                                
                        % total building specific balance (kWh/m²)
                        En_T_n_M_tot_neg = En.T_n_M_tot;
                        En_T_n_M_tot_pos = En.T_n_M_tot;
                        En_T_n_M_tot_neg(find(En.T_n_M_tot>=0)) = 0;
                        En_T_n_M_tot_pos(find(En.T_n_M_tot<0)) = 0;
                        
                        En_N_tot = [-En.T_o_M_tot -En.T_g_M_tot -En.T_w_M_tot -En_T_n_M_tot_neg -En.V_m_M_tot -En.V_w_M_tot -En.V_i_M_tot];
                        En_P_tot = [En.H_M_tot En.C_M_tot En.S_M_tot En.I_p_M_tot En.I_l_M_tot En.I_e_M_tot En_T_n_M_tot_pos];
                        
                        % total building total balance (kWh)
                        En_T_n_M_tot_A_neg = En.T_n_M_A_tot;
                        En_T_n_M_tot_A_pos = En.T_n_M_A_tot;
                        En_T_n_M_tot_A_neg(find(En.T_n_M_A_tot>=0)) = 0;
                        En_T_n_M_tot_A_pos(find(En.T_n_M_A_tot<0)) = 0;
                        
                        En_N_tot_A = [-En.T_o_M_A_tot -En.T_g_M_A_tot -En.T_w_M_A_tot -En_T_n_M_tot_A_neg -En.V_m_M_A_tot -En.V_w_M_A_tot -En.V_i_M_A_tot]*10^(-3);
                        En_P_tot_A = [En.H_M_A_tot En.C_M_A_tot En.S_M_A_tot En.I_p_M_A_tot En.I_l_M_A_tot En.I_e_M_A_tot En_T_n_M_tot_A_pos]*10^(-3);
                        
                        if nargin == 3 || nargin ==4
                            if nargin ==4
                                % figure total building specific balance (kWh/m²)
                                scrsz = get(0,'ScreenSize');
                                f4=figure('Position',[scrsz(3)*3/4+10 scrsz(4)*2/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                                figure(f4)
                            elseif nargin == 3
                                figure
                            end
                            hold on
                            bar_N = bar(1:12, En_N_tot, 'stack');
                            set(bar_N, 'BarWidth',.75)
                            bar_P = bar(1:12, En_P_tot, 'stack');
                            set(bar_P, 'BarWidth',.4)
                            set(bar_P(1),'FaceColor','red');  set(bar_P(2),'FaceColor','blue');  set(bar_P(3),'FaceColor','yellow');  set(bar_P(4),'FaceColor','green');  set(bar_P(5),'FaceColor', [101/255 206/255 139/255]);  set(bar_P(6),'FaceColor', [88/255 165/255 116/255]);  set(bar_P(7),'FaceColor',[.8 .8 .8]);
                            set(bar_N(1),'FaceColor',[.5 .5 .5]);  set(bar_N(2),'FaceColor',[.6 .6 .6]);  set(bar_N(3),'FaceColor',[.7 .7 .7]);  set(bar_N(4),'FaceColor',[.8 .8 .8]);  set(bar_N(5),'FaceColor',[.9 1 1]);  set(bar_N(6),'FaceColor',[.7 1 1]);  set(bar_N(7),'FaceColor',[.1 1 1]);
                            legend('En_T_{e,o}','En_T_g','En_T_{e,w}','En_T_{n}','En_{V,mech}','En_{V,win}','En_{V,inf}','En_H','En_C','En_S','En_{I,per}','En_{I,lig}','En_{I,elec}','Location','NE','Orientation','horizontal','Orientation','horizontal')
                            title('Monthly Energy Balance: Total Building')
                            ylabel('Energy (kWh/m²)')
                            xlabel('Time (M)')
                            set(gca,'xlim',[0.5,12.5])
                            set(gca,'XTick',1:12);
                            grid on
                            hold off
                        end
                            
                        if nargin == 3
                            % figure total building total balance (MWh)
                            figure
                            hold on
                            bar_N = bar(1:12, En_N_tot_A, 'stack');
                            set(bar_N, 'BarWidth',.75)
                            bar_P = bar(1:12, En_P_tot_A, 'stack');
                            set(bar_P, 'BarWidth',.4)
                            set(bar_P(1),'FaceColor','red');  set(bar_P(2),'FaceColor','blue');  set(bar_P(3),'FaceColor','yellow');  set(bar_P(4),'FaceColor','green');  set(bar_P(5),'FaceColor', [101/255 206/255 139/255]);  set(bar_P(6),'FaceColor', [88/255 165/255 116/255]);  set(bar_P(7),'FaceColor',[.8 .8 .8]);
                            set(bar_N(1),'FaceColor',[.5 .5 .5]);  set(bar_N(2),'FaceColor',[.6 .6 .6]);  set(bar_N(3),'FaceColor',[.7 .7 .7]);  set(bar_N(4),'FaceColor',[.8 .8 .8]);  set(bar_N(5),'FaceColor',[.9 1 1]);  set(bar_N(6),'FaceColor',[.7 1 1]);  set(bar_N(7),'FaceColor',[.1 1 1]);
                            legend('En_T_{e,o}','En_T_g','En_T_{e,w}','En_T_{n}','En_{V,mech}','En_{V,win}','En_{V,inf}','En_H','En_C','En_S','En_{I,per}','En_{I,lig}','En_{I,elec}','Location','NE','Orientation','horizontal','Orientation','horizontal')
                            title('Monthly Energy Balance: Total Building')
                            ylabel('Energy (MWh)')
                            xlabel('Time (M)')
                            set(gca,'xlim',[0.5,12.5])
                            set(gca,'XTick',1:12);
                            grid on
                            hold off
                        end
                    end
                end
            end
        end
        
        function [Teta_Amb Pow_H Pow_C] = plot_heat_temp_hours(obj, number_result, build, plot_extra)
            % plots the heat load sorted by ambient temperature and by 
            % hours for the result number "number_result"
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... to plot only the general values and not every room
            if number_result == 0
                number_result = obj.number;
            end
            
            disp(['Result number ' num2str(number_result) ': PLOT HEATING AND COOLING LOAD SORTED BY AMBIENT TEMPERATURE AND HOURS'])
            disp(' ')
            
            if nargin == 3 || nargin == 4
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        for ii = 1:length(resultfile.results_building.list_zones)
                            for jj = 1:10
                                if resultfile.results_building.list_zones(ii) == jj
                                    BDB_power(jj) = eval(['resultfile.results_building.results_BDB.power.z' num2str(jj)]);
                                    BDB_energy(jj) = eval(['resultfile.results_building.results_BDB.energy.z' num2str(jj)]);
                                end
                            end
                            ts_temp_H = [];
                            ts_temp_C = [];
                            Pow_T_o(:,(resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_T_opaque.Data);
                            Pow_H(:,(resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_H.Data(BDB_power(resultfile.results_building.list_zones(ii)).Qdot_H.Time > 365*3600*24));
                            time_H(:,(resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_H.Time(BDB_power(resultfile.results_building.list_zones(ii)).Qdot_H.Time > 365*3600*24));
                            Pow_C(:,(resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_C.Data(BDB_power(resultfile.results_building.list_zones(ii)).Qdot_C.Time > 365*3600*24));
                            time_C(:,(resultfile.results_building.list_zones(ii))) = (BDB_power(resultfile.results_building.list_zones(ii)).Qdot_C.Time(BDB_power(resultfile.results_building.list_zones(ii)).Qdot_C.Time > 365*3600*24));
                            ts_temp_H = timeseries(Pow_H(:,(resultfile.results_building.list_zones(ii))), time_H(:,(resultfile.results_building.list_zones(ii))));
                            ts_temp_C = timeseries(Pow_C(:,(resultfile.results_building.list_zones(ii))), time_C(:,(resultfile.results_building.list_zones(ii))));
                            ts_temp_H_hourly = obj.preparedata(ts_temp_H,4);
                            ts_temp_C_hourly = obj.preparedata(ts_temp_C,4);
                            ts_temp_H_daily = obj.preparedata(ts_temp_H,3);
                            ts_temp_C_daily = obj.preparedata(ts_temp_C,3);
                            Pow_H_hourly(:,(resultfile.results_building.list_zones(ii))) = ts_temp_H_hourly.Data;
                            Pow_C_hourly(:,(resultfile.results_building.list_zones(ii))) = ts_temp_C_hourly.Data;
                            Pow_H_daily(:,(resultfile.results_building.list_zones(ii))) = ts_temp_H_daily.Data;
                            Pow_C_daily(:,(resultfile.results_building.list_zones(ii))) = ts_temp_C_daily.Data;
                        end
                        
                        Pow_H_tot = sum(Pow_H,2);
                        Pow_C_tot = sum(Pow_C,2);
                        Pow_H_tot_hourly = sum(Pow_H_hourly,2);
                        Pow_C_tot_hourly = sum(Pow_C_hourly,2);
                        Pow_H_tot_daily = sum(Pow_H_daily,2);
                        Pow_C_tot_daily = sum(Pow_C_daily,2);
                        
                        area = 0;
                        for ii=1:length(resultfile.results_building.list_zones)
                            if sum(Pow_T_o(:,resultfile.results_building.list_zones(ii))) == 0
                            else
                                area = area + resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area;
                            end
                        end
                        
                        Teta_Amb.normal = resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Data(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Time > 365*3600*24);
                        
                        % use variables again
                        clear Pow_H Pow_C
                        
                        Pow_H.normal = Pow_H_tot/area;
                        Pow_H.hourly = Pow_H_tot_hourly/area;
                        Pow_H.daily = Pow_H_tot_daily/area;
                        Pow_C.normal = Pow_C_tot/area;
                        Pow_C.hourly = Pow_C_tot_hourly/area;
                        Pow_C.daily = Pow_C_tot_daily/area;
                        
                        teta_amb_d1_ = resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Data(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Time > 365*3600*24);
                        time_amb_d1_ = resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Time(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Time > 365*3600*24);
                        ts_temp_ = timeseries(teta_amb_d1_, time_amb_d1_);
                        ts_temp_hourly = obj.preparedata(ts_temp_,4);
                        teta_amb_d1_hourly_ = ts_temp_hourly.Data;
                        ts_temp_daily = obj.preparedata(ts_temp_,3);
                        teta_amb_d1_daily = ts_temp_daily.Data;
                        
                        Teta_Amb.hourly = ts_temp_hourly;
                        Teta_Amb.daily = ts_temp_daily;
                        
                        if nargin == 3
                            figure   
                            hold on
                            plot(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Data(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Time > 365*3600*24)', Pow_H_tot/area,'dk');
                            title('Heating Load Sorted by Ambient Temperature')
                            xlabel('Ambient Temperature [°C]')
                            ylabel('Heating Power [W/m^2]')
                            grid on
                        end
                        
                        if nargin == 4
                            scrsz = get(0,'ScreenSize');

                            f21=figure('Position',[scrsz(3)*0/4+10 scrsz(4)*0/3+10 scrsz(3)*1/4-10 scrsz(4)*1/4-10],'Name','Monthly Solar Gains CARNOT/PHPP');clf;
                            f22=figure('Position',[scrsz(3)*1/4+10 scrsz(4)*0/3+10 scrsz(3)*1/4-10 scrsz(4)*1/4-10],'Name','Monthly Losses CARNOT/PHPP');clf;
                            figure(f21)
                        else
                            figure    
                        end
                        hold on
                        plot(teta_amb_d1_hourly_, Pow_H_tot_hourly/area,'dk');
                        title('Heating Load Sorted by Ambient Temperature (hourly values)')
                        xlabel('Ambient Temperature [°C]')
                        ylabel('Heating Power [W/m^2]')
                        grid on
                        
                        if nargin == 3
                            figure  
                            hold on
                            plot(teta_amb_d1_daily, Pow_H_tot_daily/area,'dk');
                            title('Heating Load Sorted by Ambient Temperature (daily values)')
                            xlabel('Ambient Temperature [°C]')
                            ylabel('Heating Power [W/m^2]')
                            grid on
                        end

                        if nargin == 4
                            figure(f22)
                        else
                            figure    
                        end
                        hold on
                        plot(linspace(0,8760,length(Pow_H_tot_hourly)),sort(Pow_H_tot_hourly/area,'descend'),'Color','b','LineStyle','-','Marker','None','LineWidth',2);
                        title('Heating Load sorted by the Hours')
                        ylabel('Heating Power [W/m^2]')
                        xlabel('Time / [h]')
                        grid on
                        
                        disp(' ')
                        disp('MAXIMAL HEATING AND COOLING LOAD (hourly mean)')
                        disp(' ')
                        disp(['Max Heating Load building: ' num2str((max(Pow_H_tot_hourly))/1000) ' kW']);
                        for ii = 1:length(resultfile.results_building.list_zones)
                            disp(['Max Heating Load ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str((max(Pow_H_hourly(:,(resultfile.results_building.list_zones(ii)))))/1000) ' kW']);
                        end
                        
                        if nargin == 3  
                            figure
                            hold on
                            plot(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Data(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient.Time > 365*3600*24)', Pow_C_tot/area,'dk');
                            title('Cooling Load Sorted by Ambient Temperature')
                            xlabel('Ambient Temperature [°C]')
                            ylabel('Cooling Power [W/m^2]')
                            grid on
                        end 
                        
                        if nargin == 3
                            figure  
                            hold on
                            plot(teta_amb_d1_hourly_, Pow_C_tot_hourly/area,'dk');
                            title('Cooling Load Sorted by Ambient Temperature (hourly values)')
                            xlabel('Ambient Temperature [°C]')
                            ylabel('Cooling Power [W/m^2]')
                            grid on
                        end
                        
                        if nargin == 3
                            figure   
                            hold on
                            plot(teta_amb_d1_daily, Pow_C_tot_daily/area,'dk');
                            title('Cooling Load Sorted by Ambient Temperature (daily values)')
                            xlabel('Ambient Temperature [°C]')
                            ylabel('Cooling Power [W/m^2]')
                            grid on
                        end
                        
                        if nargin == 3
                            figure
                            hold on
                            plot(linspace(0,8760,length(Pow_C_tot_hourly)),sort(Pow_C_tot_hourly/area,'descend'),'Color','b','LineStyle','-','Marker','None','LineWidth',2);
                            title('Cooling Load sorted by the Hours')
                            ylabel('Cooling Power [W/m^2]')
                            xlabel('Time / [h]')
                            grid on;
                        end
                        
                        disp(' ')
                        disp(['Max Cooling Load building: ' num2str((max(Pow_C_tot_hourly))/1000) ' kW']);
                        for ii = 1:length(resultfile.results_building.list_zones)
                            disp(['Max Cooling Load ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name) ': ' num2str((max(Pow_C_hourly(:,(resultfile.results_building.list_zones(ii)))))/1000) ' kW']);
                        end
                    end
                end
            end
        end

        function [Temp] = plot_temp_amb_buil_soil(obj, number_result, build, plot_extra)
            % plots the ambient temperature, a mean temperature of the 
            % building and the tempeature of the ground for the result 
            % number "number_result"
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... to plot only the general values and not every room
            if nargin == 3
                disp(' ')
                disp(['Result number ' num2str(number_result) ': PLOT AMBIENT, BUILDING AND SOIL TEMPERATURE'])
            end
            if nargin == 3 || nargin == 4
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        for ii = 1:length(resultfile.results_building.list_zones)
                            for jj = 1:10
                                if resultfile.results_building.list_zones(ii) == jj
                                    AIB(jj) = eval(['resultfile.results_building.results_AIB.z' num2str(jj)]);
                                end
                            end
                        end
                        Temperature_Area = 0;
                        Area = 0;
                        for ii = 1:length(resultfile.results_building.list_zones)
                            Temperature_Area = Temperature_Area + (AIB(resultfile.results_building.list_zones(ii)).Ts.Data) * (resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            Area = Area + (resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            Temperature_mean_building = timeseries(Temperature_Area/Area, AIB(resultfile.results_building.list_zones(ii)).Ts.Time, 'Name', 'Temperature_mean_building');
                        end

                        if nargin == 4
                            scrsz = get(0,'ScreenSize');
                            f14=figure('Position',[scrsz(3)*3/4+10 scrsz(4)*1/3 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                            figure(f14)
                        else
                            figure
                        end
                        Temperature_mean_building.TimeInfo.StartDate = '01-01-2014';
                        Temperature_mean_building.TimeInfo.Format = 'dd-mmm HH:MM';
                        Temp.mean_building = Temperature_mean_building;
                        Temp.ambient = resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient;
                        Temp.ground = resultfile.results_building.results_BOUNDARY.power.GDB.ground_1;
                        plot(Temperature_mean_building,'r')
                        
                        hold on
                        plot(resultfile.results_building.results_BOUNDARY.power.WDB.Temperature_Ambient,'g')
                        plot(resultfile.results_building.results_BOUNDARY.power.GDB.ground_1,'y')
                        xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                        grid on
                        legend('T_{mean,building}','T_{ambient}','T_{ground}','Orientation','horizontal')

                        title('Temperature')
                        ylabel = 'T [°C]';
                    end
                end
            end
        end
        
        function [sorted_temp_1 sorted_time_1 sorted_temp_2 sorted_time_2] = plot_temperature_arranged_hours(obj, number_result, build, plot_extra)
            % plots the temperature arranged by the hours for the result 
            % number "number_result"
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... to plot only the general values and not every room
            if nargin == 3            
                disp(' ')
                disp(['Result number ' num2str(number_result) ': PLOT TEMPERATURE ARRANGED BY THE HOURS'])
            end
            if nargin == 3 || nargin == 4
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        for ii = 1:length(resultfile.results_building.list_zones)
                            for jj = 1:10
                                if resultfile.results_building.list_zones(ii) == jj
                                    AIB(jj) = eval(['resultfile.results_building.results_AIB.z' num2str(jj)]);
                                    BDB_power(jj) = eval(['resultfile.results_building.results_BDB.power.z' num2str(jj)]);
                                    BDB_energy(jj) = eval(['resultfile.results_building.results_BDB.energy.z' num2str(jj)]);
                                end
                            end
                            teta_i_count = [15:.5:30];
                            
                            for jj = 1:length(teta_i_count)
                                anz_teta_i_count(jj) = (length(find(round(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600)*2)/2==teta_i_count(jj))));
                            end
                            anz_teta_i_count = anz_teta_i_count/(3600/(AIB(resultfile.results_building.list_zones(ii)).Ts.Time(2)-AIB(resultfile.results_building.list_zones(ii)).Ts.Time(1)));
                            figure
                            grid on
                            bar(teta_i_count,anz_teta_i_count,.5)
                            title(['Temperature Arranged by the hours, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            xlabel('Temperature [°C]')
                            ylabel('Time [h]')
                            grid on
                            set(gca,'Xlim',[18,28])
                            sorted_temp_1(:,ii) = sort(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600),'descend');
                            sorted_time_1(:,ii) = linspace(0,24*365,length(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600)));
                        end
                        for ii = 1:length(resultfile.results_building.list_zones)
                            figure
                            grid on
                            sorted_temp_2(:,ii) = sort(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600),'descend');
                            sorted_time_2(:,ii) = linspace(0,24*365,length(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600)));
                            plot(sort(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600),'descend'), linspace(0,24*365,length(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600))))
                            %plot(AIB(resultfile.results_building.list_zones(ii)).Ts.Data(AIB(resultfile.results_building.list_zones(ii)).Ts.Time > 365*24*3600)),anz_teta_i_count_2)))
                            title(['Temperature Arranged by the hours, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                            xlabel('Temperature [°C]')
                            ylabel('Time [h]')
                            grid on
                            set(gca,'Ylim',[0,8760])
                        end
                    end
                end
            end
        end
        
        function plot_monthly_losses_gains(obj, number_result, build, plot_extra)
            % plots the monthly losses and gains for every zone
            % 1 ... number of the result
            % 2 ... building object
            % 3 ... to plot only the general values and not every room
            % NOTE: no output because you can have them with the function different_monthly_energies
            if nargin == 3
                disp(' ')
                disp(['Result number ' num2str(number_result) ': PLOT THE MONTHLY LOSSES AND GAINS'])
            end
            if nargin == 3 || nargin == 4
                loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
                if exist(loaddir, 'file') == 2
                    resultfile = load(loaddir);
                    if (resultfile.results_building.building_saved.runtime)<(24*365*3600)
                        error('function not usable because run time less than 1 year')
                    else
                        En_P = [];
                        En_N = [];
                        En_T_o = [];
                        En_T_g = [];
                        En_T_w = [];
                        En_T_n = [];
                        En_V = [];
                        En_S = [];
                        En_I = [];
                        En_H = [];
                        En_C = [];
                        for ii = 1:length(resultfile.results_building.list_zones)
                            for jj = 1:10
                                if resultfile.results_building.list_zones(ii) == jj
                                    BDB_power(jj) = eval(['resultfile.results_building.results_BDB.power.z' num2str(jj)]);
                                    BDB_energy(jj) = eval(['resultfile.results_building.results_BDB.energy.z' num2str(jj)]);
                                end
                            end
                            heating_demand = [];
                            cooling_demand = [];
                            area =[];

                            En_T_o = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_opaque_energy);
                            En_T_g = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_ground_energy);
                            En_T_w = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_window_energy);
                            En_T_n = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_T_neighbour_energy);
                            En_V = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_V_mech_energy + BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_V_window_energy + BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_V_infiltration_energy);
                            En_S = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_S_energy);
                            En_I = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_I_person_energy + BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_I_light_energy + BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_I_electricity_energy);
                            En_H = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_H_energy);
                            En_C = (BDB_energy(resultfile.results_building.list_zones(ii)).Qdot_C_energy);

                            En_T_o_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_T_o)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_T_g_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_T_g)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_T_w_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_T_w)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_T_n_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_T_n)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_V_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_V)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_S_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_S)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_I_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_I)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_H_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_H)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);
                            En_C_M(:,(resultfile.results_building.list_zones(ii))) = obj.energy2months(En_C)'/(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).heated_area);

                            En_N = [-En_T_o_M(:,(resultfile.results_building.list_zones(ii))) -En_T_g_M(:,(resultfile.results_building.list_zones(ii))) -En_T_w_M(:,(resultfile.results_building.list_zones(ii))) -En_T_n_M(:,(resultfile.results_building.list_zones(ii))) -En_V_M(:,(resultfile.results_building.list_zones(ii)))];
                            En_P = [En_H_M(:,(resultfile.results_building.list_zones(ii))) En_C_M(:,(resultfile.results_building.list_zones(ii))) En_S_M(:,(resultfile.results_building.list_zones(ii))) En_I_M(:,(resultfile.results_building.list_zones(ii)))];

                            En_N_sum = -En_T_o_M(:,(resultfile.results_building.list_zones(ii)))-En_T_g_M(:,(resultfile.results_building.list_zones(ii)))-En_T_w_M(:,(resultfile.results_building.list_zones(ii)))-En_T_n_M(:,(resultfile.results_building.list_zones(ii)))-En_V_M(:,(resultfile.results_building.list_zones(ii)));
                            En_P_sum = En_S_M(:,(resultfile.results_building.list_zones(ii)))+En_I_M(:,(resultfile.results_building.list_zones(ii)));
                            if nargin == 3
                                figure
                                hold on
                                set(gca,'FontSize',12)
                                plot(1:12, En_T_o_M(:,(resultfile.results_building.list_zones(ii))),'Color','r','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_T_g_M(:,(resultfile.results_building.list_zones(ii))),'Color','k','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_T_w_M(:,(resultfile.results_building.list_zones(ii))),'Color','y','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_T_n_M(:,(resultfile.results_building.list_zones(ii))),'Color','m','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_V_M(:,(resultfile.results_building.list_zones(ii))),'Color','c','LineStyle','-','Marker','d','LineWidth',2);
                                set(gca,'XTick',1:12);
                                set(gca,'xlim',[1,12])
                                grid on
                                title(['Monthly Losses, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)])
                                ylabel('q (kWh/m^2)')
                                xlabel('t (M)')
                                legend('En_T_o','En_T_g','En_T_w','En_T_n','En_V','Orientation','horizontal')
                                hold off

                                figure
                                hold on
                                set(gca,'FontSize',12)
                                plot(1:12, En_S_M(:,(resultfile.results_building.list_zones(ii))),'Color','r','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_I_M(:,(resultfile.results_building.list_zones(ii))),'Color','k','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_H_M(:,(resultfile.results_building.list_zones(ii))),'Color','y','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_C_M(:,(resultfile.results_building.list_zones(ii))),'Color','m','LineStyle','-','Marker','d','LineWidth',2);
                                set(gca,'xlim',[1,12])
                                set(gca,'XTick',1:12);
                                grid on
                                title(['Monthly Gains + Heating and Cooling, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)])
                                ylabel('q (kWh/m^2)')
                                xlabel('t (M)')
                                legend('En_S','En_I','En_H','En_C','Orientation','horizontal')
                                hold off

                                figure
                                hold on
                                set(gca,'FontSize',12)
                                plot(1:12, En_N_sum,'Color','y','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_P_sum,'Color','c','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_H_M(:,(resultfile.results_building.list_zones(ii))),'Color','r','LineStyle','-','Marker','d','LineWidth',2);
                                plot(1:12, En_C_M(:,(resultfile.results_building.list_zones(ii))),'Color','b','LineStyle','-','Marker','d','LineWidth',2);
                                set(gca,'xlim',[1,12])
                                set(gca,'XTick',1:12);
                                grid on
                                title(['Monthly Losses and Gains, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)])
                                ylabel('q (kWh/m^2)')
                                xlabel('t (M)')
                                legend('En_{losses}','En_{gains}','En_H','En_C','Orientation','horizontal')
                                hold off
                            end
                        end

                        En_T_o_M_tot = sum(En_T_o_M,2);
                        En_T_g_M_tot = sum(En_T_g_M,2);
                        En_T_w_M_tot = sum(En_T_w_M,2);
                        En_T_n_M_tot = sum(En_T_n_M,2);
                        En_V_M_tot = sum(En_V_M,2);
                        En_S_M_tot = sum(En_S_M,2);
                        En_I_M_tot = sum(En_I_M,2);
                        En_H_M_tot = sum(En_H_M,2);
                        En_C_M_tot = sum(En_C_M,2);

                        En_N_sum_tot = -En_T_o_M_tot-En_T_g_M_tot -En_T_w_M_tot -En_T_n_M_tot -En_V_M_tot ;
                        En_P_sum_tot = En_S_M_tot +En_I_M_tot;
                         
                        if nargin == 4
                        	scrsz = get(0,'ScreenSize');

                            f23=figure('Position',[scrsz(3)*2/4+10 scrsz(4)*0/3+10 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                            f24=figure('Position',[scrsz(3)*3/4+10 scrsz(4)*0/3+10 scrsz(3)*1/4-10 scrsz(4)*1/4-10]);clf;
                            figure(f23)
                        else
                            figure
                        end
                        hold on
                        set(gca,'FontSize',12)
                        plot(1:12, En_T_o_M_tot,'Color','r','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_T_g_M_tot,'Color','k','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_T_w_M_tot,'Color','y','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_T_n_M_tot,'Color','m','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_V_M_tot,'Color','c','LineStyle','-','Marker','d','LineWidth',2);
                        set(gca,'xlim',[1,12])
                        set(gca,'XTick',1:12);
                        grid on
                        title('Monthly Losses, Total')
                        ylabel('q (kWh/m^2)')
                        xlabel('t (M)')
                        legend('En_T_o','En_T_g','En_T_w','En_T_n','En_V','Orientation','horizontal')
                        hold off

                        if nargin == 4
                            figure(f24)
                        else
                            figure
                        end
                        hold on
                        set(gca,'FontSize',12)
                        plot(1:12, En_S_M_tot,'Color','r','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_I_M_tot,'Color','k','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_H_M_tot,'Color','y','LineStyle','-','Marker','d','LineWidth',2);
                        plot(1:12, En_C_M_tot,'Color','m','LineStyle','-','Marker','d','LineWidth',2);
                        set(gca,'xlim',[1,12])
                        set(gca,'XTick',1:12);
                        grid on
                        title('Monthly Gains + Heating and Cooling, Total')
                        ylabel('q (kWh/m^2)')
                        xlabel('t (M)')
                        legend('En_S','En_I','En_H','En_C','Orientation','horizontal')
                        hold off
                        
                        if nargin == 3
                            figure
                            hold on
                            set(gca,'FontSize',12)
                            plot(1:12, En_N_sum_tot,'Color','r','LineStyle','-','Marker','d','LineWidth',2);
                            plot(1:12, En_P_sum_tot,'Color','k','LineStyle','-','Marker','d','LineWidth',2);
                            plot(1:12, En_H_M_tot,'Color','y','LineStyle','-','Marker','d','LineWidth',2);
                            plot(1:12, En_C_M_tot,'Color','m','LineStyle','-','Marker','d','LineWidth',2);
                            set(gca,'xlim',[1,12])
                            set(gca,'XTick',1:12);
                            grid on
                            title('Monthly Losses and Gains, Total')
                            ylabel('q (kWh/m^2)')
                            xlabel('t (M)')
                            legend('En_{losses}','En_{gains}','En_{H}','En_{C}','Orientation','horizontal')
                            hold off
                        end
                    end
                end
            end
        end
        
        function plot_heat_cool_power(obj, number_result, build)
            % plots the heating and cooling power in the year for every
            % zone and for the total building
            % 1 ... number of the result
            % 2 ... building object
            % NOTE: no output because you can have them with the function different_monthly_energies
            disp(' ')
            disp(['Result number ' num2str(number_result) ': PLOT HEATING AND COOLING POWER'])
            
            [En Pow Area] = different_monthly_energies(obj, number_result, build, 1, 1);
            
            loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name
            if exist(loaddir, 'file') == 2
                resultfile = load(loaddir);
                for ii = 1:length(resultfile.results_building.list_zones)
                    figure
                    plot(Pow.H_hourly(resultfile.results_building.list_zones(ii)))
                    title(['Heating Power, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                    xlabel('Time')
                    ylabel('Power [W]')
                    grid on
                    xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                end

                figure
                plot(Pow.H_tot_hourly)
                title(['Total Heating Power']);
                xlabel('Time')
                ylabel('Power [W]')
                grid on
                xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])

                for ii = 1:length(resultfile.results_building.list_zones)
                    figure
                    plot(Pow.C_hourly(resultfile.results_building.list_zones(ii)))
                    title(['Cooling Power, ' num2str(resultfile.results_building.building_saved.thermalzone.zone(resultfile.results_building.list_zones(ii)).name)]);
                    xlabel('Time')
                    ylabel('Power [W]')
                    grid on
                    xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
                end

                figure
                plot(Pow.C_tot_hourly)
                title(['Total Cooling Power']);
                xlabel('Time')
                ylabel('Power [W]')
                grid on
                xlim([datetime('31-Dec-2014 23:59:00') datetime('01-Jan-2016 00:00:00')])
            end
        end
       
        function plot(obj, number_result, build)
            disp(' ')
            disp(['Result number ' num2str(number_result) ': PLOT THE MOST IMPORTANT VALUES'])
            % obtain all the general plots of the result number 
            % "number_result"
            % 1 ... number of the result
            % 2 ... building object
            obj.plot_zones_thC(number_result, build, 'rel','ppm',1);
            obj.energy_demand(number_result, build, 1);
            obj.different_monthly_energies(number_result, build, 1);
            obj.plot_heat_temp_hours(number_result, build, 1);
            obj.plot_temp_amb_buil_soil(number_result, build, 1);
            obj.plot_temperature_arranged_hours(number_result, build, 1);
            obj.plot_monthly_losses_gains(number_result, build, 1);
        end
        
        function [PHPP Simu] = compare_with_PHPP(obj, number_result, build,  name_xls_PHPP, language, version)
            % comparison with PHPP: plot the comparison between the
            % losses, gains, heating demand and cooling demand and display
            %the heating demand and heat load, cooling demand and cool load
            % 1 ... number of the results
            % 2 ... building object
            % 3 ... name of the file xls of the PHPP
            % 4 ... language: 1:german, 0:english
            % 5 ... version of PHPP used
            
            filename = name_xls_PHPP;
            
            switch version
                case '9.1'
                    if language
                        sheet = 'Heizung';
                    else
                        sheet = 'Heating';
                    end
                    range = 'C13:AE65';
                    
                    vollpfad = [pwd '\' filename]
            
                    if exist(vollpfad, 'file')
                        warning('Existing Excel file used.')
                    else
                        error('Excel file not existing!')
                    end

                    Excel = actxserver('Excel.Application');
                    Excel.Workbooks.Open(vollpfad);
                    warning('Excel file opened! Do not interrupt this script!')

                    [~, ~, data] = xlsread1(filename, sheet, range);
                    
                    Excel.Quit
                    Excel.delete
                    clear Excel
                    warning('Excel file closed!')
            
                    index_raw_daydegree_amb = 1;
                    index_raw_daydegree_gro = 2;
                    index_column_daydegree = 18:29;
                    index_raw_t = 2:13;
                    index_column_name_t = 1;
                    index_column_codezone_t = 4;
                    index_column_area_t = 5;
                    index_column_U_t = 7;
                    index_column_red_t = 9;
                    index_raw1_v = 23;
                    index_column_ratetot_v = 13;
                    index_column_rateinf_v = 11;
                    index_raw2_v = 28;
                    index_column_volume_v = 5;
                    index_column_c_v = 9;
                    index_raw_solar = 6:10;
                    index_raw_solar_op = 11;
                    index_raw_heatdem = 15;
                    index_column_solar = 18:29;
                    index_raw_int = 12;
                    index_column_int = 18:29;
                    index_raw_area = 19;
                    index_column_area = 9;
                    if language
                        sheet = 'Kühlung';
                    else
                        sheet = 'Cooling';
                    end
                    range = 'C14:AE76';
                    
                    Excel = actxserver('Excel.Application');
                    Excel.Workbooks.Open(vollpfad);
                    warning('Excel file opened! Do not interrupt this script!')

                    [~, ~, data1] = xlsread1(filename, sheet, range);
                    
                    Excel.Quit
                    Excel.delete
                    clear Excel
                    warning('Excel file closed!')
                    
                    index_raw1_v_c = 34;
                    index_raw2_v_c = 39;
                    index_raw_solar_c = 7:11;
                    index_raw_int_c = 13;
                    index_raw_cooldem = 16;
                    if language
                        sheet = 'Heizlast';
                    else
                        sheet = 'Heating load';
                    end
                    range = 'Q90';
                    
                    Excel = actxserver('Excel.Application');
                    Excel.Workbooks.Open(vollpfad);
                    warning('Excel file opened! Do not interrupt this script!')

                    [~, ~, data2] = xlsread1(filename, sheet, range);
                    
                    Excel.Quit
                    Excel.delete
                    clear Excel
                    warning('Excel file closed!')
                    
                    if language
                        sheet = 'Kühllast';
                    else
                        sheet = 'Cooling load';
                    end
                    range = 'Q62';
                    
                    Excel = actxserver('Excel.Application');
                    Excel.Workbooks.Open(vollpfad);
                    warning('Excel file opened! Do not interrupt this script!')

                    [~, ~, data3] = xlsread1(filename, sheet, range);
                    
                    Excel.Quit
                    Excel.delete
                    clear Excel
                    warning('Excel file closed!')
                    
            end
            for ii = 1: length(index_column_daydegree)
                PHPP.daydegree_amb_w(ii,1) = data{index_raw_daydegree_amb,index_column_daydegree(ii)};
                PHPP.daydegree_gro_w(ii,1) = data{index_raw_daydegree_gro,index_column_daydegree(ii)};
                PHPP.daydegree_amb_s(ii,1) = data1{index_raw_daydegree_amb,index_column_daydegree(ii)};
                PHPP.daydegree_gro_s(ii,1) = data1{index_raw_daydegree_gro,index_column_daydegree(ii)};
            end
            
            PHPP.En.T_op_w = zeros(12,1);
            PHPP.En.T_op_s = zeros(12,1);
            for ii = 1:length(index_raw_t)
                if strcmp(data{index_raw_t(ii),index_column_area_t},'')
                else
                    if strcmp(data{index_raw_t(ii),index_column_codezone_t},'A')
                        if language && ~strcmp(data{index_raw_t(ii),index_column_name_t},'Fenster')
                            PHPP.En.T_op_w = PHPP.En.T_op_w + data{index_raw_t(ii),index_column_area_t} * data{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_amb_w;
                            PHPP.En.T_op_s = PHPP.En.T_op_s + data1{index_raw_t(ii),index_column_area_t} * data1{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_amb_s;
                        elseif language==0 && ~strcmp(data{index_raw_t(ii),index_column_name_t},'Window')
                            PHPP.En.T_op_w = PHPP.En.T_op_w + data{index_raw_t(ii),index_column_area_t} * data{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_amb_w;
                            PHPP.En.T_op_s = PHPP.En.T_op_s + data1{index_raw_t(ii),index_column_area_t} * data1{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_amb_s;
                        end
                    end
                end
            end
            loaddir = eval(['''' build '\result_' num2str(number_result) '.mat''']); %build.name 
            if exist(loaddir, 'file') == 2
                resultfile = load(loaddir);
                if strcmp(resultfile.results_building.PHPP.choice_modelconswall, 'RC')
                    for ii = 1:length(index_column_solar)
                        PHPP.En.T_op_w(ii,1) = PHPP.En.T_op_w(ii,1) - data{index_raw_solar_op,index_column_solar(ii)};
                        PHPP.En.T_op_s(ii,1) = PHPP.En.T_op_s(ii,1) - data{index_raw_solar_op,index_column_solar(ii)};
                    end
                end
                PHPP.En.T_n_w = zeros(12,1);
                PHPP.En.T_n_s = zeros(12,1);
                for ii = 1:length(index_raw_t)
                    if strcmp(data{index_raw_t(ii),index_column_area_t},'')
                    else
                        if strcmp(data{index_raw_t(ii),index_column_codezone_t},'X')
                           PHPP.En.T_n_w = PHPP.En.T_n_w + data{index_raw_t(ii),index_column_area_t} * data{index_raw_t(ii),index_column_U_t} * data{index_raw_t(ii),index_column_red_t} * PHPP.daydegree_amb_w;
                           PHPP.En.T_n_s = PHPP.En.T_n_s + data1{index_raw_t(ii),index_column_area_t} * data1{index_raw_t(ii),index_column_U_t} * data1{index_raw_t(ii),index_column_red_t} * PHPP.daydegree_amb_s;
                        end
                    end
                end
                PHPP.En.T_g_w = zeros(12,1);
                PHPP.En.T_g_s = zeros(12,1);
                for ii = 1:length(index_raw_t)
                    if strcmp(data{index_raw_t(ii),index_column_area_t},'')
                    else
                        if strcmp(data{index_raw_t(ii),index_column_codezone_t},'B') || strcmp(data{index_raw_t(ii),index_column_codezone_t},'P')
                            PHPP.En.T_g_w = PHPP.En.T_g_w + data{index_raw_t(ii),index_column_area_t} * data{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_gro_w;
                            PHPP.En.T_g_s = PHPP.En.T_g_s + data1{index_raw_t(ii),index_column_area_t} * data1{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_gro_s;
                        end
                    end
                end
                PHPP.En.T_wi_w = zeros(12,1);
                PHPP.En.T_wi_s = zeros(12,1);
                for ii = 1:length(index_raw_t)
                    if strcmp(data{index_raw_t(ii),index_column_area_t},'')
                    else
                        if strcmp(data{index_raw_t(ii),index_column_name_t},'Fenster') || strcmp(data{index_raw_t(ii),index_column_name_t},'Window')
                            PHPP.En.T_wi_w = PHPP.En.T_wi_w + data{index_raw_t(ii),index_column_area_t} * data{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_amb_w;
                            PHPP.En.T_wi_s = PHPP.En.T_wi_s + data1{index_raw_t(ii),index_column_area_t} * data1{index_raw_t(ii),index_column_U_t} * PHPP.daydegree_amb_s;
                        end
                    end
                end

                PHPP.En.V_m_w = ((data{index_raw1_v,index_column_ratetot_v}-data{index_raw1_v,index_column_rateinf_v}) * data{index_raw2_v,index_column_volume_v} * data{index_raw2_v,index_column_c_v} ) * PHPP.daydegree_amb_w;
                PHPP.En.V_i_w = (data{index_raw1_v,index_column_rateinf_v} * data{index_raw2_v,index_column_volume_v} * data{index_raw2_v,index_column_c_v} ) * PHPP.daydegree_amb_w;

                PHPP.En.V_m_s = ((data1{index_raw1_v_c,index_column_ratetot_v}-data1{index_raw1_v_c,index_column_rateinf_v}) * data1{index_raw2_v_c,index_column_volume_v} * data1{index_raw2_v_c,index_column_c_v} ) * PHPP.daydegree_amb_s;
                PHPP.En.V_i_s = (data1{index_raw1_v_c,index_column_rateinf_v} * data1{index_raw2_v_c,index_column_volume_v} * data1{index_raw2_v_c,index_column_c_v} ) * PHPP.daydegree_amb_s;

                matrix_solar_w = zeros(1,12);
                matrix_solar_s = zeros(1,12);
                for ii = 1:length(index_raw_solar)
                    for jj = 1:length(index_column_solar)
                        matrix_solar_w(ii,jj) = data{index_raw_solar(ii),index_column_solar(jj)};
                        matrix_solar_s(ii,jj) = data1{index_raw_solar_c(ii),index_column_solar(jj)};
                    end
                end

                PHPP.En.S_w = sum(matrix_solar_w,1);
                PHPP.En.S_w = PHPP.En.S_w';

                PHPP.En.S_s = sum(matrix_solar_s,1);
                PHPP.En.S_s = PHPP.En.S_s';

                PHPP.En.I_w = zeros(12,1);
                PHPP.En.I_s = zeros(12,1);
                for ii = 1:length(index_column_int)
                    PHPP.En.I_w(ii,1) = data{index_raw_int,index_column_int(ii)};
                    PHPP.En.I_s(ii,1) = data1{index_raw_int_c,index_column_int(ii)};
                end

                PHPP.En.Heating = zeros(12,1);
                PHPP.En.Cooling = zeros(12,1);
                for ii = 1:length(index_column_int)
                    PHPP.En.Heating(ii,1) = data{index_raw_heatdem,index_column_int(ii)};
                    PHPP.En.Cooling(ii,1) = data1{index_raw_cooldem,index_column_int(ii)};
                end

                win_1(1:5) = 1:5;
                summ(1:3) = 6:8;
                win_2(1:4) = 9:12;

                PHPP.En.T_op(1:12,1) = [PHPP.En.T_op_w(win_1)' PHPP.En.T_op_s(summ)' PHPP.En.T_op_w(win_2)'];
                PHPP.En.T_g(1:12,1) = [PHPP.En.T_g_w(win_1)' PHPP.En.T_g_s(summ)' PHPP.En.T_g_w(win_2)'];
                PHPP.En.T_wi(1:12,1) = [PHPP.En.T_wi_w(win_1)' PHPP.En.T_wi_s(summ)' PHPP.En.T_wi_w(win_2)'];
                PHPP.En.T_n(1:12,1) = [PHPP.En.T_n_w(win_1)' PHPP.En.T_n_s(summ)' PHPP.En.T_n_w(win_2)']; 
                PHPP.En.V_m(1:12,1) = [PHPP.En.V_m_w(win_1)' PHPP.En.V_m_s(summ)' PHPP.En.V_m_w(win_2)'];
                PHPP.En.V_i(1:12,1) = [PHPP.En.V_i_w(win_1)' PHPP.En.V_i_s(summ)' PHPP.En.V_i_w(win_2)'];
                PHPP.En.S(1:12,1) = [PHPP.En.S_w(win_1)' PHPP.En.S_s(summ)' PHPP.En.S_w(win_2)'];
                PHPP.En.I(1:12,1) = [PHPP.En.I_w(win_1)' PHPP.En.I_s(summ)' PHPP.En.I_w(win_2)']; 
                PHPP.En.Heating(1:12,1) = PHPP.En.Heating';
                PHPP.En.Cooling(1:12,1) = PHPP.En.Cooling';

                [Simu.En Simu.Pow] = obj.different_monthly_energies(number_result, build,  1, 1);

                figure
                hold on
                bar1 = bar(1:12, [-PHPP.En.T_op Simu.En.T_o_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Transmission Losses Opaque'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [-PHPP.En.T_g Simu.En.T_g_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Transmission Losses Ground'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [-PHPP.En.T_wi Simu.En.T_w_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Transmission Losses Window'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [-PHPP.En.T_n Simu.En.T_n_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Transmission Losses Neighbour'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [-PHPP.En.V_m Simu.En.V_m_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Ventilation Losses Mechanical'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [-PHPP.En.V_i Simu.En.V_i_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Ventilation Losses Infiltration'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [PHPP.En.S Simu.En.S_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Solar Gains'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [PHPP.En.I Simu.En.I_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Internal Gains'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [PHPP.En.Heating Simu.En.H_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Heating Demand'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                figure
                hold on
                bar1 = bar(1:12, [PHPP.En.Cooling Simu.En.C_M_A_tot]);
                set(bar1, 'BarWidth',.75)
                set(bar1(1),'FaceColor','red');  set(bar1(2),'FaceColor','blue');
                legend('PHPP', 'Simulation', 'Orientation', 'horizontal')
                title(['Monthly Cooling Demand'])
                ylabel('Energy (kWh)')
                xlabel('Time (M)')
                set(gca,'XTick',1:12);
                set(gca,'xlim',[0.5,12.5])
                grid on
                hold off

                for ii = 1:12
                    if PHPP.En.Heating(ii,1)<0
                        PHPP_sum_value(ii) = 0;
                    else
                        PHPP_sum_value(ii) = PHPP.En.Heating(ii,1);
                    end
                        PHPP_sum_value_c(ii) = PHPP.En.Cooling(ii,1);
                end
                for ii = 1:12
                    if Simu.En.H_M_A_tot(ii,1)<0
                        SIM_sum_value(ii) = 0;
                    else
                        SIM_sum_value(ii) = Simu.En.H_M_A_tot(ii,1);
                    end
                        SIM_sum_value_c(ii) = Simu.En.C_M_A_tot(ii,1);
                end
                PHPP.En.Heating(13,1) = sum(PHPP_sum_value);
                Simu.En.H_M_A_tot(13,1) = sum(SIM_sum_value);
                PHPP.En.Cooling(13,1) = sum(PHPP_sum_value_c);
                Simu.En.C_M_A_tot(13,1) = sum(SIM_sum_value_c);
                for ii = 1:13
                    En_PHPP_h(ii) = (PHPP.En.Heating(ii,1)/data{index_raw_area,index_column_area});
                    En_sim_h(ii) = (Simu.En.H_M_A_tot(ii,1)/data{index_raw_area,index_column_area});
                    En_PHPP_c(ii) = (PHPP.En.Cooling(ii,1)/data{index_raw_area,index_column_area});
                    En_sim_c(ii) = (Simu.En.C_M_A_tot(ii,1)/data{index_raw_area,index_column_area});
                end
                PHPP_heatdem = energy2str(obj,En_PHPP_h);
                SIM_heatdem = energy2str(obj,En_sim_h);
                PHPP_cooldem = energy2str(obj,En_PHPP_c);
                SIM_cooldem = energy2str(obj,En_sim_c);

                for ii = 1:length(resultfile.results_building.list_zones)
                    if resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 0
                        mod = 'none/temperature';
                    elseif resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 1
                        mod = 'ideal';
                    elseif resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 2
                        mod = '1-node';
                    elseif resultfile.results_building.building_saved.thermalzone.zone(1,resultfile.results_building.list_zones(ii)).model == 3
                        mod = '2-node';
                    end
                end
                disp (['Model Simualtion: ' mod])


                disp(' ')
                disp('    COMPARISON MONTHLY HEATING DEMAND  ')
                disp(' ')
                disp('          PHPP              Simulation')
                disp(' ')
                disp(['Jan:   ' PHPP_heatdem(1,:) ' kWh/m²    ' SIM_heatdem(1,:) ' kWh/m²'])
                disp(['Feb:   ' PHPP_heatdem(2,:) ' kWh/m²    ' SIM_heatdem(2,:) ' kWh/m²'])
                disp(['Mar:   ' PHPP_heatdem(3,:) ' kWh/m²    ' SIM_heatdem(3,:) ' kWh/m²'])
                disp(['Apr:   ' PHPP_heatdem(4,:) ' kWh/m²    ' SIM_heatdem(4,:) ' kWh/m²'])
                disp(['Mai:   ' PHPP_heatdem(5,:) ' kWh/m²    ' SIM_heatdem(5,:) ' kWh/m²'])
                disp(['Jun:   ' PHPP_heatdem(6,:) ' kWh/m²    ' SIM_heatdem(6,:) ' kWh/m²'])
                disp(['Jul:   ' PHPP_heatdem(7,:) ' kWh/m²    ' SIM_heatdem(7,:) ' kWh/m²'])
                disp(['Aug:   ' PHPP_heatdem(8,:) ' kWh/m²    ' SIM_heatdem(8,:) ' kWh/m²'])
                disp(['Sep:   ' PHPP_heatdem(9,:) ' kWh/m²    ' SIM_heatdem(9,:) ' kWh/m²'])
                disp(['Oct:   ' PHPP_heatdem(10,:) ' kWh/m²    ' SIM_heatdem(10,:) ' kWh/m²'])
                disp(['Nov:   ' PHPP_heatdem(11,:) ' kWh/m²    ' SIM_heatdem(11,:) ' kWh/m²'])
                disp(['Dec:   ' PHPP_heatdem(12,:) ' kWh/m²    ' SIM_heatdem(12,:) ' kWh/m²'])
                disp(' ')
                disp(['Tot:   ' PHPP_heatdem(13,:) ' kWh/m²    ' SIM_heatdem(13,:) ' kWh/m²'])

                disp(' ')
                disp('    COMPARISON MONTHLY COOLING DEMAND  ')
                disp(' ')
                disp('          PHPP              Simulation')
                disp(' ')
                disp(['Mai:   ' PHPP_cooldem(5,:) ' kWh/m²    ' SIM_cooldem(5,:) ' kWh/m²'])
                disp(['Jun:   ' PHPP_cooldem(6,:) ' kWh/m²    ' SIM_cooldem(6,:) ' kWh/m²'])
                disp(['Jul:   ' PHPP_cooldem(7,:) ' kWh/m²    ' SIM_cooldem(7,:) ' kWh/m²'])
                disp(['Aug:   ' PHPP_cooldem(8,:) ' kWh/m²    ' SIM_cooldem(8,:) ' kWh/m²'])
                disp(['Sep:   ' PHPP_cooldem(9,:) ' kWh/m²    ' SIM_cooldem(9,:) ' kWh/m²'])
                disp(' ')
                disp(['Tot:   ' PHPP_cooldem(13,:) ' kWh/m²    ' SIM_cooldem(13,:) ' kWh/m²'])

                PHPP_heatload = num2str(data2/data{index_raw_area,index_column_area});
                PHPP_coolload = num2str(data3/data{index_raw_area,index_column_area});
                SIM_heatload = num2str(max(Simu.Pow.H_tot.Data)/data{index_raw_area,index_column_area});
                SIM_coolload = num2str(max(Simu.Pow.C_tot.Data)/data{index_raw_area,index_column_area});

                for ll = 1:size(PHPP_heatload,2)
                    if strcmp(PHPP_heatload(ll), '.')
                        ind = ll;
                    end
                end
                if (size(PHPP_heatload,2)-ind)==2
                elseif (size(PHPP_heatload,2)-ind)>2
                    PHPP_heatload = num2str(round(str2num(PHPP_heatload)*100)/100);
                    PHPP_heatload(:,ind+3:end) = [];
                end
                for ll = 1:size(PHPP_coolload,2)
                    if strcmp(PHPP_coolload(ll), '.')
                        ind = ll;
                    end
                end
                if (size(PHPP_coolload,2)-ind)==2
                elseif (size(PHPP_coolload,2)-ind)>2
                    PHPP_coolload = num2str(round(str2num(PHPP_coolload)*100)/100);
                    PHPP_coolload(:,ind+3:end) = [];
                end
                for ll = 1:size(SIM_heatload,2)
                    if strcmp(SIM_heatload(ll), '.')
                        ind = ll;
                    end
                end
                if (size(SIM_heatload,2)-ind)==2
                elseif (size(SIM_heatload,2)-ind)>2
                    SIM_heatload = num2str(round(str2num(SIM_heatload)*100)/100);
                    SIM_heatload(:,ind+3:end) = [];
                end
                for ll = 1:size(SIM_coolload,2)
                    if strcmp(SIM_coolload(ll), '.')
                        ind = ll;
                    end
                end
                if (size(SIM_coolload,2)-ind)==2
                elseif (size(SIM_coolload,2)-ind)>2
                    SIM_coolload = num2str(round(str2num(SIM_coolload)*100)/100);
                    SIM_coolload(:,ind+3:end) = [];
                end

                disp(' ')
                disp('     COMPARISON HEATING LOAD      ')
                disp(' ')
                disp('           PHPP            Simulation')
                disp(' ')
                disp(['           ' PHPP_heatload ' W/m²       ' SIM_heatload ' W/m²'])

                disp(' ')
                disp('     COMPARISON COOLING LOAD      ')
                disp(' ')
                disp('           PHPP            Simulation')
                disp(' ')
                disp(['           ' PHPP_coolload ' W/m²       ' SIM_coolload ' W/m²'])

                disp(' ')
                disp(['HEATED AREA: ' num2str(data{index_raw_area,index_column_area}) ' m²'])
                disp(' ')
            end
        end
    end
    
    methods (Access = private)
        function rh = fun_rel_hum(obj, theta, x, pres)
            % to calculate the relative humidity from the absolute humidity
            % 1 ... temperature in °C
            % 2 ... absolute humidity
            % 3 ... pressure

            ps = exp(23.462-(3978.205 ./ (233.349+theta)) ); %% for theta>0 based on Bauphysik presentations
            rh = x./(x+0.622) .* (pres./ps);
        end
        
        function x = fun_hum_ratio(obj, theta, phi, pres)
            % to calculate the absolute humidity from the relative humidity
            % 1 ... temperature in °C
            % 2 ... relative humidity
            % 3 ... pressure
            
            if(max(phi)>1);  phi = phi./100; end
            ps = exp(23.462-(3978.205 ./ (233.349+theta)) ); %% for theta>0 based on Bauphysik presentations
            x = 0.622.*(ps./((pres./phi)-ps));
        end
        
        function En_M = energy2months(obj, En)
            % to calculate the monthly energy from a object of energy
            % 1 ... object of energy
            T_m = 365*24*3600 + ([0 31 (28+31) (31+28+31) (30+31+28+31) (31+30+31+28+31) (30+31+30+31+28+31) (31+30+31+30+31+28+31) (31+31+30+31+30+31+28+31) (30+31+31+30+31+30+31+28+31) (31+30+31+31+30+31+30+31+28+31) (30+31+30+31+31+30+31+30+31+28+31) (31+30+31+30+31+31+30+31+30+31+28+31)]*24*3600);

            for jj = 1:12
                En_M(jj) = En.Data(En.Time == T_m(jj+1)) - En.Data(En.Time == T_m(jj));
            end

        end
        
        function str_en = energy2str(obj,En)
            % to prepare the string to display the numbers in order to have
            % always nnnn.nn
            for ii = 1:13
                heat_dem = '';
                heat_dem = num2str(En(ii));
                heat_dem = num2str(round(str2num(heat_dem)*100)/100);
                ind = [];
                for ll = 1 : size(heat_dem(:),1)
                    if strcmp(heat_dem(ll),'.')
                        ind = ll;
                        break
                    else
                    end
                end
                heat_dem_temp = '';
                if ind == 5
                    heat_dem_temp = heat_dem;
                elseif ind == 4
                    heat_dem_temp(1) = ' ';
                    for mm = 1:size(heat_dem(:),1)
                        heat_dem_temp(1+mm) = heat_dem(mm);
                    end 
                elseif ind == 3
                    heat_dem_temp(1) = ' ';
                    heat_dem_temp(2) = ' ';
                    for mm = 1:size(heat_dem(:),1)
                        heat_dem_temp(2+mm) = heat_dem(mm);
                    end    
                elseif ind == 2
                    heat_dem_temp(1) = ' ';
                    heat_dem_temp(2) = ' ';
                    heat_dem_temp(3) = ' ';
                    for mm = 1:size(heat_dem(:),1)
                        heat_dem_temp(3+mm) = heat_dem(mm);
                    end
                end
                heat_dem = heat_dem_temp;
                ind = [];
                for ll = 1 : size(heat_dem(:),1)
                    if strcmp(heat_dem(ll),'.')
                        ind = ll;
                        break
                    else
                    end
                end
                if ind == 5
                    if (size(heat_dem(:),1)-ind)==2
                    elseif (size(heat_dem(:),1)-ind)>2
                        heat_dem(:,ind+3:end) = [];
                    elseif (size(heat_dem(:),1)-ind)==1
                        heat_dem(:,ind+2) = '0';
                    elseif (size(heat_dem(:),1)-ind)==0
                        heat_dem(:,ind+1) = '0';
                        heat_dem(:,ind+2) = '0';
                    end
                else
                    heat_dem(:,1) = ' ';
                    heat_dem(:,2) = ' ';
                    heat_dem(:,3) = ' ';
                    heat_dem(:,4) = '0';
                    heat_dem(:,5) = '.';
                    heat_dem(:,6) = '0';
                    heat_dem(:,7) = '0';
                end
                str_en(ii,:) = heat_dem;
            end
        end
    
        function [new_ts] = preparedata(obj, ts, timestep)
            % to convert a time serie in hourly or daily values
            % 1 ... time serie
            % 2 ... timestep: 5: minute long values, 4: hourly value, 3:
            % daily value
            
            [Y, M, D, H, MN, S] = datevec(ts.Time/3600/24);
            % [Y, M, D, H, MN, S] = datevec(TIME_Jun');
            In = [Y M D H MN ts.Data];
            [unDates,trash,IDX] = unique(In(:,1:timestep),'rows'); 
            Out = [unDates zeros(size(unDates,1),1)]; 
            for d = 1:size(unDates,1)
                Out(d,end) = nanmean(In(IDX == d,end));
            end 

            data = Out(:,end);

            switch timestep
                case 5      % minute
                    time = datenum(Out(:,1),Out(:,2),Out(:,3),Out(:,4),Out(:,5),zeros(size(unDates,1),1));
                case 4      % hour
                    time = datenum(Out(:,1),Out(:,2),Out(:,3),Out(:,4),zeros(size(unDates,1),1),zeros(size(unDates,1),1));
                case 3      % day
                    time = datenum(Out(:,1),Out(:,2),Out(:,3),zeros(size(unDates,1),1),zeros(size(unDates,1),1),zeros(size(unDates,1),1));
            end
            
            new_ts = timeseries(data, time*3600*24);
            new_ts.Name = ts.Name;
            new_ts.DataInfo.Units = ts.DataInfo.Units;
            new_ts.TimeInfo.Units = ts.TimeInfo.Units;
            new_ts.TimeInfo.Format = ts.TimeInfo.Format;
            new_ts.TimeInfo.StartDate = ts.TimeInfo.StartDate;
        end
    
    end
end