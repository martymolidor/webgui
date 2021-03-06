package WebGUI::Asset::File::ZipArchive;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::File';
define assetName => ['assetName', 'Asset_ZipArchive'];
define tableName => 'ZipArchiveAsset';
define icon      => 'ziparchive.gif';
property showPage => (
            tab          => "properties",
            label        => ['show page', 'Asset_ZipArchive'],
            hoverHelp    => ['show page description', 'Asset_ZipArchive'],
            fieldType    => 'text',
            default      => 'index.html',
         );
property templateId => (
            tab          => "display",
            label        => ['template label', 'Asset_ZipArchive'],
            hoverHelp    => ['template description', 'Asset_ZipArchive'],
            namespace    => "ZipArchiveAsset",
            fieldType    => 'template',
            default      => 'ZipArchiveTMPL00000001',
         );


use WebGUI::SQL;

use Archive::Tar;
use Archive::Zip;
use Cwd ();
use Scope::Guard ();


=head1 NAME

Package WebGUI::Asset::ZipArchive

=head1 DESCRIPTION

Provides a mechanism to upload and automatically extract a zip archive
containing related items.  An asset setting will set the launch point of the archive.

=head1 SYNOPSIS

use WebGUI::Asset::ZipArchive;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 unzip ( $storage, $filename )

Uncompress and/or expand an archive, based on the file extension of the filename.
Returns 1 if the unzip was successful.  Returns 0 if there were problems.

=head3 $storage

A WebGUI::Storage object containing the archive.

=head3 $filename

The filename of the archive.

=cut

sub unzip {
	my $self = shift;
	my $storage = shift;
	my $filename = shift;
   
	my $filepath = $storage->getPath();
    my $cwd = Cwd::cwd();
    chdir $filepath;
    my $dir_guard = Scope::Guard->new(sub { chdir $cwd });
   
	my $i18n = WebGUI::International->new($self->session,"Asset_ZipArchive");
	if ($filename =~ m/\.zip$/i) {
		my $zip = Archive::Zip->new();
		unless ($zip->read($filename) == $zip->AZ_OK){
			$self->session->log->warn($i18n->get("zip_error"));
			return 0;
		}
		$zip->extractTree();
        $self->fixFilenames;
	} elsif ($filename =~ m/\.tar$/i) {
		Archive::Tar->extract_archive($filepath.'/'.$filename,1);
		if (Archive::Tar->error) {
			$self->session->log->warn(Archive::Tar->error);
			return 0;
		}
        $self->fixFilenames;
	} else {
		$self->session->log->warn($i18n->get("bad_archive"));
	}

	return 1;
}

#-------------------------------------------------------------------

=head2 fixFilenames ( )

Fix any files with dangerous extensions, in all files that were extracted.  This is done
locally, because if we used a method from Storage, then it would also rename HTML files.

=cut

sub fixFilenames {
	my $self    = shift;
    my $storage = $self->getStorageLocation;
    my $files   = $storage->getFiles('all');
    FILE: foreach my $file (@{ $files }) {
        my $extension = $storage->getFileExtension($file);
        next FILE unless $extension ~~ [qw/pl perl pm cgi php asp sh/];
        my $newFile = $file;
        #$newFile =~ s/\.$extension$/_$extension.txt/;
        $newFile =~ s/\.$extension$/_$extension.txt/;
        $storage->renameFile($file, $newFile);
    }
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

override prepareView => sub {
	my $self = shift;
	super();
	my $template = WebGUI::Asset::Template->newById($self->session, $self->get("templateId"));
	$template->prepare($self->getMetaDataAsTemplateVariables);
	$self->{_viewTemplate} = $template;
};


#-------------------------------------------------------------------

=head2 processEditForm ( )

Used to process properties from the form posted.  In this asset, we use
this method to deflate the zip file into the proper folder

=cut

override processEditForm => sub {
	my $self = shift;
	#File should be saved here by the superclass
	super();
	my $storage = $self->getStorageLocation();
	
	my $file = $self->filename;
	
	#return undef unless $file;
	my $i18n = WebGUI::International->new($self->session, 'Asset_ZipArchive');
	unless ($self->session->form->process("showPage")) {
		$storage->delete;
		$self->session->db->write("update FileAsset set filename=NULL where assetId=".$self->session->db->quote($self->getId));
		$self->session->scratch->set("za_error",$i18n->get("za_show_error"));
		return undef;
	}
	
	unless ($file =~ m/\.tar$/i || $file =~ m/\.zip$/i) {
		$storage->delete;
		$self->session->db->write("update FileAsset set filename=NULL where assetId=".$self->session->db->quote($self->getId));
		$self->session->scratch->set("za_error",$i18n->get("za_error"));
		return undef;
	}
	
	unless ($self->unzip($storage,$self->filename)) {
		$self->session->log->warn($i18n->get("unzip_error"));
	}
};


#-------------------------------------------------------------------

=head2 view ( )

Method called by the container www_view method.  In this asset, this is
used to show the file to administrators.

=cut

sub view {
	my $self = shift;
    my $cache = $self->session->cache;
    my $cacheKey = $self->getWwwCacheKey('view');
    if (!$self->session->isAdminOn && $self->cacheTimeout > 10) {
        my $out = $cache->get( $cacheKey );
		return $out if $out;
	}
	my %var = %{$self->get};
	#$self->session->log->warn($self->getId);
	$var{controls} = $self->getToolbar;
	if($self->session->scratch->get("za_error")) {
	   $var{error} = $self->session->scratch->get("za_error");
	}
	$self->session->scratch->delete("za_error");
	my $storage = $self->getStorageLocation;
	if($self->filename ne "") {
	   $var{fileUrl} = $storage->getUrl($self->showPage);
	   $var{fileIcon} = $storage->getFileIconUrl($self->showPage);
	}
	unless($self->showPage) {
	   $var{pageError} = "true";
	}
	my $i18n = WebGUI::International->new($self->session,"Asset_ZipArchive");
	$var{noInitialPage} = $i18n->get('noInitialPage');
	$var{noFileSpecified} = $i18n->get('noFileSpecified');
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
    if (!$self->session->isAdminOn && $self->cacheTimeout > 10) {
        $cache->set( $cacheKey, $out, $self->cacheTimeout);
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

Web facing method which is the default view page.  This method does a 
302 redirect to the "showPage" file in the storage location.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	if ($self->session->isAdminOn) {
		return $self->session->asset($self->getContainer)->www_view;
	}
	$self->session->response->setRedirect($self->getFileUrl($self->showPage));
	return "1";
}


__PACKAGE__->meta->make_immutable;
1;

