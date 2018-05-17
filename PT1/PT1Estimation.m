function [ output_args ] = PT1Estimation( input_args )
%PT1ESTIMATION Estimate a PT1 Model based on measurement data
%
% PT1 in general:
%
% T*y'+y = K*u
% This equation is quite similar to radioactive decay (with u== 0). u>0
% would mean that you bring new radioactive material in the system.
%
% Simulation:
% A straight forward simulation could look like this (maybe not the best
% regarding stiff ode).
% T*(Y(n+1)-Y(n))/dt + Y(n) = K*u(n) with Y(1) = some constant.   (EQ 1)
% Note, T has the physical meaning of a "decay time" similar to the
% "half-life time" of radioactive material. K is a so called gain, a
% transformation constant between input and output value(or units).
%
% Identification in a real system:
% Usually we face however a different problem. Noisy measurement data is
% given and the task is to identify the parameters K & T for the noisy
% data. This is just a linear regression problem. Mathematically it can be
% described as min || T*y' + y - K*u ||  over all K & T.

% Lets assume a time interval of 0.1 seconds.
dt = 0.1;%

%Now we "load" the measurement data. Usually they would come from a
%measurement system (real world). Maybe from a Geiger-Mueller counter
%(regarding radioactive).
%
[u,y] = produceArtificialMeasurementData;
y=y';
u=u';
gradientY = diff(y)./dt;
%now there are two ways to solve this. First possibility is to define a
%function handle like this
% Theta = (T,K)
myObjective = @(Theta)(sum(( Theta(1)*gradientY + y(1:end-1) - Theta(2)*u(1:end-1) ).^2));

ThetaInitial = [0;0];
OptimalTheta = fminunc(myObjective,ThetaInitial);

%And what a surprise
OptimalT = OptimalTheta(1)
OptimalK = OptimalTheta(2)

%The other way would be to eploit the linearty in the optimization problem
%and to directly solve the equation with the known A'A*Theta = A'b.


%Thus we found again the parameters from the simulation.
%This information can be used to automatically tune a PI controller (pole
%compensation).
% The controller is of the form
% u(t) = Kc*(e(t)+1/Tc*integral(e(s))ds);
% Transformation in Laplace space would explain why
% Kc = K and Tc = T are good choices for a controller.
% For further understand, please refer to
% https://en.wikipedia.org/wiki/Control_theory (PID controller section).


    function [u,y] = produceArtificialMeasurementData()
        %this is for reproducing the mat file - usually should come from
        %real measurement system.
        Tlocal = 3.14/10;
        Klocal = 2;
        dt2 = 0.1;
        
        %create a random input signal
        u = [2*ones(1,20), 1*ones(1,10), 4*ones(1,30) -1*ones(1,30) -2*ones(1,20)];
        y = nan(size(u));
        timeVector = [0:dt2:(length(u)-1)*dt2];
        y(1) = 4;%inital value
        for k = 1:length(y)-1
            % Rearagning equation (EQ 1) yields:
            y(k+1) = (Klocal*u(k)-y(k))/Tlocal*dt2 + y(k);
        end
        figure; plot(timeVector,u,timeVector,y);
        
        
    end

end

