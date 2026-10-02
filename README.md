# Controle Fuzzy MPPT para Rastreamento do Ponto de Máxima Potência - Projeto, Cálculo Manual e Implementação Computacional de um Sistema de Inferência Fuzzy para energia Solar Fotovoltaica


Este repositório contém o desenvolvimento, o equacionamento analítico e a implementação computacional de um algoritmo de inferência fuzzy do tipo Mamdani voltado para o rastreamento do Ponto de Máxima Potência (MPPT) em módulos solares por meio da regulação do *duty cycle* de um conversor CC-CC.

---

## 1. Mapeamento das Variáveis de Controle

 O modelo fuzzy toma decisões com base na variação instantânea de potência e tensão, aplicando a técnica Perturbe e Observe (P&O):

* **Entrada 1 — Variação de Potência ($\Delta P$):** Universo de discurso normalizado em $[-1.0, 1.0]$ p.u.
  * *Conjuntos fuzzy:* `Negativa`, `Zero`, `Positiva`.
* **Entrada 2 — Variação de Tensão ($\Delta V$):** Universo de discurso normalizado em $[-1.0, 1.0]$ p.u.
  * *Conjuntos fuzzy:* `Negativa`, `Zero`, `Positiva`.
* **Saída — Variação da Razão Cíclica ($\Delta D$):** Universo de discurso em $[-1.0, 1.0]$ p.u.
  * *Conjuntos fuzzy:* `Diminuir`, `Manter`, `Aumentar`.

---

## 2. Matriz de Regras do Sistema

| $\Delta P$ \ $\Delta V$ | Negativa | Zero | Positiva |
| :--- | :---: | :---: | :---: |
| **Negativa** | Aumentar | Manter | Diminuir |
| **Zero** | Diminuir | Manter | Aumentar |
| **Positiva** | Aumentar | Manter | Diminuir |

---

## 3. Guia para Execução do Código

1. Certifique-se de ter o **GNU Octave** (com o pacote `fuzzy-logic-toolkit`) ou o **MATLAB** instalado.
2. Abra o script principal no ambiente de sua preferência (`fuzzy_mppt.m`).
3. Execute o script para rodar a inferência com as entradas de teste.
4. O resultado do cálculo da variação do *duty cycle* ($\Delta D$) e os detalhes numéricos serão impressos diretamente no console.

---

## 4. Avaliação e Resultados da Simulação

Para a condição operacional de validação definida por $\Delta P = -1{,}0$ p.u. e $\Delta V = 0{,}25$ p.u.:

O sistema identificou uma queda abrupta na geração combinada a uma elevação na tensão da malha. O motor de inferência de Mamdani ativou as regras correspondentes aos termos de saída `Manter` e `Diminuir`, truncando suas funções de pertinência em $0{,}5$ e $0{,}25$, respectivamente.

A agregação dos conjuntos fuzzy resultou em uma distribuição assimétrica sobre a região negativa. A etapa de defuzzificação via Centro de Área (CDA) forneceu a seguinte resposta nítida (*crisp*):

$$\Delta D \approx -0{,}2181 \text{ p.u.}$$



## Autoria
* *Aluno*: Guilherme de Sá Teles Magalhães 
* *Matricula*: 202011130028
* *Disciplina*: Automação Inteligente — IFBA
