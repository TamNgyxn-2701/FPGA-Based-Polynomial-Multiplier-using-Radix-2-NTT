transcript on
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog ../rtl/mod_arith_q12289.v
vlog ../rtl/montgomery_mul_q12289.v
vlog ../rtl/twiddle_rom_256.v
vlog ../rtl/input_rom_128.v
vlog ../rtl/ntt_core_256.v
vlog ../rtl/poly_mul_ntt_core.v
vlog ../tb/tb_poly_mul_ntt_core.v
vsim -voptargs=+acc work.tb_poly_mul_ntt_core
add wave -radix unsigned sim:/tb_poly_mul_ntt_core/DUT/state
add wave -radix unsigned sim:/tb_poly_mul_ntt_core/DUT/cnt
add wave sim:/tb_poly_mul_ntt_core/busy
add wave sim:/tb_poly_mul_ntt_core/done
run -all
