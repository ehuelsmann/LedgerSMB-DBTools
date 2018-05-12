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
    my $affected_payments;
    my $affected_invoices;
    my $query;

    if ( param('invid') ) {
        my $dbh = database;

        $query = q{
SELECT id, invnumber, transdate, amount FROM ar WHERE id = ?
UNION ALL
SELECT id, invnumber, transdate, amount FROM ap WHERE id = ?};
        $invoices = $dbh->selectall_arrayref( $query,
            { Slice => {} }, param('invid'), param('invid'));
        die $dbh->errstr
            if $dbh->state;

        $query = q{
SELECT *, case when amount < 0 then amount*-1 end as debit,
          case when amount > 0 then amount end as credit FROM acc_trans
  JOIN account ON acc_trans.chart_id = account.id
 WHERE trans_id = ?
 ORDER BY entry_id};
        $ledger_lines = $dbh->selectall_arrayref(
            $query, { Slice => {} }, param('invid'));
        die $dbh->errstr
            if $dbh->state;

        $query = q{
SELECT payment.id, payment.reference, payment_date, notes,
       abs(sum(acc_trans.amount)) as amount FROM payment
  JOIN payment_links ON payment.id = payment_links.payment_id
  JOIN acc_trans ON payment_links.entry_id = acc_trans.entry_id
  JOIN account ON acc_trans.chart_id = account.id
 WHERE acc_trans.trans_id = ?
       AND account.id IN (SELECT account_id FROM account_link
                          WHERE description IN ('AR_paid', 'AP_paid'))
 GROUP BY payment.id, payment.reference, payment_date, notes
 ORDER BY payment_date, payment.id
    };
       $affected_payments = $dbh->selectall_arrayref(
            $query, { Slice => {} }, param('invid'));
        die $dbh->errstr
            if $dbh->state;

        $query = q{
SELECT invnumber, payment.id, payment.reference, payment_date, notes
  FROM payment
  JOIN (SELECT DISTINCT payment_id, invnumber
          FROM payment_links
          JOIN acc_trans on payment_links.entry_id = acc_trans.entry_id
          JOIN (SELECT id, invnumber FROM ar WHERE id = ?
                UNION ALL
                SELECT id, invnumber FROM ap WHERE id = ?
               ) aa ON acc_trans.trans_id = aa.id) a
       ON payment.id = a.payment_id
  ORDER BY payment_date, payment.id
    };
       $affected_invoices = $dbh->selectall_arrayref(
            $query, { Slice => {} }, param('invid'), param('invid'));
        die $dbh->errstr
            if $dbh->state;
    }
    elsif ( param('search') ) {
        my $search_param = '%' . param('search') . '%';
        my $dbh = database;

        $query = q{
SELECT id, invnumber, transdate, amount FROM ar WHERE invnumber LIKE ?
UNION ALL
SELECT id, invnumber, transdate, amount FROM ap WHERE invnumber LIKE ?};
        $invoices = $dbh->selectall_arrayref( $query,
            { Slice => {} }, $search_param, $search_param);
        die $dbh->errstr
            if $dbh->state;
    }
    template 'remove-invoice' => {
        'title' => 'LedgerSMB_DBTools',
        'search' => param('search'),
        'invoices' => $invoices,
        'ledger_lines' => $ledger_lines,
        'payments' => $affected_payments,
        'affected_invoices' => $affected_invoices,
        'invid' => param('invid'),
    };
};

get '/logout' => sub {
    app->destroy_session;
    forward '/';
};

true;
