Running Mkbootstrap for eval_1053_89d0 ()
chmod 644 "eval_1053_89d0.bs"
"/home/leiu/perl5/perlbrew/perls/perl-5.22.1/bin/perl" "/home/leiu/perl5/perlbrew/perls/perl-5.22.1/lib/5.22.1/ExtUtils/xsubpp"  -typemap "/home/leiu/perl5/perlbrew/perls/perl-5.22.1/lib/5.22.1/ExtUtils/typemap" -typemap "/home/leiu/perl5/lib/perl5/typemap.rperl"   eval_1053_89d0.xs > eval_1053_89d0.xsc && mv eval_1053_89d0.xsc eval_1053_89d0.c
g++ -fwrapv -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64  -xc++ -c  -I"/home/leiu/perl5/bin" -I/home/leiu/perl5/lib/perl5 -Ilib -fwrapv -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -Wno-unused-variable -DNO_XSLOCKS -Wno-deprecated -std=c++11 -Wno-reserved-user-defined-literal -Wno-literal-suffix -D__CPP__TYPES -O3 -fomit-frame-pointer -march=native -g   -DVERSION=\"0.00\" -DXS_VERSION=\"0.00\" -fPIC "-I/home/leiu/perl5/perlbrew/perls/perl-5.22.1/lib/5.22.1/x86_64-linux/CORE"   eval_1053_89d0.c
rm -f blib/arch/auto/eval_1053_89d0/eval_1053_89d0.so
LD_RUN_PATH="/usr/lib/x86_64-linux-gnu" cc  -shared -O2 -L/usr/local/lib -fstack-protector eval_1053_89d0.o  -o blib/arch/auto/eval_1053_89d0/eval_1053_89d0.so 	\
	   -lstdc++  	\
	  
chmod 755 blib/arch/auto/eval_1053_89d0/eval_1053_89d0.so
"/home/leiu/perl5/perlbrew/perls/perl-5.22.1/bin/perl" -MExtUtils::Command::MM -e 'cp_nonempty' -- eval_1053_89d0.bs blib/arch/auto/eval_1053_89d0/eval_1053_89d0.bs 644
