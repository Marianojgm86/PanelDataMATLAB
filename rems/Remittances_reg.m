clear all
clc

% addpath paneldata
addpath(genpath('../paneldata'))

% Analysis for remittances
% n =  T=, N=
% years?

disp('-----------------------------------------');
disp('            PANEL DATA MODELS            ');
disp('-----------------------------------------');

% Load data from data-codes.xlsx file

T = readtable('data/data-codes.xlsx', 'Sheet','data-codes','ReadRowNames', true);



%% Test 1: using directly what is in the uploaded data in line with Barajas
%et al

% Lending rate
y = T{:,4};

% Construct variables within X


x1 = T{:,5}; % MP RATE
x2 = T{:,5}.*T{:,3}; %MP RATE * REMS
x3 = T{:,5}.*T{:,16}; %MP RATE * KA_OPEN
x4 = T{:,5}.*T{:,10}; %MP RATE * RQ_EST
x5 = T{:,3}; % Rems
x6 = T{:,16}; % kaopen

X = [x1, x2, x5, x3, x6, x4];

id = T{:,1};
year = T{:,2};

ynames = {'lend_rate'};
xnames = {'mp_rate','mp_rems','rems','mp_kaopen', 'kaopen', 'mp_rq', 'CONST'};


% Panel FE Robust
regfer1 = panel(id, year, y, X, 'fe', 'vartype', 'robust');
regfer1.ynames = ynames;
regfer1.xnames = xnames;
estdisp(regfer1);

% Panel RE Robust
regrer1 = panel(id, year, y, X, 're', 'vartype', 'robust');
regrer1.ynames = ynames;
regrer1.xnames = xnames;
estdisp(regrer1);



% return

% Individual effects
ieffectsdisp(regfer1);

% Individual effects
ieffectsdisp(regfer1,'overall');

%%  Test 2 including LA dummy

% Lending rate
y2 = T{:,4};

% Construct variables within X

x12 = T{:,5}; % MP RATE
x22 = T{:,5}.*T{:,3}; %MP RATE * REMS
x32 = T{:,5}.*T{:,16}; %MP RATE * KA_OPEN
x42 = T{:,5}.*T{:,10}; %MP RATE * RQ_EST
x52 = T{:,3}; % Rems
x62 = T{:,16}; % kaopen
x72 = T{:,5}.*T{:,17}.*T{:,3}; %MP RATE * LA_DUMMY*rens


X2 = [x12, x22, x52, x32, x62, x42, x72];

id = T{:,1};
year = T{:,2};

ynames = {'lend_rate'};
xnames = {'mp_rate','mp_rems','rems','mp_kaopen', 'kaopen', 'mp_rq', 'mp_la_rems', 'CONST'};


% Panel FE Robust
regfer2 = panel(id, year, y2, X2, 'fe', 'vartype', 'robust');
regfer2.ynames = ynames;
regfer2.xnames = xnames;
estdisp(regfer2);

% Panel RE Robust
regrer2 = panel(id, year, y2, X2, 're', 'vartype', 'robust');
regrer2.ynames = ynames;
regrer2.xnames = xnames;
estdisp(regrer2);


ieffectsdisp(regfer2);

% Individual effects
ieffectsdisp(regfer2,'overall');



%% Test 3: using the yearly change in rems

% Lending rate
y3 = T{:,4};

% Construct variables within X


x13 = T{:,5}; % MP RATE
x23 = T{:,5}.*log(T{:,3}); %MP RATE * REMS
x33 = T{:,5}.*T{:,16}; %MP RATE * KA_OPEN
x43 = T{:,5}.*T{:,10}; %MP RATE * RQ_EST
x53 = T{:,end}; % Rems
x63 = T{:,16}; % kaopen


id3 = T{:,1};
year3 = T{:,2};


allX3 = [year3, id3, y3, x13, x23, x33, x63, x43, x53];

% Removing year 2000
allX3 = allX3(allX3(:,1)>2000,:);

% matrices
id3 = allX3(:,1);
year3 = allX3(:,2);
y3 = allX3(:,3);
X3 = allX3(:, 4:end);


ynames = {'lend_rate'};
xnames = {'mp_rate','mp_rems', 'mp_kaopen', 'kaopen', 'mp_rq','rems', 'CONST'};


% Panel FE Robust
regfer3 = panel(id3, year3, y3, X3, 'fe', 'vartype', 'robust');
regfer3.ynames = ynames;
regfer3.xnames = xnames;
estdisp(regfer3);

% Panel RE Robust
regrer3 = panel(id3, year3, y3, X3, 're', 'vartype', 'robust');
regrer3.ynames = ynames;
regrer3.xnames = xnames;
estdisp(regrer3);




% Individual effects
ieffectsdisp(regfer3);

% Individual effects
ieffectsdisp(regfer3,'overall');


return

%%
% OLS
regols = ols(y,X);
regols.ynames = ynames;
regols.xnames = xnames;
estdisp(regols);

% Clustered OLS
regolsc = ols(y,X,'vartype','cluster','clusterid',id);
regolsc.ynames = ynames;
regolsc.xnames = xnames;
estdisp(regolsc);

% Panel FE For a fixed effects (within) estimation
regfe = panel(id,year,y, X, 'fe');
regfe.ynames = ynames;
regfe.xnames = xnames;
estdisp(regfe);

% Individual effects
ieffectsdisp(regfe);

% Individual effects
ieffectsdisp(regfe,'overall');

% F test of inividual effects
effF = effectsftest(regfe);
testdisp(effF);


% Panel BE  For a between estimation.
regbe = panel(id,year,y, X, 'be');
regbe.ynames = ynames;
regbe.xnames = xnames;
estdisp(regbe);

% Panel RE  For a random effects GLS estimation
regre = panel(id,year,y, X, 're');
regre.ynames = ynames;
regre.xnames = xnames;
estdisp(regre);

% BP test for effects
bpre = bpretest(regre);
testdisp(bpre);

% Hausman test
h = hausmantest(regfe, regre);
testdisp(h);

% Mundlak test
mu = mundlakvatest(regfe);
testdisp(mu);

% Pool test
% po = pooltest(regfe);
% testdisp(po);

% Wooldridge serial test
wo = woolserialtest(regfe);
testdisp(wo);

wo = woolserialtest(regfe,'dfcorrection',0);
testdisp(wo);

% Pesaran CSD
pecsdfe = pesarancsdtest(regfe);
testdisp(pecsdfe);

pecsdre = pesarancsdtest(regre);
testdisp(pecsdre);


% Panel FE Robust
regfer = panel(id, year, y, X, 'fe', 'vartype', 'robust');
regfer.ynames = ynames;
regfer.xnames = xnames;
estdisp(regfer);

% Panel RE Robust
regrer = panel(id, year, y, X, 're', 'vartype', 'robust');
regrer.ynames = ynames;
regrer.xnames = xnames;
estdisp(regrer);

% Mundlak test
mur = mundlakvatest(regfer);
testdisp(mur);

% Individual effects
ieffectsdisp(regfer);

% Individual effects
ieffectsdisp(regfer,'overall');
