# /home/alex/software/source/_forks_/radare2-testbins/wasm

# wasm_testbins="/home/alex/software/source/_forks_/radare2-testbins/wasm"
# for file in $wasm_testbins/*; do
#     gdb -x /tmp/test/gdbscript.sh --args r2 -AA -NN -qq $file 2>/dev/null | grep -q "\[DEBUG\] pass"
#     if [ "$?" -eq 0 ]; then
#         echo $file
#     fi
# done