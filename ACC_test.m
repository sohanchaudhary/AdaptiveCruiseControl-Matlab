clear;
clc;
%% 1. Initilize the system such as arduino with other sensors library
a = arduino('COM6', 'Uno', 'Libraries',{'Ultrasonic','ExampleLCD/LCDAddon'},'Forcebuild',true );

ultrasonicObj = ultrasonic(a,'D13','D12'); % Trig:D13, Echo : D12

lcd = addon(a,'ExampleLCD/LCDAddon','RegisterSelectPin','D7','EnablePin','D6','DataPins',{'D5','D4','D3','D2'});
initializeLCD(lcd, 'Rows', 2, 'Columns', 16);

%% 2. Define Pins and Variables
BUTTON_CC = 'A4';
BUTTON_ACC = 'A3';
BUTTON_CANCEL = 'A2';
BUTTON_INC = 'A1';
BUTTON_DEC = 'A0';

speed=0;
mode=0;
max_speed=30;
min_speed=0;
setspeed=0;
threshold_dis=0.1;
msg = 'Welcome to Adaptive Cruise Control Project of Group 21 ';
team = 'Project Members: Sohan Chaudhary, Manoj Adhikari, and Tao Zhang ';
l = length(msg);
lt = length(team);
for i=0:1:lt
    if(i<16)
        setCursorLCD(lcd,0,i);
        printLCD(lcd,msg(i+1));
        setCursorLCD(lcd,1,i);
        printLCD(lcd,team(i+1));
    else
        % Perform circular shifting of the characters
        for j = 1:lt-1
            if (j < l)
               msg(j) = msg(j+1);
            end
            team(j) = team(j+1);
            if (j<17)
               temp(j) = team(j);
            end
        end

        if (i<l)
            setCursorLCD(lcd,0,0);
            printLCD(lcd,msg);
        end
        setCursorLCD(lcd,1,0);
        printLCD(lcd,temp);
        pause(0.3);
        clearLCD(lcd);
        %pause(0.3);
        % if(i==lt-1)
        %    i=0;
        %    pause(0.5);
        % end
               
    end
end


%% 3. Main loop
while 1
        setCursorLCD(lcd,0,0);
        printLCD(lcd,['Speed: ',num2str(speed)]);
        setCursorLCD(lcd,1,0);
        printLCD(lcd,'Mode: NORMAL');
        % clearLCD(lcd);
        %Analog Reading of Increase button
        while readVoltage(a,BUTTON_INC)>=3
            if speed < max_speed
                speed=speed+1;
                setCursorLCD(lcd,0,0);
                printLCD(lcd,['Speed: ',num2str(speed)]);
                setCursorLCD(lcd,1,0);
                printLCD(lcd,'Mode: NORMAL');
                % clearLCD(lcd);
                pause(0.2); %Delay for 0.2 second
            end
        end
        %Analog Reading of Decrease button
        while readVoltage(a,BUTTON_DEC)>=3
            if speed>0              
                speed=speed-1;
                setCursorLCD(lcd,0,0);
                printLCD(lcd,['Speed: ',num2str(speed)]);
                setCursorLCD(lcd,1,0);
                printLCD(lcd,'Mode: NORMAL');
                pause(0.2);
            end
            clearLCD(lcd);
        end
        %Analog Reading of Cruise Control button
        if readVoltage(a,BUTTON_CC)>=3
            mode=1;
            clearLCD(lcd);
        end
        while mode==1
            setCursorLCD(lcd,0,0);
            printLCD(lcd,['Speed: ',num2str(speed)]);
            setCursorLCD(lcd,1,0);
            printLCD(lcd,'Mode: CC');
            % clearLCD(lcd);
            while readVoltage(a,BUTTON_INC)>=3
                if speed < max_speed
                    speed=speed+1;      
                    setCursorLCD(lcd,0,0);
                    printLCD(lcd,['Speed: ',num2str(speed)]);
                    setCursorLCD(lcd,1,0);
                    printLCD(lcd,'Mode: CC');
                    % clearLCD(lcd);
                    pause(0.2);
                end
            end
            while readVoltage(a,BUTTON_DEC)>=3
                clearLCD(lcd);
                if speed > 0
                    speed=speed-1;
                    setCursorLCD(lcd,0,0);
                    printLCD(lcd,['Speed: ',num2str(speed)]);
                    setCursorLCD(lcd,1,0);
                    printLCD(lcd,'Mode: CC');
                    pause(0.1);
                    % 
                end
            end
            if readVoltage(a,BUTTON_CANCEL)>=3
               mode=0;
               clearLCD(lcd);
            end
        end
        %Analog Reading of Adaptive Cruise Control button
        if readVoltage(a,BUTTON_ACC)>=3
            mode=2;
            setspeed=speed;
            clearLCD(lcd);
        end
        while mode==2
            setCursorLCD(lcd,0,0);
            printLCD(lcd,['Speed: ',num2str(speed)]);
            setCursorLCD(lcd,1,0);
            printLCD(lcd,'Mode: ACC');
            clearLCD(lcd);
            if readDistance(ultrasonicObj)<threshold_dis
                setCursorLCD(lcd,0,0);
                printLCD(lcd, 'Object detected');
                pause(0.2);
                clearLCD(lcd);
                if speed > 0
                    speed=speed-1;    
                    setCursorLCD(lcd,0,0);
                    printLCD(lcd,['Speed: ',num2str(speed)]);
                    setCursorLCD(lcd,1,0);
                    printLCD(lcd,'Mode: ACC');
                    pause(0.2);
                end  
            end
            if readDistance(ultrasonicObj)>threshold_dis
                if speed<setspeed
                    speed=speed+1;                    
                end
                setCursorLCD(lcd,0,0);
                printLCD(lcd,['Speed: ',num2str(speed)]);
                setCursorLCD(lcd,1,0);
                printLCD(lcd,'Mode: ACC');
                % clearLCD(lcd);
                pause(0.2);
            end
            if readVoltage(a,BUTTON_CANCEL)>=3
               mode=0;
            end
        end
        % When nothing is pressed
        if speed>0  
            pause(0.5);
            speed=speed-1;
            
            clearLCD(lcd);
        end
        % pause(2);
end      