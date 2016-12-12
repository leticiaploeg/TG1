% Communicating with the power supply

% PT-BR instructions O que fazer:
        
    % Agilent IO Libraries Suite (Keysight IO Libraries Suite): deve ser
    % instalado antes de conectar o USB/GPIB ao computador. Na instala��o
    % tamb�m tem-se a interface Keysight Connection Expert, que � capaz de
    % identificar o instrumento automaticamente e enviar comandos (COMP ou
    % SCPI). Testar a fonte (TLK e LSN) por meio desta interface.
    
    %Links: Read me da instala��o <goo.gl/rxZlDy>
    % Instala��o <goo.gl/g6IoD4>

    % Fonte operando em SCPI: Para verificar, pressionar o bot�o LCL at�
    % aparecer o endere�o do instrumento "Adr --". No caso de apenas o
    % endere�o prim�rio aparecer, a fonte est� no modo compatibilidade
    % (ARPS). Caso apare�a "SEC --", a fonte est� no modo SCPI e pode ser
    % conectada com o Matlab. A altera��o da linguagem de COMP para SCPI
    % pode ser feita por meio do comando "SYST:LANG TMSL".
    
    % Board Index: Se este valor � dado como x pela leitura do Keysight
    % Connection Expert, deve-se verificar se o Matlab identificou como x.
    % Isso pode ser feito por meio do comando "tmtool". Procure pelo
    % instrumento na op��o "Scan" e verifique o valor board index. Utilize
    % este valor na declara��o do objeto GPIB.

% EN-US instructions What you should do:
        
    % Agilent IO Libraries Suite (Keysight IO Libraries Suite): must be
    % installed before connecting the USB/GPIB to the computer.
    % Installation process suggests installing Keysight Connection Expert,
    % a software capable of automatically identify the instrument and send
    % commands (COMP or SCPI). Test the supply (TLK and LSN) with this
    % software.
    
    %Links: Installation read me <goo.gl/rxZlDy>
    % Installation <goo.gl/g6IoD4>

    % SCPI operation mode: To verify that, press the LCL button until the
    % instrument address "Adr --" shows up. In case of only the primary
    % address shows up, the power supply is in compatibility mode(ARPS). If
    % "SEC --" shows up, the power supply is in SCPI mode and can be
    % connected with Matlab. The language change can be done by using the
    % command "SYST:LANG TMSL".
    
    % Board Index: If this value is given by 'x' by Keysight Connection
    % Expert, you must verify if Matlab also identified 'x'. This can be
    % done with the command "tmtool". Search for the instrument on "Scan"
    % option and verify the board index value. Use this value on the
    % declaration of the GPIB object.
    
clear;

% Inicializing

% Identify earth magnetic field at a point of the orbit: wlrdmagm(height,
% lat, lon, dyear)
[xyz, h, dec, dip, f] = wrldmagm(1000, 42.283, -71.35, decyear(2010,12,11),'2010')
perm = 4.95e-5; % Magnetic permeability in vacuum [T-in/A]
N = 40; % Number of coil turns
a = 49.2126; % Half the length of one side of the coil [in]
gama = 0.53; % Ratio between the distance between the coils and 2a
Bx = xyz(1)*0.000000001
By = xyz(2)*0.000000001
Bz = xyz(3)*0.000000001 % Magnetic field on z-axis [T]

Ix = (abs(Bx)*pi*a*(1+gama^2)*sqrt(2+gama^2))/(4*perm*N);
Vx = VoltageCalculationX(Ix);

Iy = (abs(By)*pi*a*(1+gama^2)*sqrt(2+gama^2))/(4*perm*N);
Vy = VoltageCalculationY(Iy)

Iz = (abs(Bz)*pi*a*(1+gama^2)*sqrt(2+gama^2))/(4*perm*N);
Vz = VoltageCalculationZ(Iz);

% Instruments Supply A = Y axis Supply B = Z axis Supply C = X axis

% Creates GPIB object associated to a Agilent instrument (board index 7 and
% primary address 5) and connects with instrument

gb = gpib('agilent',7,5); 
fopen(gb);
gb.EOSMode = 'read&write';
gb.EOSCharCode = 'LF'

ga = visa('agilent', 'GPIB2::5::INSTR');
fopen(ga); 
ga.EOSMode = 'read&write';
ga.EOSCharCode = 'LF'

gc = visa('agilent', 'GPIB1::5::INSTR');
fopen(gc); 
gc.EOSMode = 'read&write';
gc.EOSCharCode = 'LF'

% Program body: Sending SCPI/COMP commands to the power supplies

fprintf(ga,'ERR?');
errA = fscanf(ga)
fprintf(ga,'ID?');
idSupplyA = fscanf(ga)
fprintf(ga,'VOUT?');
vSupplyA = fscanf(ga)
fprintf(ga,'IOUT?');
iSupplyA = fscanf(ga)

fprintf(ga,'ISET 4'); % Current limit value

fprintf(gb,'*IDN?');
idSupplyB = fscanf(gb)
fprintf(gb,'VOLT?');
vSupplyB = fscanf(gb)
fprintf(gb,'MEAS:CURR?');
iSupplyB = fscanf(gb)

fprintf(gb,'CURR 4'); % Current limit value

fprintf(gc,'ERR?');
errC = fscanf(gc)
fprintf(gc,'ID?');
idSupplyC = fscanf(gc)
fprintf(gc,'VOUT?');
vSupplyC = fscanf(gc)
fprintf(gc,'IOUT?');
iSupplyC = fscanf(gc)

fprintf(gc,'ISET 4'); % Current limit value

% Output voltage limit

outputString = sprintf('VSET %d', Vy);
fprintf(ga,outputString);

outputString = sprintf('VSET %d', Vx);
fprintf(gc,outputString);

outputString = sprintf('VOLT %d', Vz);
fprintf(gb,outputString);

% End of program body

fclose(ga); % Closes connection
delete(ga); % Erases GPIB object A
clear ga;

fclose(gb); % Closes connection
delete(gb); % Erases GPIB object B
clear gb;

fclose(gc); % Closes connection
delete(gc); % Erases GPIB object C
clear gc;