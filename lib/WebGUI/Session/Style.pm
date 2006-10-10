package WebGUI::Session::Style;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::CPHash;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Session::Style

=head1 DESCRIPTION

This package contains utility methods for WebGUI's style system.

=head1 SYNOPSIS

 use WebGUI::Session::Style;
 $style = WebGUI::Session::Style->new($session);

 $html = $style->generateAdditionalHeadTags();
 $html = $style->process($content);

 $session = $style->session;
 
 $style->makePrintable(1);
 $style->setLink($url,\%params);
 $style->setMeta(\%params);
 $style->setRawHeadTags($html);
 $style->setScript($url, \%params);
 $style->useEmptyStyle(1);

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 generateAdditionalHeadTags ( )

Creates tags that were set using setLink, setMeta, setScript, extraHeadTags, and setRawHeadTags.

=cut

sub generateAdditionalHeadTags {
	my $self = shift;
	# generate additional raw tags
	my $tags = $self->{_raw};
        # generate additional link tags
	# generate additional javascript tags
	$tags .= join '', values %{ $self->{_link} }, values %{ $self->{_javascript} };
	delete $self->{_raw};
	delete $self->{_javascript};
	delete $self->{_link};
	WebGUI::Macro::process($self->session,\$tags);
	return $tags;
}


#-------------------------------------------------------------------

=head2 makePrintable ( boolean ) 

Tells the system to use the make printable style instead of the normal style.

=head3 boolean

If set to 1 then the printable style will be used, otherwise the regular style will be used.

=cut

sub makePrintable {
	my $self = shift;
	$self->{_makePrintable} = shift;
}


#-------------------------------------------------------------------

=head2 new ( session ) 

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 process ( content, templateId )

Returns a parsed style with content based upon the current WebGUI session information.
Sets the C<sent> method/flag to be true so that subsequent head data is processed
right away.

=head3 content

The content to be parsed into the style. Usually generated by WebGUI::Page::generate().

=head3 templateId

The unique identifier for the template to retrieve. 

=cut

sub process {
	my $self = shift;
	my %var;
	$var{'body.content'} = shift;
	my $templateId = shift;
	if ($self->{_makePrintable} && $self->session->asset) {
		$templateId = $self->{_printableStyleId} || $self->session->asset->get("printableStyleTemplateId");
		my $currAsset = $self->session->asset;
		until ($templateId) {
			# some assets don't have this property.  But at least one ancestor should....
			$currAsset = $currAsset->getParent;
			$templateId = $currAsset->get("printableStyleTemplateId");
		}
	} elsif ($self->session->scratch->get("personalStyleId") ne "") {
		$templateId = $self->session->scratch->get("personalStyleId");
	} elsif ($self->{_useEmptyStyle}) {
		$templateId = 6;
	}
$var{'head.tags'} = '
<meta name="generator" content="WebGUI '.$WebGUI::VERSION.'" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Content-Script-Type" content="text/javascript" />
<meta http-equiv="Content-Style-Type" content="text/css" />
<script type="text/javascript">
function getWebguiProperty (propName) {
var props = new Array();
props["extrasURL"] = "'.$self->session->url->extras().'";
props["pageURL"] = "'.$self->session->url->page(undef, undef, 1).'";
return props[propName];
}
</script>
<!--morehead-->
';
if ($self->session->user->isInGroup(2) || $self->session->setting->get("preventProxyCache")) {
	# This "triple incantation" panders to the delicate tastes of various browsers for reliable cache suppression.
	$var{'head.tags'} .= '
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache, must-revalidate, max-age=0, private" />
<meta http-equiv="Expires" content="0" />
';
	$self->session->http->setCacheControl("none");
}
	my $style = WebGUI::Asset::Template->new($self->session,$templateId);
	my $output;
	if (defined $style) {
		$var{'head.tags'} .= $style->get("headBlock");
		$output = $style->process(\%var);
	} else {
		$output = "WebGUI was unable to instantiate your style template.".$var{'body.content'};
	}
	WebGUI::Macro::process($self->session,\$output);
	$self->sent(1);
        my $macroHeadTags = $self->generateAdditionalHeadTags();
        $output =~ s/\<\!--morehead--\>/$macroHeadTags/;	
	return $output;
}	


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 sent ( boolean )

Returns a boolean indicating whether the style has already been sent. This is important when trying to set things to the HTML head block.

=head3 boolean

Set the value.

=cut

sub sent {
	my $self = shift;
	my $boolean = shift;
	if (defined $boolean) {
		$self->session->stow->set("styleHeadSent",$boolean);
		return $boolean;
	}
	return $self->session->stow->get("styleHeadSent");
}

#-------------------------------------------------------------------

=head2 setLink ( url, params )

Sets a <link> tag into the <head> of this rendered page for this page view. This is typically used for dynamically adding references to CSS and RSS documents.

=head3 url

The URL to the document you are linking.  Only one link can be set per url.  If a link to this URL exists,
the old link will remain and this method will return undef.

=head3 params

A hash reference containing the other parameters to be included in the link tag, such as "rel" and "type".

=cut

sub setLink {
	my $self = shift;
	my $url = shift;
	my $params = shift;
	$params = {} unless (defined $params and ref $params eq 'HASH');
	return undef if ($self->{_link}{$url});
	my $tag = '<link href="'.$url.'"';
	foreach my $name (keys %{$params}) {
		$tag .= ' '.$name.'="'.$params->{$name}.'"';
	}
	$tag .= ' />'."\n";
	$self->{_link}{$url} = $tag;
	$self->session->output->print($tag) if ($self->sent);
}

#-------------------------------------------------------------------

=head2 setPrintableStyleId ( params )

Overrides current printable style id defined in assets definition

=head3 params

scalar containing id of style to use

=cut

sub setPrintableStyleId {
	my $self = shift;
	my $styleId = shift;

	$self->{_printableStyleId} = $styleId;
}

#-------------------------------------------------------------------

=head2 setMeta ( params )

Sets a <meta> tag into the <head> of this rendered page for this page view. 

=head3 params

A hash reference containing the parameters of the meta tag.

=cut

sub setMeta {
	my $self = shift;
	my $params = shift;
	my $tag = '<meta';
	foreach my $name (keys %{$params}) {
		$tag .= ' '.$name.'="'.$params->{$name}.'"';
	}
	$tag .= ' />'."\n";
	$self->setRawHeadTags($tag);
}



#-------------------------------------------------------------------

=head2 setRawHeadTags ( tags )

Sets data to be output into the <head> of the current rendered page for this page view.

=head3 tags

A raw string containing tags. This is just a raw string so you must actually pass in the full tag to use this call.

=cut

sub setRawHeadTags {
	my $self = shift;
	my $tags = shift;
	$self->{_raw} .= $tags;
	$self->session->output->print($tags) if ($self->sent);
}


#-------------------------------------------------------------------

=head2 setScript ( url, params )

Sets a <script> tag into the <head> of this rendered page for this page view. This is typically used for dynamically adding references to Javascript or ECMA script.

=head3 url

The URL to your script.

=head3 params

A hash reference containing the additional parameters to include in the script tag, such as "type" and "language".

=cut

sub setScript {
	my $self = shift;
	my $url = shift;
	my $params = shift;
	return undef if ($self->{_javascript}{$url});
	my $tag = '<script src="'.$url.'"';
	foreach my $name (keys %{$params}) {
		$tag .= ' '.$name.'="'.$params->{$name}.'"';
	}
	$tag .= '></script>'."\n";
	$self->{_javascript}{$url} = $tag;
	$self->session->output->print($tag) if ($self->sent);
}

#-------------------------------------------------------------------

=head2 useEmptyStyle ( boolean ) 

Tells the style system to use an empty style rather than outputing the normal style. This is useful when you want your code to dynamically generate a style.

=head3 boolean

If set to 1 it will use an empty style, if set to 0 it will use the regular style. Defaults to 0.

=cut

sub useEmptyStyle {
	my $self = shift;
	$self->{_useEmptyStyle} = shift;
}

#-------------------------------------------------------------------

=head2 userStyle ( content )

Wrapper's the content in the user style defined in the settings.

=head3 content

The content to be wrappered.

=cut

sub userStyle {
	my $self = shift;
        my $output = shift;
	$self->session->http->setCacheControl("none");
        if ($output) {
                return $self->process($output,$self->session->setting->get("userFunctionStyleId"));
        } else {
                return undef;
        }       
}  

1;
