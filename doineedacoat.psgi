use strict;
use warnings;

use doineedacoat;

my $app = doineedacoat->apply_default_middlewares(doineedacoat->psgi_app);
$app;

