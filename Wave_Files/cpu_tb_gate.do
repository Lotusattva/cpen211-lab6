onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/sim_clk
add wave -noupdate /cpu_tb/sim_reset
add wave -noupdate /cpu_tb/sim_s
add wave -noupdate /cpu_tb/sim_load
add wave -noupdate /cpu_tb/sim_in
add wave -noupdate /cpu_tb/sim_out
add wave -noupdate /cpu_tb/sim_N_out
add wave -noupdate /cpu_tb/sim_V_out
add wave -noupdate /cpu_tb/sim_Z_out
add wave -noupdate /cpu_tb/sim_w_out
add wave -noupdate /cpu_tb/err
add wave -noupdate /cpu_tb/DUT/clk
add wave -noupdate /cpu_tb/DUT/reset
add wave -noupdate /cpu_tb/DUT/s
add wave -noupdate /cpu_tb/DUT/load
add wave -noupdate /cpu_tb/DUT/in
add wave -noupdate /cpu_tb/DUT/out
add wave -noupdate /cpu_tb/DUT/N
add wave -noupdate /cpu_tb/DUT/V
add wave -noupdate /cpu_tb/DUT/Z
add wave -noupdate /cpu_tb/DUT/w
add wave -noupdate /cpu_tb/DUT/instr
add wave -noupdate /cpu_tb/DUT/nsel
add wave -noupdate /cpu_tb/DUT/opcode
add wave -noupdate /cpu_tb/DUT/op
add wave -noupdate /cpu_tb/DUT/sximm8
add wave -noupdate /cpu_tb/DUT/writenum
add wave -noupdate /cpu_tb/DUT/readnum
add wave -noupdate /cpu_tb/DUT/vsel
add wave -noupdate /cpu_tb/DUT/shift
add wave -noupdate /cpu_tb/DUT/ALUop
add wave -noupdate /cpu_tb/DUT/write
add wave -noupdate /cpu_tb/DUT/loada
add wave -noupdate /cpu_tb/DUT/loadb
add wave -noupdate /cpu_tb/DUT/loadc
add wave -noupdate /cpu_tb/DUT/loads
add wave -noupdate /cpu_tb/DUT/asel
add wave -noupdate /cpu_tb/DUT/bsel
add wave -noupdate /cpu_tb/DUT/state
add wave -noupdate /cpu_tb/DUT/PC
add wave -noupdate /cpu_tb/DUT/mdata
add wave -noupdate /cpu_tb/DUT/sximm5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}