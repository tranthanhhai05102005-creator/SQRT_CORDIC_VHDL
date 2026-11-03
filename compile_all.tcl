vdel -all -lib work
vlib work
vcom -work work -2002 -explicit -stats=none src/sqrt_package.vhd
vcom -work work -2002 -explicit -stats=none src/regn.vhd
vcom -work work -2002 -explicit -stats=none src/SQRT_Datapath.vhd
vcom -work work -2002 -explicit -stats=none src/SQRT_CU.vhd
vcom -work work -2002 -explicit -stats=none src/SQRTApprox.vhd
vcom -work work -2002 -explicit -stats=none src/SQRTApprox_tb.vhd
