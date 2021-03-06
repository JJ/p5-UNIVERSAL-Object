#!perl

use strict;
use warnings;

use lib '../../lib';

use Test::More qw[no_plan];

BEGIN {
    use_ok('UNIVERSAL::Object::Immutable');
}

{
    {
        package My::ArrayInstance::Test;

        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }

        sub REPR   { +[] }
        sub CREATE { $_[0]->REPR }
    }

    my $instance;

    $@ = undef;
    eval { $instance = My::ArrayInstance::Test->new };
    ok(!$@, '... got lack of error');

    isa_ok($instance, 'My::ArrayInstance::Test');

    $@ = undef;
    eval { $instance->[100] = 10 };
    like($@, qr/^Modification of a read-only value attempted/, '... got the expected error');
}

{
    {
        package My::ScalarInstance::Test;

        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }

        sub REPR   { \(my $r = 0) }
        sub CREATE { $_[0]->REPR }
    }

    my $instance;

    $@ = undef;
    eval { $instance = My::ScalarInstance::Test->new };
    ok(!$@, '... got lack of error');

    isa_ok($instance, 'My::ScalarInstance::Test');

    $@ = undef;
    eval { $$instance++ };
    like($@, qr/^Modification of a read-only value attempted/, '... got the expected error');
}

{
    {
        package My::RefInstance::Test;

        use strict;
        use warnings;

        our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }

        sub REPR   { \(my $r = []) }
        sub CREATE { $_[0]->REPR }
    }

    my $instance;

    $@ = undef;
    eval { $instance = My::RefInstance::Test->new };
    ok(!$@, '... got lack of error');

    isa_ok($instance, 'My::RefInstance::Test');

    $@ = undef;
    eval { $$instance = {} };
    like($@, qr/^Modification of a read-only value attempted/, '... got the expected error');
}

