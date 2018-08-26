package Data::MessagePack::Boolean;
use strict;
use warnings;

# for **require** Data::MessagePack::Boolean
our $true  = do { bless \(my $dummy = 1), __PACKAGE__ };
our $false = do { bless \(my $dummy = 0), __PACKAGE__ };

BEGIN {
    *Data::MessagePack::Boolean:: = *JSON::PP::Boolean::;
}

package Data::MessagePack::Boolean; # for perl 5.14
use overload (
    "0+"     => sub { ${$_[0]} },
    "++"     => sub { $_[0] = ${$_[0]} + 1 },
    "--"     => sub { $_[0] = ${$_[0]} - 1 },
    fallback => 1,
);

# for **use** Data::MessagePack::Boolean
$true  = do { bless \(my $dummy = 1), __PACKAGE__ };
$false = do { bless \(my $dummy = 0), __PACKAGE__ };

1;
