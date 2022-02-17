onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib da_rom_triangle_opt

do {wave.do}

view wave
view structure
view signals

do {da_rom_triangle.udo}

run -all

quit -force
