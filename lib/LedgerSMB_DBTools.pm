package LedgerSMB_DBTools;

use Dancer2;
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

get '/' => require_login sub {
    print STDERR "\n\n\n" . session->read('my_key') . "\n\n";
    session->write('my_key', rand());
    template 'index' => { 'title' => 'LedgerSMB_DBTools' };
};

true;
