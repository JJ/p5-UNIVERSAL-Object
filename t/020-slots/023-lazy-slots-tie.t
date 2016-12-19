#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    plan 'no_plan';

    use_ok('UNIVERSAL::Object');
}

=pod

=cut

{
    package UNIVERSAL::Object::Lazy::__INSTANCE__;
    use strict;
    use warnings;

    use attributes ();

    sub TIEHASH { bless { %{$_[1]} }, $_[0] }
    sub FETCH {
        my ($self, $key) = @_;
        $self->{$key} = $self->{$key}->()
            if ref $self->{$key} eq 'CODE'
            && scalar grep { $_ eq 'Lazy' } attributes::get( $self->{$key} );
        return $self->{$key};
    }

    # stolen from Tie::StdHash ...
    sub STORE    { $_[0]->{$_[1]} = $_[2] }
    sub FIRSTKEY { my $a = scalar keys %{$_[0]}; each %{$_[0]} }
    sub NEXTKEY  { each %{$_[0]} }
    sub EXISTS   { exists $_[0]->{$_[1]} }
    sub DELETE   { delete $_[0]->{$_[1]} }
    sub CLEAR    { %{$_[0]} = () }
    sub SCALAR   { scalar %{$_[0]} }

    package UNIVERSAL::Object::Lazy;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

    sub CREATE {
        my $class = shift;
        my $self  = $class->SUPER::CREATE( @_ );
        tie %$self, 'UNIVERSAL::Object::Lazy::__INSTANCE__', $self;
        return $self;
    }

    sub FETCH_CODE_ATTRIBUTES  { ('Lazy') }
    sub MODIFY_CODE_ATTRIBUTES { () }

    package Foo;
    use strict;
    use warnings;

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Lazy') }
    our %HAS; BEGIN { %HAS = (
        baz => sub { undef },
        bar => sub {
            my ($self) = @_;
            my $code = sub {
                $self->{baz}
                    ? 'Foo::bar->' . $self->{baz}
                    : undef
            };
            attributes::->import(__PACKAGE__, $code, 'Lazy');
            return $code;
        },

    )};
}

{
    my $foo = Foo->new;
    isa_ok($foo, 'Foo');

    is($foo->{baz}, undef, '... got the expected value');
    is($foo->{bar}, undef, '... got the expected value');
}

{
    my $foo = Foo->new;
    isa_ok($foo, 'Foo');

    is($foo->{baz}, undef, '... got the expected value');
    $foo->{baz} = 'Foo::baz';
    is($foo->{bar}, 'Foo::bar->Foo::baz', '... got the expected (lazy) value');
}

{
    my $foo = Foo->new( baz => 'Foo::baz' );
    isa_ok($foo, 'Foo');

    is($foo->{baz}, 'Foo::baz', '... got the expected value');
    is($foo->{bar}, 'Foo::bar->Foo::baz', '... got the expected value');
}


1;

