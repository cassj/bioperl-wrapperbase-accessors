use strict;
use warnings;

use Data::Dumper;
use Bio::Root::Test;

use Bio::Tools::Run::WrapperBase::Accessor;

test_begin(-tests => 48);

# Make a subclass to test:
push @ATestClass::ISA, 'Bio::Tools::Run::WrapperBase::Accessor';

#define some parameters for it:
$ATestClass::Parameters = {
			    foo => 'a numeric value',
			    bar => 'a string',
			    baz => 'a description',
			    MEEP => 'a param in caps'
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
can_ok('ATestClass', 'MEEP');


# and each switch
can_ok('ATestClass', 'stuff');
can_ok('ATestClass', 'thing');

# and that we can create a new object
my $obj = ATestClass->new();
isa_ok($obj, 'ATestClass');


# do the generated parameter methods work
ok($obj->is_valid_parameter("foo"), "->foo ok");
ok(!$obj->is_valid_parameter("Foo"), "->Foo error"); # _rearrange lets you use lc or uc or mix of both.
ok(!$obj->is_valid_parameter("bAr"), "->bAr error"); # which I think is daft, but meh.
ok(!$obj->is_valid_parameter("meep"), "->meep error");
ok($obj->is_valid_parameter("MEEP"), "->MEEp ok");
ok(!$obj->is_valid_parameter("cheesecake"), "->cheesecake error");
ok($obj->is_valid_switch('stuff'), "->stuff ok");
ok(!$obj->is_valid_switch('monkey'), "->monkey error");


#returns params in alphabetical order.
is_deeply([$obj->valid_parameters],[qw(MEEP bar baz foo)], "valid_params alphabetical");

#returns switches in alphabetical order
is_deeply([$obj->valid_switches], [qw(stuff thing)], "valid switches alphabetical");

# returns the parameter hash for the given params
is_deeply($obj->parameters, $ATestClass::Parameters,"parameter hash correct");
is_deeply($obj->parameters('foo'), {foo => 'a numeric value'}, "single parameter correct");
is_deeply($obj->parameters('foo','bar'), {foo=>'a numeric value', bar=>'a string'}, "multi params correct");

# returns the switch hash for the given switches
is_deeply($obj->switches, $ATestClass::Switches, "switches hash correct");
is_deeply($obj->switches('stuff'), {stuff => 'a description of stuff'},"single switch correct");
is_deeply($obj->switches('stuff','thing'), {stuff=>'a description of stuff', thing=>'a description of thing'}, "multi switch correct");


# and just check it really does pass by value, not reference
# as we don't want people accidentally dicking with the class data
my $param_copy = ATestClass->parameters;
$param_copy->{test} = "blah blah blah";
isnt(ATestClass->parameters->{test}, $param_copy->{test}, "returned params are a *copy*");

my $switch_copy = ATestClass->switches;
$switch_copy->{test} = "blah blah blah";
isnt(ATestClass->switches->{test}, $param_copy->{test}, "returned switches are a *copy*");

# and use those accessors
is($obj->foo(123), 123, "can set param");
is($obj->foo, 123, "param is set correctly");
ok(!defined $obj->foo(undef), "can undef param");

is($obj->stuff(1), 1, "can set switch");
is($obj->stuff, 1, "switch set correctly");
ok(!defined $obj->stuff(undef), "can undef switch");

# Bioperl / _rearrange lets you specify various wierd
# combinations of case for the parameter names in teh
# constructor. Don't. It's confusing. But it should work

$obj = ATestClass->new('-foo' => 123);
is($obj->foo, 123, "parameter set in constructor");
$obj = ATestClass->new('-stuff' => 1);
is($obj->stuff, 1, "switch set in constructor");
$obj = ATestClass->new('-FoO' => 123);
is($obj->foo, 123,"parameter set with daft case in constructor");
$obj = ATestClass->new('-stuFF' => 1);
is($obj->stuff, 1, "switch set with stupid case in constructor");
$obj = ATestClass->new(-stuff=>1, -foo=>123);
is($obj->foo,123,"multi param set in constructor");
is($obj->stuff, 1, "multi switch set in constructor");

## And can we create an appropriate parameter string
can_ok($obj, 'parameter_string');
is($obj->parameter_string(-double_dash=>1), ' --foo 123 --stuff',  "parameter string generated correctly");

$obj = ATestClass->new(-stUff=>1, -FoO=>123);
is($obj->parameter_string(-double_dash=>1), ' --foo 123 --stuff',  "parameter string generated correctly even with stupid case");




