package Dancer2::Plugin::Auth::Extensible::Provider::DBConnection;

use Carp qw/croak/;
use DBI;
use Try::Tiny;

use Moo;
with "Dancer2::Plugin::Auth::Extensible::Role::Provider";
use namespace::clean;

our $VERSION = '0.001';

sub authenticate_user {
   my ($self, $username, $password) = @_;

   croak "username and password must be defined"
     unless defined $username and defined $password;

   croak "session doesn't contain database name for auth"
     unless defined session->read('dbname');

print STDERR "\n\n\nhere!!\n\n\n";
   my $dbh;
#   session->write('dbname', 'postgres');
print STDERR "\n\n\nhere2!!\n\n\n";
   try {
     $dbh = DBI->connect('dbi:Pg:host=postgres;dbname=postgres', # . session->read('dbname'),
             $username, $password);
     print STDERR DBI->errstr . "\n\n";
   };

print STDERR "authenticated: " . (defined $dbh ? "yes" : "no") . "\n\n";   
   return defined $dbh;
}
