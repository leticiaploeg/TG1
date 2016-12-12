% Code to find out the relation current/voltage with a load (X or Y axis)
% Instrument

g = visa('agilent', 'GPIB0::5::INSTR')
fopen(g); 
g.EOSMode = 'read&write';
g.EOSCharCode = 'LF';

% Program body: Sending SCPI commands to the power supply
fprintf(g,'ERR?');
errorSupply = fscanf(g)
fprintf(g,'ID?');
idSupply = fscanf(g)

fprintf(g,'ISET 4'); % Limit of current
fprintf(g,'VSET 0');
pause(1);

voltage = [];
current = [];

j = 1;
for n = 0:1:26  
    outputString = sprintf('VSET %d', n);
    fprintf(g,outputString);
    pause(1);
    
    fprintf(g,'VOUT?');
    vSupply = fscanf(g);
    vSupply = vSupply(6:end)
    fprintf(g,'IOUT?');
    iSupply = fscanf(g);
    iSupply = iSupply(6:end)
    pause(1);
    
    voltage(j) = str2num(vSupply);
    current(j) = str2num(iSupply);
    j = j+1;
    pause(1);
end

figure
plot(voltage, current, '-o')
title({'Tensão vs Corrente','Fonte A: Eixo Y'})
xlabel('Tensão (V)')
ylabel('Corrente (A)')


lm = fitlm(voltage,current,'linear')

% End of program body

fclose(g); % Closing connection
delete(g); % Erasing GPIB object
clear g;