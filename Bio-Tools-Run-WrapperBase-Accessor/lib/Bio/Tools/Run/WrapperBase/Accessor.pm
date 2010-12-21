# ABSTRACT: Base class for Bioperl compatible Unafold wrappers

=head1 NAME

Bio::Tools::Run::WrapperBase::Accessor - Bioperl compatible WrapperBase with accessors

=head1 SYNOPSIS

Do not attempt to directly instantiate objects from this class.
Use the appropriate subclass.

 package Bio::Tools::Run::atool;
 use base 'Bio::Tools::Run::rapperBase::Accessor';
 
 BEGIN {
    my $Parameters = {foo => "a description of foo", 
                      bar => "a description of bar"};
    __PACKAGE__->_register_parameters($Parameters);
 }
 

 # and in your code...
 use Bio::Tools::Run::atool;
 my $tool = Bio::Tools::Run::atool->new({foo=>123});
 $tool->bar(321);
 print $tool->foo()."\n";
 $tool->is_valid_parameter("foo");     #=> 1
 $tool->is_valid_parameter("kittens"); #=> 0
 $tool->valid_parameters; #=> ("foo","bar");


=head1 DESCRIPTION

Base class for Bioperl wrappers around command line tools with support for generation of accessors for parameters.

=cut

use strict;
use warnings;

package Bio::Tools::Run::WrapperBase::Accessor;
use base 'Bio::Tools::Run::WrapperBase';

#use base 'Bio::Tools::Run::WrapperBase::Accessor
# __PACKAGE__->_set_parameters($param_hash);
#

# Creates accessors for arguments for all valid parameters
# $self->valid_parameters
# $self->is_valid_parameter($param_name)


=head2 _register_parameters

Title    : _register_parameters
Usage    : package MyWrapperClass;
           use base 'Bio::Tools::Run::WrapperBase::Accessor';
           my $Parameters = {foo => 'A description of foo', bar => 'A description of bar'};
           __PACKAGE__->_register_parameters($Parameters);
Function : Creates class methods valid_parameters and is_valid_parameter($name)
           and accessors for each of your parameter names in which to store argument values.
Returns  : 1 to indicate success.
Args     : None


=cut
sub _register_parameters{
    my $class = shift;
    &class::throw("_mk_param_accessors is a class method. If you're calling it from an object you're doing it wrong.") if ref($class);
    my $params = shift || {};
    
    my @valid_params = sort {$a cmp $b} keys %{$params};
    my $valid_parameters = sub { return @valid_params; };

    my $is_valid_parameter = sub {
      my ($self, $p) = @_;
      $p = lc($p); # Because _rearrange lets you specify params in uc, lc or a mix
      my %ps = %$params;
      return exists $ps{$p};
    };

    # Return parameter hash, by value
    my $parameters  = sub {
      my ($self,@which) = @_;
      @which = keys %$params unless scalar(@which);
      my %data;
      @data{@which} = @$params{@which};
      return \%data;
    };

    # add the methods to the class
    {
      no strict 'refs';
      *{"$class\::valid_parameters"}  = $valid_parameters;
      *{"$class\::is_valid_parameter"} = $is_valid_parameter;
      *{"$class\::parameters"} = $parameters;
    }

    # and generate accessors for each of the values
    foreach my $param ($class->valid_parameters){
      my $accessor = sub{
	my $self = shift;
	if (scalar(@_) > 0){
	  # need a hook here for validation?
	  $self->{$param} = shift;
	}
	return $self->{$param}
      };
      {
	no strict 'refs';
	*{"$class\::$param"} = $accessor;
      }
    }

    return 1;
}


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_); 
  bless $self, $class;

  #don't know why. It's a bioperl thing. 
  my @params = map {uc($_)} $self->valid_parameters;
  my @values = $self->_rearrange(\@params, @_);
  
  foreach (@params){
    my $param = lc $_;
    my $val = shift @values;
    $self->$param($val) if $val;
  }
  return $self;
}


=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to the
Bioperl mailing list. Your participation is much appreciated. 

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs 

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via the
web:

  http://bugzilla.open-bio.org/  

=head1 AUTHOR - Cass Johnston <cassjohnston@gmail.com>

The author(s) and contact details should be included here (this insures you get credit for creating the module.  
Lesser contributions can be documented in a separate CONTRIBUTORS section if you prefer. 

=cut

1;
