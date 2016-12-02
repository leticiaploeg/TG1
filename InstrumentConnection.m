% Communicating with the power supply

% PT-BR instructions
% O que fazer:
        
    % Agilent IO Libraries Suite (Keysight IO Libraries Suite): deve ser instalado antes de
    % conectar o USB/GPIB ao computador. Na instalação também tem-se a interface Keysight Connection Expert,
    % que é capaz de identificar o instrumento automaticamente e enviar
    % comandos (COMP ou SCPI). Testar a fonte (TLK e LSN) por meio desta interface.
    
    %Links: Read me da instalação <http://www.keysight.com/upload/cmc_upload/All/iols_15_5_readme.htm>
    %       Instalação <http://www.keysight.com/pt/pd-1985909/io-libraries-suite?nid=-33330.977662.00&cc=BR&lc=por&cmpid=zzfindiosuite>        

    % Fonte operando em SCPI: Para verificar, pressionar o botão LCL até
    % aparecer o endereço do instrumento "Adr --". No caso de apenas o endereço
    % primário aparecer, a fonte está no modo compatibilidade (ARPS). Caso
    % apareça "SEC --", a fonte está no modo SCPI e pode ser conectada com
    % o Matlab. A alteração da linguagem de COMP para SCPI pode ser feita por meio do comando
    % "SYST:LANG TMSL".
    
    % Board Index: Se este valor é dado como x pela leitura do Keysight
    % Connection Expert, deve-se verificar se o Matlab identificou como x.
    % Isso pode ser feito por meio do comando "tmtool". Procure pelo
    % instrumento na opção "Scan" e verifique o valor board index. Utilize
    % este valor na declaração do objeto GPIB.

% EN-US instructions
% What you should do:
        
    % Agilent IO Libraries Suite (Keysight IO Libraries Suite): must be
    % installed before connecting the USB/GPIB to the computer. Installation
    % process suggests installing Keysight Connection Expert, a software
    % capable of automatically identify the instrument and send commands
    % (COMP or SCPI). Test the supply (TLK and LSN) with this software.
    
    %Links: Installation read me <http://www.keysight.com/upload/cmc_upload/All/iols_15_5_readme.htm>
    %       Installation <http://www.keysight.com/pt/pd-1985909/io-libraries-suite?nid=-33330.977662.00&cc=BR&lc=por&cmpid=zzfindiosuite>        

    % SCPI operation mode: To verify that, press the LCL button until the instrument address "Adr --" shows up.
    % In case of only the primary address shows up, the power supply is in
    % compatibility mode(ARPS). If "SEC --" shows up, the power supply is in SCPI mode and can be connected
    % with Matlab. The language change can be done by using the command "SYST:LANG TMSL".
    
    % Board Index: If this value is given by 'x' by Keysight Connection
    % Expert, you must verify if Matlab also identified 'x'. This can be
    % done with the command "tmtool". Search for the instrument on "Scan"
    % option and verify the board index value. Use this value on the
    % declaration of the GPIB object.
    
clear;

% Inicializing

% Identify earth magnetic field at a point of the orbit: wlrdmagm(height, lat, lon, dyear)
[xyz, h, dec, dip, f] = wrldmagm(1000, 42.283, -71.35, decyear(2010,7,4),'2010')
perm = 4.95e-5; % Magnetic permeability in vacuum [T-in/A]
N = 40; % Number of coil turns
a = 49.2126; % Half the length of one side of the coil [in]
gama = 0.53; % Ratio between the distance between the coils and 2a
%Bx = xyz(1)*0.000000001
%By = xyz(2)*0.000000001
Bz = xyz(3)*0.000000001 % Magnetic field on z-axis [T]

%Ix = (Bx*pi*a*(1+gama^2)*sqrt(2+gama^2))/(4*perm*N);
%Vx = VoltageCalculationX(Ix);

%Iy = (By*pi*a*(1+gama^2)*sqrt(2+gama^2))/(4*perm*N);
%Vy = VoltageCalculationY(Iy);

Iz = (Bz*pi*a*(1+gama^2)*sqrt(2+gama^2))/(4*perm*N);
Vz = VoltageCalculationZ(Iz);

% Instruments 
%ga = gpib('agilent',7,5);
gb = gpib('agilent',7,5); % Creates GPIB object associated to a Agilent instrument (board index 7 and primary address 5)
%gc = gpib('agilent',7,5);

% Connecting with instrument
%fopen(ga); 
%ga.EOSMode = 'read&write';
%ga.EOSCharCode = 'LF'

fopen(gb);
gb.EOSMode = 'read&write';
gb.EOSCharCode = 'LF'

%fopen(gc); 
%gc.EOSMode = 'read&write';
%gc.EOSCharCode = 'LF'

% Program body: Sending SCPI/COMP commands to the power supplies

%fprintf(ga,'ID?');
%idSupplyA = fscanf(ga)
%fprintf(ga,'VOUT?');
%vSupplyA = fscanf(ga)
%fprintf(ga,'IOUT?');
%iSupplyA = fscanf(ga)

%fprintf(ga,'ISET 4'); % Current limit value

fprintf(gb,'*IDN?');
idSupplyB = fscanf(gb)
fprintf(gb,'VOLT?');
vSupplyB = fscanf(gb)
fprintf(gb,'MEAS:CURR?');
iSupplyB = fscanf(gb)

fprintf(gb,'CURR 4'); % Current limit value

%fprintf(gc,'ID?');
%idSupplyC = fscanf(gC)
%fprintf(gc,'VOUT?');
%vSupplyC = fscanf(gc)
%fprintf(gc,'IOUT?');
%iSupplyC = fscanf(gc)

%fprintf(gc,'ISET 4'); % Current limit value

% Output voltage limit

outputString = sprintf('VSET %d', Vx);
fprintf(ga,outputString);

outputString = sprintf('VSET %d', Vy);
fprintf(gc,outputString);

outputString = sprintf('VOLT %d', Vz);
fprintf(gb,outputString);


%for n = 0:1:Vz
 %   outputString = sprintf('VOLT %d', n);
  %  fprintf(g,outputString);
    
  %  fprintf(g,'SYST:ERR?');
   % error = fscanf(g);
   % if (error ~= 0)
    %    fprintf(g,'*CLS');
     %   fprintf(g, 'OUTP 1');
   % end    
%end

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