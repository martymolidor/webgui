package WebGUI::Macro::PageUrl;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	my $pathinfo = $session{env}{SCRIPT_NAME};
        $pathinfo =~ s#^/##;
        return WebGUI::URL::getScriptURL().$pathinfo;
}


1;

