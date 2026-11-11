onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/clock
add wave -noupdate /tb/DUT/reset
add wave -noupdate -divider entradas
add wave -noupdate /tb/DUT/start
add wave -noupdate /tb/DUT/enc_dec
add wave -noupdate -radix hexadecimal /tb/DUT/data_i
add wave -noupdate -radix hexadecimal /tb/DUT/key_i
add wave -noupdate -divider ESTADOS
add wave -noupdate /tb/DUT/EA
add wave -noupdate /tb/DUT/PE
add wave -noupdate -divider ENCRIPTY
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_enc_i1
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_enc_i2
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_enc_j
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_k
add wave -noupdate -divider DECRIPTY
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_dec_i1
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_dec_i2
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_dec_j
add wave -noupdate -radix hexadecimal -format logic /tb/DUT/count_k
add wave -noupdate -divider sinais
add wave -noupdate /tb/DUT/pos
add wave -noupdate /tb/DUT/nNi
add wave -noupdate /tb/DUT/k
add wave -noupdate /tb/DUT/key_pos_choose
add wave -noupdate /tb/DUT/for_verifier
add wave -noupdate -divider sinais
add wave -noupdate -radix hexadecimal /tb/DUT/SN
add wave -noupdate -radix hexadecimal /tb/DUT/Ni
add wave -noupdate -radix hexadecimal /tb/DUT/mask
add wave -noupdate -radix hexadecimal /tb/DUT/N1
add wave -noupdate -radix hexadecimal /tb/DUT/N2
add wave -noupdate -radix hexadecimal /tb/DUT/CM1
add wave -noupdate -radix hexadecimal /tb/DUT/CM1_aux
add wave -noupdate -radix hexadecimal /tb/DUT/CM2
add wave -noupdate -radix hexadecimal /tb/DUT/R
add wave -noupdate /tb/DUT/count_k
add wave -noupdate -divider Saídas
add wave -noupdate /tb/DUT/busy
add wave -noupdate /tb/DUT/ready
add wave -noupdate -radix hexadecimal /tb/DUT/data_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {230000 ns}