onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_alu/clk
add wave -noupdate /tb_alu/rst
add wave -noupdate /tb_alu/rd_wr
add wave -noupdate /tb_alu/addr
add wave -noupdate /tb_alu/en
add wave -noupdate /tb_alu/wr_data
add wave -noupdate /tb_alu/rd_data
add wave -noupdate /tb_alu/res_out
add wave -noupdate /tb_alu/prev_res
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {948 ps}
