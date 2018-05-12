package LedgerSMB_DBTools;

use Dancer2;
use Dancer2::Plugin::SessionDatabase;
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

get '/' => require_login sub {
    template 'index' => { 'title' => 'LedgerSMB_DBTools' };
};

get '/remove-invoice' => require_login sub {
    my $invoices;
    my $ledger_lines;
    my $query;

    if ( param('invid') ) {
        
    }
    elsif ( param('search') ) {
        my $search_param = '%' . param('search') . '%';
        my $dbh = database;

        $query =
            'SELECT id, invnumber, transdate, amount FROM ar WHERE invnumber LIKE ?
         UNION ALL
             SELECT id, invnumber, transdate, amount FROM ap WHERE invnumber LIKE ?';
        $invoices = $dbh->selectall_arrayref( $query,
            { Slice => {} }, $search_param, $search_param);
        die $dbh->errstr
            if $dbh->state;
    }
    template 'remove-invoice' => {
        'title' => 'LedgerSMB_DBTools',
        'search' => param('search'),
        'invoices' => $invoices,
    };
};

get '/logout' => sub {
    app->destroy_session;
    forward '/';
};

true;
