classdef VMX < handle & matlab.mixin.CustomDisplay
    properties
        vmx = [];
        port = 11;
        motorResponse = [];
        x = [];
        y = [];
        z = [];
        theta = [];
    end
    
    properties (Access = private)
        baud = 9600;
        motorsPresent = {};
    end
    
    
    methods
        % instantiate the class, connect to the motor controller
        function obj = VMX(portNum, motorSpeed, xNum, yNum, thetaNum, zNum)
            if nargin > 0
                if exist('portNum','var') && ~isempty(portNum)
                    if isscalar(portNum)
                        obj.port = portNum;
                    else
                        error('Port number must be a scalar')
                    end
                end
                
                if exist('motorSpeed','var') && ~isempty(motorSpeed)
                    if ~isscalar(motorSpeed)
                        error('Motor speed must be a scalar')
                    end
                else
                    motorSpeed = 1000;
                end
                
                if exist('xNum','var') && isscalar(xNum)
                    obj.x = VMX.createEmptyStruct('x',xNum);
                    obj.x.speed = motorSpeed;
                    obj.motorsPresent = [obj.motorsPresent,'x'];
                end
                
                if exist('yNum','var') && isscalar(yNum)
                    obj.y = VMX.createEmptyStruct('y',yNum);
                    obj.y.speed = motorSpeed;
                    obj.motorsPresent = [obj.motorsPresent,'y'];
                end
                
                if exist('zNum','var') && isscalar(zNum)
                    obj.z = VMX.createEmptyStruct('z',zNum);
                    obj.z.speed = motorSpeed;
                    obj.motorsPresent = [obj.motorsPresent,'z'];
                end
                
                if exist('thetaNum','var') && isscalar(thetaNum)
                    obj.theta = VMX.createEmptyStruct('theta',thetaNum);
                    obj.theta.speed = motorSpeed;
                    obj.motorsPresent = [obj.motorsPresent,'theta'];
                end
                
                obj.connectMotor();
                obj.setSpeed();
            end
        end
               
        % set the speed of the motor
        function setSpeed(obj)
            for ii = 1:length(obj.motorsPresent)
                motorToSet = obj.(obj.motorsPresent{ii}).motorNum;
                speed = obj.(obj.motorsPresent{ii}).speed;
                speedCommand = sprintf('F C S%dM%d, R',motorToSet,speed);
                fprintf(obj.vmx,speedCommand);
                pause(.1); % pause for 100ms
                obj.motorResponse = fscanf(obj.vmx,'%c',1);
            end
        end
        
        % move the motor relative to current position
        function moveMotorRelative(obj,motorToMove,moveAmount)
            
            if moveAmount==0
                obj.motorResponse = '';
                return
            end
            
            % if the user gives the axis name, pull the correct values
            if ischar(motorToMove)
                motorToMove = obj.(lower(motorToMove));
            end
            
            if ~isstruct(motorToMove)
                error('Please provide the structure for the motor to move. Do not enter a number. Axis names are acceptable');
            end
            
            % conversion factors
            steps = round(moveAmount/motorToMove.unitsPerStep);
            
            if steps==0
                obj.motorResponse = '';
                return
            end
            
            % move the stage
            obj.moveMotor(motorToMove.motorNum,steps);
            
            % update the position
            obj.(motorToMove.axis).displacementSteps = obj.(motorToMove.axis).displacementSteps + steps;
            obj.(motorToMove.axis).displacementUnits = obj.(motorToMove.axis).displacementSteps * ...
                                                       obj.(motorToMove.axis).unitsPerStep;
        end
        
        % move the motor to an absolute position relative to zero
        function moveMotorAbsolute(obj,motorToMove,position)           
            
            % if the user gives the axis name, pull the correct values
            if ischar(motorToMove)
                motorToMove = obj.(lower(motorToMove));
            end
            
            if ~isstruct(motorToMove)
                error('Please provide the structure for the motor to move. Do not enter a number. Axis names are acceptable');
            end
            
            % conversion factors
            steps = round(position/motorToMove.unitsPerStep);
            
            delta = steps - motorToMove.displacementSteps;
           
            if delta==0
                obj.motorResponse = '';
                return
            end
            
            % move the stage
            obj.moveMotor(motorToMove.motorNum,delta);
            
            % update the positions
            obj.(motorToMove.axis).displacementSteps = obj.(motorToMove.axis).displacementSteps + delta;
            obj.(motorToMove.axis).displacementUnits = obj.(motorToMove.axis).displacementSteps * ...
                                                       obj.(motorToMove.axis).unitsPerStep;
        end
        
        % set the new "home" position for a stage
        function setCurrentPositionAsHome(obj,motorToMove)
            % if the user gives the axis name, pull the correct values
            if ischar(motorToMove)
                motorToMove = lower(motorToMove);
            elseif isstruct(motorToMove)
                motorToMove = motorToMove.axis;    
            end
            
            if ~ischar(motorToMove)
                error('Please provide the structure for the motor to move. Do not enter a number. Axis names are acceptable');
            end
            
            % zero the positions
            obj.(motorToMove).displacementSteps = 0;
            obj.(motorToMove).displacementUnits = 0;
        end
        
        % toggle the units used for a given stage
        function toggleUnits(obj,axisToToggle)
            % if the user gives the axis name, pull the correct values
            if ischar(axisToToggle)
                axisToToggle = lower(axisToToggle);
            elseif isstruct(axisToToggle)
                axisToToggle = axisToToggle.axis;    
            end
            
            if ~ischar(axisToToggle)
                error('Please provide the structure for the axis to toggle. Do not enter a number. Axis names are acceptable');
            end
            
            if strcmpi(axisToToggle,'theta')
                if strcmpi(obj.(axisToToggle).units,'degrees')
                    % convert to radians
                    newUnits = 'radians';
                    newUnitsPerStep = 5/400*pi/180;
                else
                    % convert to degrees
                    newUnits = 'degrees';
                    newUnitsPerStep = 5/400;
                end
            else
                if strcmpi(obj.(axisToToggle).units,'mm')
                    % convert to inches
                    newUnits = 'in';
                    newUnitsPerStep = .1/400;
                else
                    % convert to millimeters
                    newUnits = 'mm';
                    newUnitsPerStep = .1/400*25.4;
                end
            end
            
            obj.(axisToToggle).units = newUnits;
            obj.(axisToToggle).unitsPerStep = newUnitsPerStep;
            obj.(axisToToggle).displacementUnits = obj.(axisToToggle).displacementSteps * ...
                                                   obj.(axisToToggle).unitsPerStep;
            
        end
        
        % clear the serial object
        function delete(obj)
            if ~isempty(obj.vmx)
                fprintf(obj.vmx,'Q'); % release the motor
                fclose(obj.vmx); % close the port
                delete(obj.vmx);
            end
        end
        
    end
    
    methods (Access = private)
        % connect to the motor
        function connectMotor(obj)
            if isempty(obj.vmx)
                obj.vmx = serial(sprintf('COM%d',obj.port),'BaudRate',obj.baud,'DataBits',8,'Parity','None','StopBits',1);
                set(obj.vmx,'Timeout',30);
                
                % open the port
                fopen(obj.vmx);
                pause(.1); % wait for 100ms
                
                % send a verify command
                fprintf(obj.vmx,'V');
                pause(.1); % wait for 100ms
                
                % see if the controller connected properly
                obj.motorResponse = fscanf(obj.vmx,'%c',1);
            end
        end
        
        % move the motor
        function moveMotor(obj,motorToMove,stepsToMove)
            if stepsToMove==0 || isempty(stepsToMove)
                obj.motorResponse = '';
                return
            end
            
            % move the stage
            moveCommand = sprintf('I%dM%d',motorToMove,stepsToMove);
            
            fprintf(obj.vmx,'F C %s, R', moveCommand);
            pause(.1); % pause for 100ms
            
            obj.motorResponse = fscanf(obj.vmx,'%c',1);
        end
    end
    
    methods (Access = protected)
        
        function displayScalarObject(obj)
            className = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
            scalarHeader = [className,' Stage status:'];
            disp(scalarHeader)
            propgroup = getPropertyGroups(obj);
            
            for ii = 1:length(obj.motorsPresent) + 1
                fprintf('\n');
                matlab.mixin.CustomDisplay.displayPropertyGroups(obj,propgroup(ii))
            end
        end
        
        function propgrp = getPropertyGroups(obj)
            if ~isscalar(obj) % this should never trigger
                propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(obj);
                return
            end
            
            % Loop through the available stages
            nMotors = length(obj.motorsPresent);
            
            gTitles = cell(1,nMotors);
            for ii = 1:nMotors
                gTitles{ii} =  [obj.motorsPresent{ii} ' axis:'];
            end
            
            propLists = cell(1,nMotors);
            for ii = 1:nMotors
                curMotor = obj.(obj.motorsPresent{ii});
                propLists{ii} = struct('Motor_Number',curMotor.motorNum,...
                                       'Motor_Speed', [num2str(curMotor.speed) ' steps per second'],...
                                       'Position',[num2str(curMotor.displacementUnits) ' ' curMotor.units],...
                                       'Step_Position', curMotor.displacementSteps);
            end
            
            gTitle1 = 'General Motor Controller Info';
            propList1 = struct('Connected_on_port',obj.port,...
                               'Last_received_response',obj.motorResponse);
            
            
            % property groups for scalars
            propgrp(1) = matlab.mixin.util.PropertyGroup(propList1,gTitle1);
            for ii = 1:nMotors
                propgrp(ii+1) = matlab.mixin.util.PropertyGroup(propLists{ii},gTitles{ii}); %#ok<AGROW>
            end
            
            
        end
        
    end
    
    methods (Static, Access = private)
        function motor = createEmptyStruct(movementAxis,motorNumber)
            if nargin > 0
                if exist('movementAxis','var') && ~isempty(movementAxis)
                    if ~ischar(movementAxis)
                        movementAxis = num2str(movementAxis);
                    end
                end
                
                if ~exist('motorNumber','var')
                    motorNumber = [];
                end
            end
            
            mmPerStep = 0.00025 * 25.4;
            degPerStep = 5/400;
            
            motor = struct('axis',movementAxis,'motorNum',motorNumber,...
                'speed',[],'units',[],'unitsPerStep',[],...
                'displacementSteps',0,'displacementUnits',0);
            
            if strcmpi(movementAxis,'theta')
                motor.units = 'degrees';
                motor.unitsPerStep = degPerStep;
            else
                motor.units = 'mm';
                motor.unitsPerStep = mmPerStep;
            end
        end
        
    end
end