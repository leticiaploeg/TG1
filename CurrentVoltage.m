% Code to find out the relation current/voltage with a load (the load used was the Z coils) 

clear;

% Instrument
g = gpib('agilent',7,5); % Cria objeto GPIB associado com um instrumento Agilent de board index 7 e endereço primário 5. 
fopen(g); % Inicia conexão com instrumento
g.EOSMode = 'read&write';
g.EOSCharCode = 'LF'

% Program body: Sending SCPI commands to the power supply

fprintf(g,'*IDN?');
idSupply = fscanf(g)

fprintf(g,'CURR 4'); % Limit of current
fprintf(g,'CURR:PROT:STAT 1'); % Enables or disables the power supply overcurrent protection function (OCP) 
fprintf(g,'VOLT 0');
pause(1);

voltage = [];
current = [];

j = 1;
for n = 0:1:27  
    outputString = sprintf('VOLT %d', n);
    fprintf(g,outputString);
    pause(1);
    
    fprintf(g,'MEAS:VOLT?');
    vSupply = fscanf(g);
    fprintf(g,'MEAS:CURR?');
    iSupply = fscanf(g);
    pause(1);
    
    voltage(j) = str2num(vSupply);
    current(j) = str2num(iSupply);
    j = j+1;
    pause(1);
end

figure
plot(voltage, current) 

lm = fitlm(voltage,current,'linear')

% End of program body

fclose(g); % Closing connection
delete(g); % Erasing GPIB object
clear g;