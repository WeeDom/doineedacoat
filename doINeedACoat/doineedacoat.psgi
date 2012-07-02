use strict;
use warnings;

use doINeedACoat;

my $app = doINeedACoat->apply_default_middlewares(doINeedACoat->psgi_app);
$app;

