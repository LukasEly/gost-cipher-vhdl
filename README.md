# Cifra GOST em VHDL

Implementação em hardware da cifra de bloco **GOST 28147-89**, descrita em VHDL e controlada por uma máquina de estados. O testbench compara a saída do hardware com os vetores gerados pelo modelo de referência em C fornecido na disciplina.

## Contexto

Trabalho da disciplina **Sistemas Digitais** (PUCRS), 3º semestre de Engenharia de Computação. O modelo de referência em C era material de apoio do professor e não está incluído aqui.

## Autor

- Lukas Ely

## Tecnologias

- VHDL
- ModelSim / Questa para simulação

## Como simular

```sh
vsim -do sim.do
```

O script compila `crypt_gost.vhd` e `tb.vhd`, carrega as formas de onda de `wave.do` e executa a simulação.

## Estrutura de pastas

```
.
├── crypt_gost.vhd   cifra GOST e máquina de estados de controle
├── tb.vhd           testbench
├── sim.do           script de simulação do ModelSim
└── wave.do          configuração das formas de onda
```
