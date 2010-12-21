use strict;
use warnings;

use Data::Dumper;
use Bio::Root::Test;

use Bio::Tools::Run::WrapperBase::Accessor;

test_begin(-tests => 25);

# Make a subclass to test:
push @ATestClass::ISA, 'Bio::Tools::Run::WrapperBase::Accessor';

#define some parameters for it:
$ATestClass::Parameters = {
			    foo => 'a numeric value',
			    bar => 'a string',
			    baz => 'a boolean value'
			   };

can_ok('ATestClass', '_register_parameters');
ok(ATestClass->_register_parameters($ATestClass::Parameters), 'registering parameters');

# check we've added the parameter accessors
can_ok('ATestClass', 'valid_parameters');
can_ok('ATestClass', 'is_valid_parameter');
can_ok('ATestClass', 'parameters');


# and argument accessors for each parameter
can_ok('ATestClass', 'foo');
can_ok('ATestClass', 'bar');
can_ok('ATestClass', 'baz');


# and that we can create a new object
my $obj = ATestClass->new();
isa_ok($obj, 'ATestClass');

# do the generated parameter methods work
ok($obj->is_valid_parameter("foo"));
ok($obj->is_valid_parameter("Foo")); # _rearrange lets you use lc or uc or mix of both.
ok($obj->is_valid_parameter("bAr")); # which I think is daft, but meh.
ok(!$obj->is_valid_parameter("cheesecake"));

#returns params in alphabetical order.
is_deeply([$obj->valid_parameters],[qw(bar baz foo)]);

# returns the parameter hash for the given params
is_deeply($obj->parameters, $ATestClass::Parameters);
is_deeply($obj->parameters('foo'), {foo => 'a numeric value'});
is_deeply($obj->parameters('foo','bar'), {foo=>'a numeric value', bar=>'a string'});

#and just check it really does pass by value, not reference
my $param_copy = $obj->parameters;
$param_copy->{test} = "blah blah blah";
isnt($ATestClass::Parameters->{test}, $param_copy->{test});

# and use those accessors
is($obj->foo(123), 123);
is($obj->foo(), 123);
is($obj->foo(0), 0);

# And we're using undef to mean don't pass this parameter,
# so check we can undef stuff.
$obj->foo(undef);
ok(! defined $obj->foo());

# Can we set values in the constructor. I don't really understand
# why Bioperl insists on using _rearrange and allowing params
# to be specified in uc, lc or some mix of the 2, but for compatibility:

$obj = ATestClass->new('-foo' => 123);
is($obj->foo, 123);

$obj = ATestClass->new('-FOO' => 123);
is($obj->foo, 123);

$obj = ATestClass->new('-FoO' => 123);
is($obj->foo, 123);

