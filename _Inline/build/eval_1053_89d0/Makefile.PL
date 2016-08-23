use ExtUtils::MakeMaker;
my %options = %{
{
  'CC' => 'g++ -fwrapv -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64  -xc++',
  'CCFLAGS' => ' -fwrapv -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -Wno-unused-variable -DNO_XSLOCKS -Wno-deprecated -std=c++11 -Wno-reserved-user-defined-literal -Wno-literal-suffix -D__CPP__TYPES',
  'INC' => '-I"/home/leiu/perl5/bin" -I/home/leiu/perl5/lib/perl5 -Ilib',
  'LIBS' => [
    '-lstdc++'
  ],
  'NAME' => 'eval_1053_89d0',
  'OPTIMIZE' => ' -O3 -fomit-frame-pointer -march=native -g',
  'TYPEMAPS' => [
    '/home/leiu/perl5/perlbrew/perls/perl-5.22.1/lib/5.22.1/ExtUtils/typemap',
    '/home/leiu/perl5/lib/perl5/typemap.rperl'
  ],
  'VERSION' => '0.00'
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
