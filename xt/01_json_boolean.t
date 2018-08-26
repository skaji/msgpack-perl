use strict;
use warnings;
use Test::More;
use File::Temp ();
use TAP::Harness::Env;
use Capture::Tiny 'capture_merged';

sub fill_in {
    my ($template, $hash) = @_;
    $template =~ s/\{\{ \s* (\S+?) \s* \}\}/ $hash->{$1} or die "undefined var '$1'\n" /xge;
    $template;
}

my @JSON_CLASS = qw(
    JSON
    JSON::PP
    JSON::XS
    Cpanel::JSON::XS
    JSON::MaybeXS
    Mojo::JSON
);

my $SCRIPT = <<'___';
use strict;
use warnings;
use {{ json_class }} qw(encode_json decode_json);
use Data::MessagePack;
use Test::More;

my $packer = Data::MessagePack->new;

my $hash = {
    json    => {{ json_class }}::true,
    msgpack => Data::MessagePack::true,
};

my $ret1 = $packer->unpack($packer->pack($hash));
my $ret2 = decode_json encode_json $hash;

is_deeply $ret1, $hash;
is_deeply $ret2, $hash;

done_testing;
___

my $tempdir = File::Temp::tempdir(CLEANUP => 1);
for my $json_class (@JSON_CLASS) {
    my $version;
    if (eval "require $json_class") {
        $version = $json_class->VERSION || "undef";
    } else {
        diag "Failed to load $json_class; skip its test...";
        next;
    }
    my $script = fill_in $SCRIPT, { json_class => $json_class };
    (my $filename = "$json_class-$version") =~ s/::/-/g;
    $filename .= ".t";
    open my $fh, ">", "$tempdir/$filename" or die;
    print {$fh} $script;
}

for my $backend ('pp', 'xs') {
    local $ENV{PERL_DATA_MESSAGEPACK} = $backend;
    note "Data::MessagePack backend $backend";
    my ($merged, $ok) = capture_merged {
        my $tester = TAP::Harness::Env->create({
            color => 0, lib => [ "blib/arch", "blib/lib" ]
        });
        $tester->runtests(glob "$tempdir/*.t")->has_errors ? 0 : 1;
    };
    note $merged;
    ok $ok or diag $merged;
}

done_testing;
