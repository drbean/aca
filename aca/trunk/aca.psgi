use strict;
use warnings;

use Aca;

my $app = Aca->apply_default_middlewares(Aca->psgi_app);
$app;

