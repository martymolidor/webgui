package Test::WebGUI::Asset::MatrixListing;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset/;

use Test::More;
use Test::Deep;
use Test::Exception;

sub list_of_tables {
     return [qw/assetData MatrixListing assetAspectComments/];
}

sub parent_list {
    return ['WebGUI::Asset::Wobject::Matrix'];
}

sub t_11_getEditForm : Tests {
    ok(1);   # TODO: Test MatrixListing getEditForm
    # Do not extend other test
}

1;
