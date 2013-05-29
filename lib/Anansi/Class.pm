package Anansi::Class;


=head1 NAME

Anansi::Class - A base module definition

=head1 SYNOPSIS

 package Anansi::Example;

 use base qw(Anansi::Class);

 sub finalise {
  my ($self, %parameters) = @_;
 }

 sub initialise {
  my ($self, %parameters) = @_;
 }

 1;

=head1 DESCRIPTION

This is a base module definition that manages the creation and destruction of
module object instances including embedded objects and ensures that destruction
can only occur when an object is no longer used.  Makes use of
L<Anansi::ObjectManager>.

=cut


our $VERSION = '0.07';

use Anansi::ObjectManager;


=head1 METHODS

=cut


=head2 DESTROY

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=back

Performs module object instance clean-up actions.  Indirectly called by the perl
interpreter.

=cut


sub DESTROY {
    my ($self) = @_;
    my $objectManager = Anansi::ObjectManager->new();
    if(1 == $objectManager->registrations($self)) {
        $self->finalise();
        $objectManager->obsolete(
            USER => $self,
        );
        $objectManager->unregister($self);
    }
}


=head2 finalise

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=back

Called just prior to module instance object destruction.  Intended to be
replaced by an extending module.  Indirectly called.

=cut


sub finalise {
    my ($self) = @_;
}


=head2 implicate

 sub implicate {
     my ($self, $caller, $parameter) = @_;
     if('EXAMPLE_VARIABLE' eq $parameter) {
         return \EXAMPLE_VARIABLE;
     }
     try {
         return $self->SUPER::implicate($caller, $parameter);
     }
     return if($@);
 }

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item caller I<(Array, Required)>

An array containing the I<package>, I<file name> and I<line number> of the caller.

=item parameter I<(String, Required)>

A string containing the name to import.

=back

Performs one module instance name import.  Called for each name to import.
Intended to be replaced by an extending module.  Indirectly called.

=cut


sub implicate {
    my ($self, $caller, $parameter) = @_;
    try {
        return $self->SUPER::implicate($caller, $parameter);
    }
    return if($@);
}


=head2 import

 use Anansi::Example qw(EXAMPLE_VARIABLE);

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item parameters I<(Array, Optional)>

An array containing all of the names to import.

=back

Performs all required module name imports.  Indirectly called via an extending
module.

=cut


sub import {
    my ($self, @parameters) = @_;
    my $caller = caller();
    foreach my $parameter (@parameters) {
        my $value = $self->implicate($caller, $parameter);
        *{$caller.'::'.$parameter} = $value if(defined($value));
    }
}


=head2 initialise

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item parameters I<(Hash)>

Named parameters that were supplied to the I<new> method.

=back

Called just after module instance object creation.  Intended to be replaced by
an extending module.  Indirectly called.

=cut


sub initialise {
    my ($self, %parameters) = @_;
}


=head2 new

 my $object = Anansi::Example->new();

 my $object = Anansi::Example->new(
  SETTING => 'example',
 );

=over 4

=item class I<(Blessed Hash B<or> String, Required)>

Either an object or a string of this namespace.

=item parameters I<(Hash, Optional)>

Named parameters.

=back

Instantiates an object instance of a module.  Indirectly called via an extending
module through inheritance.

=cut


sub new {
    my ($class, %parameters) = @_;
    return if(ref($class) =~ /^(ARRAY|CODE|FORMAT|GLOB|HASH|IO|LVALUE|REF|Regexp|SCALAR|VSTRING)$/i);
    $class = ref($class) if(ref($class) !~ /^$/);
    my $self = {
        NAMESPACE => $class,
        PACKAGE => __PACKAGE__,
    };
    bless($self, $class);
    my $objectManager = Anansi::ObjectManager->new();
    $objectManager->register($self);
    $self->initialise(%parameters);
    return $self;
}


=head2 old

 $object->old();

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item parameters I<(Hash, Optional)>

Named parameters.

=back

Enables a module instance object to be externally destroyed.

=cut


sub old {
    my ($self, %parameters) = @_;
    $self->DESTROY();
}


=head2 used

 $object->used('EXAMPLE');

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item parameters I<(Array, Optional)>

An array of strings containing the names of blessed objects currently in use by
this object.

=back

Releases a module instance object to enable it to be destroyed.

=cut


sub used {
    my ($self, @parameters) = @_;
    my $objectManager = Anansi::ObjectManager->new();
    foreach my $key (@parameters) {
        next if(!defined($self->{$key}));
        next if(!defined($self->{$key}->{IDENTIFICATION}));
        $objectManager->obsolete(
            USER => $self,
            USES => $self->{$key},
        );
        delete $self->{$key};
    }
}


=head2 uses

 $object->uses(
  EXAMPLE => $example,
 );

 $object->uses(
  EXAMPLE => 'Anansi::Example',
 );

=over 4

=item self I<(Blessed Hash, Required)>

An object of this namespace.

=item parameters I<(Hash, Optional)>

A hash containing keys that represent the name to associate with the string
namespace or object within the associated values.

=back

Binds module instance objects to the current object to ensure that the objects
are not prematurely destroyed.

=cut


sub uses {
    my ($self, %parameters) = @_;
    my $objectManager = Anansi::ObjectManager->new();
    $objectManager->current(
        USER => $self,
        USES => [values %parameters],
    );
    while(my ($key, $value) = each(%parameters)) {
        next if(!defined($value->{IDENTIFICATION}));
        $self->{$key} = $value if(!defined($self->{KEY}));
    }
}


=head1 NOTES

This module is designed to make it simple, easy and quite fast to code your
design in perl.  If for any reason you feel that it doesn't achieve these goals
then please let me know.  I am here to help.  All constructive criticisms are
also welcomed.


=head1 AUTHOR

Kevin Treleaven <kevin I<AT> treleaven I<DOT> net>

=cut


1;
