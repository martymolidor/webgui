package WebGUI::URL;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use URI::Escape;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub append {
	my ($url);
	$url = $_[0];
	if ($url =~ /\?/) {
		$url .= '&'.$_[1];
	} else {
		$url .= '?'.$_[1];
	}
	return $url;
}

#-------------------------------------------------------------------
sub escape {
	return uri_escape($_[0]);
}

#-------------------------------------------------------------------
sub gateway {
        my ($url);
        $url = $session{config}{scripturl}.'/'.$_[0];
	if ($_[1]) {
		$url = append($url,$_[1]);
	}
        if ($session{setting}{preventProxyCache} == 1) {
                $url = append($url,randint(0,1000).';'.time());
        }
        return $url;
}

#-------------------------------------------------------------------
sub makeCompliant {
        my ($value);
	$value = $_[0];
        $value =~ s/\s+$//g;            #removes trailing whitespace
        $value =~ s/^\s+//g;            #removes leading whitespace
        $value =~ s/ /_/g;              #replaces whitespace with underscores
        $value =~ s/\.$//g;             #removes trailing period
        $value =~ s/[^A-Za-z0-9\-\.\_]//g; #removes all funky characters
        return $value;
}

#-------------------------------------------------------------------
sub makeUnique {
        my ($url, $test, $pageId);
        $url = $_[0];
        $pageId = $_[1] || "new";
        while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$url' and pageId<>'$pageId'")) {
                if ($url =~ /(.*)(\d+$)/) {
                        $url = $1.($2+1);
                } elsif ($test ne "") {
                        $url .= "2";
                }
        }
        return $url;
}

#-------------------------------------------------------------------
sub page {
	my ($url);
	$url = $session{page}{url};
	if ($_[0]) {
		$url = append($url,$_[0]);
	}
	if ($session{setting}{preventProxyCache} == 1) {
		$url = append($url,randint(0,1000).';'.time());
	}
	return $url;
}

#-------------------------------------------------------------------
sub unescape {
	return uri_unescape($_[0]);
}

#-------------------------------------------------------------------
sub urlize {
	my ($value);
        $value = lc($_[0]);		#lower cases whole string
	$value = makeCompliant($value);
        return $value;
}


1;
