cd ..

sh -c "$(curl -fsSL https://raw.githubusercontent.com/d2verb/zigenv/master/zigenv-init.sh)" && . $HOME/.zigenv/zigenv-init.sh && zigenv install 0.13.0 && zigenv change 0.13.0

zig build

zig-out/bin/lvm3 programs/2048.obj


cd ..

git clone https://github.com/paul-nameless/lc3-asm

cd lc3-asm

python lc3.py tests/hello.asm && ../lvm3/zig-out/bin/lvm3 tests/hello-out.obj

python lc3.py tests/add-num.asm && ../lvm3/zig-out/bin/lvm3 tests/add-num-out.obj

python lc3.py tests/hello2.asm && ../lvm3/zig-out/bin/lvm3 tests/hello2-out.obj

python lc3.py ../lvm3/test/fib01.asm && ../lvm3/zig-out/bin/lvm3 ../lvm3/test/fib01-out.obj

python lc3.py ../lvm3/test/fib02.asm && ../lvm3/zig-out/bin/lvm3 ../lvm3/test/fib02-out.obj

(cd ../lvm3 && zig build) && python lc3.py ../lvm3/test/fib02.asm && ../lvm3/zig-out/bin/lvm3 ../lvm3/test/fib02-out.obj