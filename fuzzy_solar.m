clear; clc; close all;

%% 1. Ponto de Operação para Teste (Crisp)
DeltaP_in = -1.0;  % Variação de Potência (p.u.)
DeltaV_in =  0.25; % Variação de Tensão (p.u.)

fprintf('====================================================\n');
fprintf('  CONTROLADOR FUZZY MPPT - EXECUÇÃO NATIVA MATLAB   \n');
fprintf('====================================================\n');
fprintf('Entrada DeltaP : %6.2f p.u.\n', DeltaP_in);
fprintf('Entrada DeltaV : %6.2f p.u.\n', DeltaV_in);

%% 2. Fase 1: Fuzzificação das Entradas
% Definição analítica das funções de pertinência de entrada
% Universo [-1.0; 1.0] p.u.

% Entrada 1: DeltaP
mu_DP_Neg = max(0, min(1, -DeltaP_in));
mu_DP_Zero = max(0, min((DeltaP_in + 0.5)/0.5, (0.5 - DeltaP_in)/0.5));
mu_DP_Pos = max(0, min(1, DeltaP_in));

% Entrada 2: DeltaV
mu_DV_Neg = max(0, min(1, -DeltaV_in));
mu_DV_Zero = max(0, min((DeltaV_in + 0.5)/0.5, (0.5 - DeltaV_in)/0.5));
mu_DV_Pos = max(0, min(1, DeltaV_in));

fprintf('\n[FASE 1: FUZZIFICAÇÃO]\n');
fprintf('mu_Negativa(DeltaP) = %.2f | mu_Zero(DeltaP) = %.2f | mu_Positiva(DeltaP) = %.2f\n', ...
    mu_DP_Neg, mu_DP_Zero, mu_DP_Pos);
fprintf('mu_Negativa(DeltaV) = %.2f | mu_Zero(DeltaV) = %.2f | mu_Positiva(DeltaV) = %.2f\n', ...
    mu_DV_Neg, mu_DV_Zero, mu_DV_Pos);

%% 3. Fase 2 e 3: Força das Regras e Implicação de Mamdani
% Universo de discurso discretizado da saída DeltaD (passo 0.1 p.u.)
DeltaD_grid = -1.0:0.1:1.0;
N_pts = length(DeltaD_grid);

% Funções de pertinência da saída DeltaD
mu_DD_Dim = max(0, min(1, -DeltaD_grid));
mu_DD_Man = max(0, min((DeltaD_grid + 0.5)/0.5, (0.5 - DeltaD_grid)/0.5));
mu_DD_Aum = max(0, min(1, DeltaD_grid));

% Base de 9 Regras da Tabela de Perturbe e Observe:
% w_k = min(mu_In1, mu_In2)
w = zeros(3, 3);
w(1,1) = min(mu_DP_Neg, mu_DV_Neg);  % R1: Neg e Neg -> Aumentar
w(1,2) = min(mu_DP_Neg, mu_DV_Zero); % R2: Neg e Zero -> Manter
w(1,3) = min(mu_DP_Neg, mu_DV_Pos);  % R3: Neg e Pos  -> Diminuir

w(2,1) = min(mu_DP_Zero, mu_DV_Neg); % R4: Zero e Neg -> Diminuir
w(2,2) = min(mu_DP_Zero, mu_DV_Zero);% R5: Zero e Zero -> Manter
w(2,3) = min(mu_DP_Zero, mu_DV_Pos); % R6: Zero e Pos  -> Aumentar

w(3,1) = min(mu_DP_Pos, mu_DV_Neg);  % R7: Pos e Neg  -> Aumentar
w(3,2) = min(mu_DP_Pos, mu_DV_Zero); % R8: Pos e Zero -> Manter
w(3,3) = min(mu_DP_Pos, mu_DV_Pos);  % R9: Pos e Pos  -> Diminuir

% Ativação agregada para cada termo da saída:
w_Diminuir = max([w(1,3), w(2,1), w(3,3)]);
w_Manter   = max([w(1,2), w(2,2), w(3,2)]);
w_Aumentar = max([w(1,1), w(2,3), w(3,1)]);

fprintf('\n[FASE 2 E 3: IMPLICAÇÃO DE MAMDANI]\n');
fprintf('Força ativada para "Diminuir" : %.2f\n', w_Diminuir);
fprintf('Força ativada para "Manter"   : %.2f\n', w_Manter);
fprintf('Força ativada para "Aumentar" : %.2f\n', w_Aumentar);

%% 4. Fase 4: Agregação (Operador Máximo)
% Truncamento de cada conjunto consequente pelo respectivo grau de ativação
mu_C_Dim = min(w_Diminuir, mu_DD_Dim);
mu_C_Man = min(w_Manter,   mu_DD_Man);
mu_C_Aum = min(w_Aumentar, mu_DD_Aum);

% Agregação pela união (Máximo)
mu_agg = max(mu_C_Dim, max(mu_C_Man, mu_C_Aum));

%% 5. Fase 5: Defuzzificação por Centro de Área (CDA)
soma_numerador   = sum(mu_agg .* DeltaD_grid);
soma_denominador = sum(mu_agg);

DeltaD_crisp = soma_numerador / soma_denominador;

fprintf('\n[FASE 4 E 5: AGREGAÇÃO E DEFUZZIFICAÇÃO]\n');
fprintf('Somatório do Numerador   (Momento Estático) : %8.4f p.u.\n', soma_numerador);
fprintf('Somatório do Denominador (Área Total)        : %8.4f\n', soma_denominador);
fprintf('Saída Crisp Defuzzificada (DeltaD)          : %8.4f p.u.\n', DeltaD_crisp);
fprintf('====================================================\n');

%% 6. Geração do Gráfico Exigido (Região Agregada e CDA)
figure('Color', [1 1 1], 'Position', [150 150 800 450]);

plot(DeltaD_grid, mu_DD_Dim, 'k--', 'LineWidth', 1); hold on;
plot(DeltaD_grid, mu_DD_Man, 'Color', [0.85 0.65 0.13], 'LineStyle', '--', 'LineWidth', 1);
plot(DeltaD_grid, mu_DD_Aum, 'g--', 'LineWidth', 1);

% Preenchimento da área agregada
area(DeltaD_grid, mu_agg, 'FaceColor', [0.2 0.6 1.0], 'FaceAlpha', 0.5, 'EdgeColor', 'b', 'LineWidth', 2);

% Linha vertical e ponto demarcando o Centro de Área (CDA)
plot([DeltaD_crisp DeltaD_crisp], [0 1], 'r-', 'LineWidth', 2);
plot(DeltaD_crisp, 0.25, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

grid on;
title(sprintf('Região Fuzzy Agregada e Centro de Área (\\Delta D = %.4f p.u.)', DeltaD_crisp), 'FontSize', 12);
xlabel('Variação do Duty Cycle \Delta D (p.u.)');
ylabel('Grau de Pertinência \mu');
legend('Diminuir', 'Manter', 'Aumentar', 'Região Agregada', 'CDA Final', 'Location', 'NorthEast');
xlim([-1.0 1.0]); ylim([0 1.05]);
