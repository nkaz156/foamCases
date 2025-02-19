clear;
clc;
% Constants
g = 9.80665;                  % m/s^2, constant gravity
gamma = 1.4;                  % Specific heat ratio for air
R = 8.314E3;                  % Universal gas constant
cp = 1005;                    % J/(kg·K), specific heat at constant pressure for air
hedge_length = 0.3;           % HEDGE length in meters

% Import Standard Atmosphere Data from https://www.pdas.com/bigtables.html
sa = importStdAtm("StdAtm_0_1000km.csv"); % Standard atmosphere table (Table 1)
sat = import_transport("std_atm_transport.xlsx"); % Atmosphere transport properties (Table 2)

% Provided Parameters
m = 6;                      % Mass in kg
A = 0.01;                     % Frontal area in m^2 (0.1 m x 0.1 m)
theta_deg = 38.37;            % Cone half-angle in degrees
theta_rad = deg2rad(theta_deg);
CD = 2 * sin(theta_rad)^2;    % Drag coefficient
T_wall = 300;                 % HEDGE wall temperature in K

% Initial Conditions
t = 0;                        % Time in seconds
h = 160000;                   % Initial altitude in meters
v = 0;                        % Initial velocity in m/s
dt = 1;                     % Time step in seconds

% Lists to store data
time_list = [];
altitude_list = [];
velocity_list = [];
mach_list = [];
stagnation_temp_list = [];
ref_temp_list = [];
rho_list = [];
a_list = [];
p_atm_list = [];
p_stag_list = [];
gamma_list = [];
dyn_visc_list = [];
Re_list = [];
g_list = [];
Kn_list = [];

% Altitudes to analyze (in meters)
altitudes = [155000, 75000, 50000, 15000];  % Altitude points in meters
static_pressure_list = zeros(size(altitudes));
static_temperature_list = zeros(size(altitudes));
total_pressure_list = zeros(size(altitudes));
total_temperature_list = zeros(size(altitudes));
Reynolds_number_list = zeros(size(altitudes));

% Main Simulation Loop
while h > 0
    h_km = h/1000;
    % Get atmospheric properties
    rho = interp1(sa.Z, sa.rho, h_km, "linear");
    T = interp1(sa.Z, sa.T, h_km, "linear");
    a = interp1(sa.Z, sa.c, h_km, "linear");
    p_atm = interp1(sa.Z, sa.p, h_km, "linear");
    mmass = interp1(sat.htact, sat.molweight, h_km, "linear");
    g = interp1(sa.Z, sa.g, h_km, "linear");
    dyn_visc = interp1(sat.htact, sat.dynvisc, h_km, "linear");



    % Calculate drag force
    D = 0.5 * rho * v^2 * CD * A;
    
    % Update velocity and altitude
    dv = (g - D / m) * dt;

    v = v + dv;
    h = h - v * dt;

    gamma = (mmass*a^2)/(R*T);
    
    % Calculate Mach number and stagnation temperature
    M = v / a;
    T0 = T*(1+((gamma-1)/2)*M^2);
    P0 = p_atm * (1 + (gamma - 1) / 2 * M^2)^(gamma / (gamma - 1));

    % Calculate Reynolds Number:
    Re = (rho * v * hedge_length) / dyn_visc;

    % Calculate Knudsen Number
    Kn = (M/Re) * sqrt((gamma * pi())/(2));
    
    % Record data
    time_list = [time_list; t];
    a_list = [a_list; a];
    rho_list = [rho_list; rho];
    ref_temp_list = [ref_temp_list; T];
    altitude_list = [altitude_list; h]; 
    velocity_list = [velocity_list; v];
    mach_list = [mach_list; M];
    stagnation_temp_list = [stagnation_temp_list; T0];
    p_atm_list = [p_atm_list; p_atm];
    gamma_list = [gamma_list; gamma];
    p_stag_list = [p_stag_list; P0];
    dyn_visc_list = [dyn_visc_list; dyn_visc];
    Re_list = [Re_list, Re];
    g_list = [g_list, g];
    Kn_list = [Kn_list, Kn];
    
    % Update time
    t = t + dt;
    
    % Check if the CubeSat has reached the ground
    if h <= 0
        break;
    end
end

% Extract values at the specified altitudes by interpolating simulation data
for i = 1:length(altitudes)
    h_target = altitudes(i);
    v_target = interp1(altitude_list, velocity_list, h_target, 'linear', 'extrap');
    
    % Atmospheric properties
    rho = interp1(altitude_list, rho_list, h_target, "linear");
    T_atm = interp1(altitude_list, ref_temp_list, h_target, "linear");  % Atmospheric temperature
    P_atm = interp1(altitude_list, p_atm_list, h_target,"linear");      % Static pressure
    a = interp1(altitude_list, a_list, h_target, "linear");             % Speed of sound
    M = interp1(altitude_list, mach_list, h_target, "linear");          % Mach number
    dynvisc = interp1(altitude_list, dyn_visc_list, h_target, "linear"); % Dynamic viscosity
    Kn = interp1(altitude_list, Kn_list, h_target, "linear");          % Knudsen number
    
    % Total (stagnation) temperature and pressure
    T_total = interp1(altitude_list, stagnation_temp_list, h_target, "linear");  % Total temperature
    P_total = interp1(altitude_list, p_stag_list, h_target, "linear"); % Total pressure
    
    % y+ cell size calculations (from
    % https://www.cfd-online.com/Wiki/Y_plus_wall_distance_estimation)
    Re = interp1(altitude_list, Re_list, h_target, "linear"); % Reynolds #
    Cf = (2*log10(Re) - 0.65)^(-2.3); % Schlichting skin-friction correlation (valid for Re < 10e9)
    T_w = Cf * (1/2) * rho * v_target^2; % Wall shear stress
    ustar = sqrt(T_w/rho); % Friction velocity
    y = (1 * dynvisc) / (rho * ustar); % 1 represents desired y-plus
    y_in = y * 39.3701; % convert to inches

    
    % Store results
    static_pressure_list(i) = P_atm;
    static_temperature_list(i) = T_atm;
    total_pressure_list(i) = P_total;
    total_temperature_list(i) = T_total;
    Reynolds_number_list(i) = Re;
    
    % Display results for each altitude
    fprintf('At altitude %.1f km:\n', h_target / 1000);
    fprintf('   Atmospheric temperature: %.2f K\n', T_atm);
    fprintf('   Stagnation temperature: %.2f K\n', T_total);
    fprintf('   Atmospheric pressure: %.2f Pa\n', P_atm);
    fprintf('   Stagnation pressure: %.2f Pa\n', P_total);
    fprintf('   Interpolated velocity: %.2f m/s\n', v_target);
    fprintf('   Mach Number: %.4f\n', M);
    fprintf('   Knudsen Number: %.4f\n', Kn);
    fprintf('   Reynolds number: %.2e\n', Re);
    fprintf('   Density: %.4e kg.m^-3\n', rho);
    fprintf('   Dynamic viscosity: %.4e kg.m^-1.s^-1\n', dynvisc);
    fprintf('   Cell wall distance for y+ = 1: %.4e m, %.4e in\n\n', y, y_in );
end

% Display re-entry results
fprintf('Total time of fall: %.2f seconds\n', t);
fprintf('Maximum Mach number during re-entry: %.2f\n', max(mach_list));

% Plotting results
figure;
subplot(4,1,1);
plot(time_list, altitude_list / 1000);
xlabel('Time (s)');
ylabel('Altitude (km)');
title('Altitude vs Time');

subplot(4,1,2);
plot(time_list, velocity_list / 1000);
xlabel('Time (s)');
ylabel('Velocity (km/s)');
title('Velocity vs Time');

subplot(4,1,3);
plot(time_list, mach_list);
xlabel('Time (s)');
ylabel('Mach Number');
title('Mach Number vs Time');

subplot(4,1,4);
plot(time_list, Re_list);
xlabel('Time (s)');
ylabel('Reynolds Number');
title('Reynolds Number vs Time');

figure;
hold on;
plot(time_list, stagnation_temp_list);
plot(time_list, ref_temp_list);
hold off;
xlabel('Time (s)');
ylabel('Stagnation Temperature (K)');
title('Stagnation Temperature vs Time');
legend('Stagnation Temperature', 'Atmospheric Temperature')

figure;
plot(altitude_list/1000, gamma_list);
xlabel('Altitude (km)');
ylabel('Ratio of Specific Heats (gamma)');
title ('Ratio of Specific Heats vs Altitude');

figure;
plot(altitude_list/1000, Re_list);
xlabel('Altitude (km)');
ylabel('Reynolds Number');
title ('Reynolds Number vs Altitude');

figure;
plot(altitude_list/1000, Kn_list);
xlabel('Altitude (km)');
ylabel('Knudsen Number');
title ('Knudsen Number vs Altitude');