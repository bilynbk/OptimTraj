% MAIN - Pendulum
%
% Demonstrates simple swing-up for a single pendulum with a torque motor.
% This is an easy problem, used for demonstrating how to use analytic
% gradients with trajOpt.
%

clc; clear;
addpath ../../

% Physical parameters of the pendulum
p.k = 1;  % Normalized gravity constant
p.c = 0.1;  % Normalized damping constant

% User-defined dynamics and objective functions
problem.func.dynamics = @(t,x,u)( dynamics(x,u,p) );
problem.func.pathObj = @(t,x,u)( pathObjectiveTest(t,x,u) );

% bound objective for testing
xF_target = [pi;0];
problem.func.bndObj = @(t0,x0,tF,xF)( boundObjective(xF,xF_target) );

% Problem bounds
problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = 0.5;
problem.bounds.finalTime.upp = 2.5;

problem.bounds.state.low = [-2*pi; -inf];
problem.bounds.state.upp = [2*pi; inf];
problem.bounds.initialState.low = [0;0];
problem.bounds.initialState.upp = [0;0];
problem.bounds.finalState.low = [pi;0];
problem.bounds.finalState.upp = [pi;0];

problem.bounds.control.low = -5; %-inf;
problem.bounds.control.upp = 5; %inf;

% Guess at the initial trajectory
problem.guess.time = [0,1];
problem.guess.state = [0, pi; pi-.1, 0];
problem.guess.control = [1, 0];

% Options for fmincon
problem.options(1).nlpOpt = optimset(...
    'Display','iter',...
    'GradObj','on',...
    'GradConstr','on',...
    'DerivativeCheck','on',...
    'MaxFunEvals',6000);

method = 'rungeKutta';
% method = 'trapezoid';
% method = 'hermiteSimpson';

switch method

    case 'rungeKutta'

        problem.options(1).method = 'rungeKutta';
        problem.options(1).defaultAccuracy = 'low';
        
        % plot defect gradient sparsity
        problem.options(1).rungeKutta.PlotDefectGrad = 'on';
        
        problem.options(1).rungeKutta.nSegment = 3;
        
        problem.options(2) = problem.options(1);
        problem.options(2).defaultAccuracy = 'medium';
        problem.options(2).rungeKutta.nSegment = 7;
        
        problem.options(2).rungeKutta.AdaptiveDerivativeCheck = 'off';
        
    case 'trapezoid'

        problem.options(1).method = 'trapezoid';
        problem.options(1).defaultAccuracy = 'low';
        
        % plot defect gradient sparsity
        problem.options(1).trapezoid.PlotDefectGrad = 'on';
        
        problem.options(2) = problem.options(1);
        problem.options(2).defaultAccuracy = 'medium';
        
    case 'hermiteSimpson'

        problem.options(1).method = 'hermiteSimpson';
        problem.options(1).defaultAccuracy = 'low';
        
        % plot defect gradient sparsity
        problem.options(1).hermiteSimpson.PlotDefectGrad = 'on';
        
        problem.options(2) = problem.options(1);
        problem.options(2).defaultAccuracy = 'medium';
    
end


% Solve the problem
soln = optimTraj(problem);
soln = soln(end);
t = soln.grid.time;
q = soln.grid.state(1,:);
dq = soln.grid.state(2,:);
u = soln.grid.control;

% Plot the solution:
figure(1); clf;

subplot(3,1,1)
plot(t,q)
ylabel('q')
title('Single Pendulum Swing-Up');

subplot(3,1,2)
plot(t,dq)
ylabel('dq')

subplot(3,1,3)
plot(t,u)
ylabel('u')


