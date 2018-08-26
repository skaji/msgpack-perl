requires 'perl', '5.008001';

requires 'Math::BigInt', 1.89; # old versions of BigInt were broken

on configure => sub {
    requires 'Module::Build::XSUtil';
    requires 'Devel::PPPort', '3.42';
};

on test => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires';
};

on develop => sub {
    requires 'Test::LeakTrace';
    requires 'Capture::Tiny';
    requires 'JSON';
    requires 'JSON::PP';
    requires 'JSON::XS';
    requires 'Cpanel::JSON::XS', '4.04';
    requires 'JSON::MaybeXS', '1.004000';
    requires 'Mojolicious' if $] > 5.010;
};
