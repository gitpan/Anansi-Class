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

=head1 DESCRIPTION

This is a base module definition that manages the creation and destruction of
module object instances including embedded objects and ensures that destruction
can only occur when an object is no longer used.

=cut


our $VERSION = '0.02';

use Anansi::ObjectManager;


=head1 METHODS

=cut


=head2 DESTROY

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

Performs module instance object variable imports.  Intended to be replaced by an
extending module.  Indirectly called.

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

Performs all required base module imports.  Indirectly called via an extending
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

Instantiates an object instance of a module.  Indirectly called via an extending
module.

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

Enables a module instance object to be externally destroyed.

=cut


sub old {
    my ($self, %parameters) = @_;
    $self->DESTROY();
}


=head2 used

 $object->used('EXAMPLE');

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

Binds a module instance object to the current object to ensure that the object
is not prematurely destroyed.

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


=head1 AUTHOR

Kevin Treleaven <kevin AT treleaven DOT net>

=cut


1;
