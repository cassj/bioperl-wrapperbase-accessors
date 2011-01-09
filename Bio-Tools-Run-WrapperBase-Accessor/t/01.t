use strict;
use warnings;

use Data::Dumper;
use Bio::Root::Test;

use Bio::Tools::Run::WrapperBase::Accessor;

test_begin(-tests => 42);

# Make a subclass to test:
push @ATestClass::ISA, 'Bio::Tools::Run::WrapperBase::Accessor';

#define some parameters for it:
$ATestClass::Parameters = {
			    foo => 'a numeric value',
			    bar => 'a string',
			    baz => 'a description'
			   };

$ATestClass::Switches = {
			 stuff => 'a description of stuff',
			 thing => 'a description of thing'
			};

can_ok('ATestClass', '_setup');
ok(ATestClass->_setup('-params' => $ATestClass::Parameters, '-switches' => $ATestClass::Switches), 'registering parameters');

# check we've added the parameter accessors
can_ok('ATestClass', 'valid_parameters');
can_ok('ATestClass', 'valid_switches');
can_ok('ATestClass', 'is_valid_parameter');
can_ok('ATestClass', 'is_valid_switch');
can_ok('ATestClass', 'parameters');
can_ok('ATestClass', 'switches');


# and argument accessors for each parameter
can_ok('ATestClass', 'foo');
can_ok('ATestClass', 'bar');
can_ok('ATestClass', 'baz');

# and each switch
can_ok('ATestClass', 'stuff');
can_ok('ATestClass', 'thing');

# and that we can create a new object
my $obj = ATestClass->new();
isa_ok($obj, 'ATestClass');

# do the generated parameter methods work
ok($obj->is_valid_parameter("foo"));
ok($obj->is_valid_parameter("Foo")); # _rearrange lets you use lc or uc or mix of both.
ok($obj->is_valid_parameter("bAr")); # which I think is daft, but meh.
ok(!$obj->is_valid_parameter("cheesecake"));
ok($obj->is_valid_switch('stuff'));
ok(!$obj->is_valid_switch('monkey'));


#returns params in alphabetical order.
is_deeply([$obj->valid_parameters],[qw(bar baz foo)]);

#returns switches in alphabetical order
is_deeply([$obj->valid_switches], [qw(stuff thing)]);

# returns the parameter hash for the given params
is_deeply($obj->parameters, $ATestClass::Parameters);
is_deeply($obj->parameters('foo'), {foo => 'a numeric value'});
is_deeply($obj->parameters('foo','bar'), {foo=>'a numeric value', bar=>'a string'});

# returns the switch hash for the given switches
is_deeply($obj->switches, $ATestClass::Switches);
is_deeply($obj->switches('stuff'), {stuff => 'a description of stuff'});
is_deeply($obj->switches('stuff','thing'), {stuff=>'a description of stuff', thing=>'a description of thing'});


# and just check it really does pass by value, not reference
# as we don't want people accidentally dicking with the class data
my $param_copy = ATestClass->parameters;
$param_copy->{test} = "blah blah blah";
isnt(ATestClass->parameters->{test}, $param_copy->{test});

my $switch_copy = ATestClass->switches;
$switch_copy->{test} = "blah blah blah";
isnt(ATestClass->switches->{test}, $param_copy->{test});

# and use those accessors
is($obj->foo(123), 123);
is($obj->foo, 123);
ok(!defined $obj->foo(undef));

is($obj->stuff(1), 1);
is($obj->stuff, 1);
ok(!defined $obj->stuff(undef));


# Can we set values in the constructor. I don't really understand
# why Bioperl insists on using _rearrange and allowing params
# to be specified in uc, lc or some mix of the 2, but for compatibility:

$obj = ATestClass->new('-foo' => 123);
is($obj->foo, 123);

$obj = ATestClass->new('-FOO' => 123);
is($obj->foo, 123);

$obj = ATestClass->new('-FoO' => 123);
is($obj->foo, 123);

$obj = ATestClass->new('-Foo' => 123, '-stuFF' => 1);
is($obj->stuff, 1);


# And can we create an appropriate parameter string
can_ok($obj, 'parameter_string');
is($obj->parameter_string(-double_dash=>1), ' --foo 123 --stuff');

