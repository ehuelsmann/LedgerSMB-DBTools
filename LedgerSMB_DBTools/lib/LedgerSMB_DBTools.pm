package LedgerSMB_DBTools;

use Dancer2;
use Dancer2::Plugin::SessionDatabase;
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

get '/' => require_login sub {
    template 'index' => { 'title' => 'LedgerSMB_DBTools' };
};

get '/remove-invoice' => require_login sub {
    database->do('select count(*) from pg_roles');
    template 'remove-invoice' => { 'title' => 'LedgerSMB_DBTools' };
};


true;
