function main = SeniorDesignfxntest()
%% Senior Design Project Code written by Peter Carlson
clear; close all;
%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%    Workbook: C:\Users\Peter\Dropbox\Matlab\SeniorDesignInputs.xlsx
%    Worksheet: Sheet1
% Import the data
SeniorDesignInputs = csvread("C:/Users/Eric/PycharmProjects/KeysightSimu/inputs.csv");
%% Define Constants and Initalize matricies
StartingAu=SeniorDesignInputs(1); %starting composition in wt %
TPreheat=SeniorDesignInputs(2);%In C
tpreheat=SeniorDesignInputs(3);%End of t Range
TReflow=SeniorDesignInputs(4);%In C
treflow=SeniorDesignInputs(5);%End of t Range
xmin = 0; %micron
xmax = 68;%end position in micron
tstep = 0.01; %time step (dt)
x = xmin:(xmax-xmin)/1000:xmax; %initalize x array
t1 = 0:tstep:tpreheat;%initalize time array of preheat
t2 = 0:tstep:treflow; %initalize time array of reflow
DAuPreheat=.031*(10^6)*exp(-39360/(8.314*(TPreheat+273)));%Units of micron^2/s
DAuReflow=.031*(10^6)*exp(-39360/(8.314*(TReflow+273)));%Units of micron^2/s
CAupreheat = zeros(length(t1), length(x)); %Initalize CAu(t,x) for preheat
CAureflow = zeros(length(t2), length(x));  %Initalize CAu(t,x) for reflow
%% inital/boundary conditions
CAupreheat(1,1:60) = 100; %Gold plating on MSRI side
CAupreheat(1,61:648) = StartingAu; %Inital solder composition in wt% gold
CAupreheat(1,649:end) = 100; %Gold plating on IC side
%% loop lads
for i = 2:length(t1)
    CAupreheat(i,:) = fwddiff(x, CAupreheat(i-1,:), tstep, DAuPreheat); %at each t, solve for all conc(x)
end
%Setting inital conditions for reflow to the end of preheat phase
CAureflow(1,1:60) = CAupreheat(end,1:60);
CAureflow(1,61:648) = CAupreheat(end,61:648);
CAureflow(1,649:end) = CAupreheat(end,649:end);
for i = 2:length(t2)
    CAureflow(i,:) = fwddiff(x, CAureflow(i-1,:), tstep, DAuReflow); %at each t, solve for all conc(x)
end
EndComposition=sum(CAureflow(end,61:648))/(648-61) %Obtains the average composition within the solder for use in calculations
Endmelttemp=278+(EndComposition-80)*((500-278)/5) %in Degrees Celcius
Intermetallic=1+(15-(1-EndComposition))/(28-15) %Percent intermettalic in alloy
%% plotting
figure
plot(x,CAupreheat(end,:), 'r') 
hold on
plot(x,CAureflow(end,:), 'b')
legend('Diffusion Profile after preheat', 'Diffusion Profile after reflow')
xlim([0 68])
xlabel('distance(microns)')
ylabel('Gold concentration (weight %)')
saveas(figure(1),'C:/Users/Eric/PycharmProjects/KeysightSimu/SolderPlot', 'bmp')
main = 'complete'
end



%% Here be fxns
function Cfinal = fwddiff(xvector, CAu, dt, D) %(array, array, value, value), solve for all concentrations
%constants
    dx = (xvector(2)-xvector(1));
    %preallocate
    dcdt = zeros(1, length(xvector)-2); %d2cdx2 should not have a value for index 1 and last val since we use half pt method
    Cfinal = zeros(1, length(xvector)); %holds new concentrations
    D2Cdx2 = zeros(1, size(CAu,2)+2); %initialize a concentration matrix for use in 2nd derivative, where end points have half points between
    %initalize geometry
    D2Cdx2(3:end-2) = CAu(2:end-1);
    D2Cdx2(1) = CAu(1);
    D2Cdx2(end) = CAu(end);
    %create half points
    D2Cdx2(2) = (CAu(1)+CAu(2))/2; %linear interpolation between c1 and c2 to find c1.5
    D2Cdx2(end-1) = (CAu(1)+CAu(2))/2; %linear interpolation between cend-1 and cend to find cend-0.5 
    %solve for dcdt, where dcdt(1)=(D2Cdx2(5)-D2Cdx2(3))/2*dx - (D2Cdx2(3)-D2Cdx2(1))/2*dx
    for i=1:(length(xvector)-2)
        dcdt(i) = (D/(2*dx))*((((D2Cdx2(i+4)-D2Cdx2(i+2))/2*dx) - ((D2Cdx2(i+2)-D2Cdx2(i))/2*dx)));
    end
    %forward euler solve
    Cfinal(2:end-1) = CAu(2:end-1) + dt*dcdt;
    %adjust boundary conditions -> no flux
    Cfinal(1) = Cfinal(2); %index 1 and last val become same as neighbor
    Cfinal(end) = Cfinal(end-1); 
end
