package WebGUI::Asset::Post::Thread;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::Template;
use WebGUI::Asset::Post;
use WebGUI::Group;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(WebGUI::Asset::Post);

#-------------------------------------------------------------------
sub archive {
	my $self = shift;
	foreach my $post (@{$self->getPosts}) {
		$post->setStatusArchived;
	}
}

#-------------------------------------------------------------------
sub canReply {
	my $self = shift;
	return !$self->isLocked && $self->getParent->get("allowReplies") && $self->getParent->canPost;
}

#-------------------------------------------------------------------
sub canSubscribe {
	my $self = shift;
	return ($self->session->user->userId ne "1" && $self->canView);
}

#-------------------------------------------------------------------
sub createSubscriptionGroup {
	my $self = shift;
	return if ($self->get("subscriptionGroupId"));
	my $group = WebGUI::Group->new($self->session, "new");
	$group->name($self->getId);
	$group->description("The group to store subscriptions for the thread ".$self->getId);
	$group->isEditable(0);
	$group->showInForms(0);
	$group->deleteGroups(['3']); # admins don't want to be auto subscribed to this thing
	$self->update({
		subscriptionGroupId=>$group->getId
		});
}

#-------------------------------------------------------------------

=head2 decrementReplies ( )

Deccrements this reply counter.

=cut

sub decrementReplies {
        my $self = shift;
	$self->update({replies=>$self->get("replies")-1});
	$self->getParent->decrementReplies;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Thread");
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'thread.gif',
                tableName=>'Thread',
                className=>'WebGUI::Asset::Post::Thread',
                properties=>{
			subscriptionGroupId => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			replies => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			isSticky => {
				fieldType=>"yesNo",
				defaultValue=>0
				},
			isLocked => {
				fieldType=>"yesNo",
				defaultValue=>0
				},
			lastPostId => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			lastPostDate => {
				noFormPost=>1,
				fieldType=>"dateTime",
				defaultValue=>undef
				},
			karma => {
				noFormPost=>1,
				fieldType=>"integer",
				defaultValue=>0
				},
			karmaRank => {
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>0
				},
			karmaScale => {
				noFormPost=>1,
				fieldType=>"integer",
				defaultValue=>1
				}
			},
		});
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

sub DESTROY {
	my $self = shift;
	return unless defined $self;
	$self->{_next}->DESTROY if (defined $self->{_next});
	$self->{_previous}->DESTROY if (defined $self->{_previous});
	$self->SUPER::DESTROY;
}



#-------------------------------------------------------------------

=head2 getArchiveUrl ( ) 

Formats the url to set the status of a thread archived.

=cut

sub getArchiveUrl {
	my $self = shift;
	$self->getUrl("func=archive");
}

#-------------------------------------------------------------------
sub getLastPost {
	my $self = shift;
	my $lastPostId = $self->get("lastPostId");
	my $lastPost;
	if ($lastPostId) {
		$lastPost = WebGUI::Asset::Post->new($self->session, $lastPostId);
	}
	return $lastPost if (defined $lastPost);
	return $self;	
}

#-------------------------------------------------------------------

=head2 getLayoutUrl ( layout )

Formats the url to change the layout of a thread.

=head3 layout

A string indicating the type of layout to use. Can be flat or nested.

=cut

sub getLayoutUrl {
	my $self = shift;
	my $layout = shift;
	return $self->session->asset->getUrl("layout=".$layout.'#id'.$self->session->asset->getId) if ($self->session->asset);
	return $self->getUrl("layout=".$layout);
}

#-------------------------------------------------------------------

=head2 getLockUrl ( )

Formats the url to lock a thread.

=cut

sub getLockUrl {
	my $self = shift;
	$self->getUrl("func=lockThread");
}


#-------------------------------------------------------------------

=head2 getNextThread ( )

Returns a thread object for the next (newer) thread in the same forum.

=cut

sub getNextThread {
	my $self = shift;
        unless (defined $self->{_next}) {
		my $sortBy = $self->getParent->getValue("sortBy");
		my ($id, $class, $version) = $self->session->dbSlave->quickArray("
				select asset.assetId,asset.className,max(assetData.revisionDate)
				from Thread
				left join asset on asset.assetId=Thread.assetId 
				left join assetData on assetData.assetId=Thread.assetId and assetData.revisionDate=Thread.revisionDate
				left join Post on Post.assetId=assetData.assetId and assetData.revisionDate=Post.revisionDate
				where asset.parentId=".$self->session->db->quote($self->get("parentId"))." 
					and asset.state='published' 
					and asset.className='WebGUI::Asset::Post::Thread'
					and ".$sortBy.">".$self->session->db->quote($self->get($sortBy))." 
					and (
						assetData.status in ('approved','archived')
						 or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag"))."
						or (assetData.ownerUserId=".$self->session->db->quote($self->session->user->userId)." and assetData.ownerUserId<>'1')
						)
				group by assetData.assetId
				order by ".$sortBy." asc 
				");
		$self->{_next} = WebGUI::Asset->new($self->session, $id,$class,$version);
	#	delete $self->{_next} unless ($self->{_next}->{_properties}{className} =~ /Thread/);
	};
	return $self->{_next};
}



#-------------------------------------------------------------------

=head2 getPosts ( ) 

Returns a list of the post objects in this thread, including the thread post itself.

=cut

sub getPosts {
	my $self = shift;
	$self->getLineage(["self","descendants"], {returnObjects=>1});	
}

#-------------------------------------------------------------------

=head2 getPreviousThread ( )

Returns a thread object for the previous (older) thread in the same forum.

=cut

sub getPreviousThread {
	my $self = shift;
        unless (defined $self->{_previous}) {
		my $sortBy = $self->getParent->getValue("sortBy");
		my ($id, $class, $version) = $self->session->dbSlave->quickArray("
				select asset.assetId,asset.className,max(assetData.revisionDate)
				from Thread
				left join asset on asset.assetId=Thread.assetId 
				left join assetData on assetData.assetId=Thread.assetId and assetData.revisionDate=Thread.revisionDate
				left join Post on Post.assetId=assetData.assetId and assetData.revisionDate=Post.revisionDate
				where asset.parentId=".$self->session->db->quote($self->get("parentId"))." 
					and asset.state='published' 
					and asset.className='WebGUI::Asset::Post::Thread'
					and ".$sortBy."<".$self->session->db->quote($self->get($sortBy))." 
					and (
						assetData.status in ('approved','archived')
						 or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag"))."
						or (assetData.ownerUserId=".$self->session->db->quote($self->session->user->userId)." and assetData.ownerUserId<>'1')
						)
				group by assetData.assetId
				order by ".$sortBy." desc, assetData.revisionDate desc ");
		$self->{_previous} = WebGUI::Asset::Post::Thread->new($self->session, $id,$class,$version);
	#	delete $self->{_previous} unless ($self->{_previous}->{_properties}{className} =~ /Thread/);
	};
	return $self->{_previous};
}


#-------------------------------------------------------------------

=head2 getStickUrl ( )

Formats the url to make a thread sticky.

=cut

sub getStickUrl {
	my $self = shift;
	return $self->getUrl("func=stick");
}

#-------------------------------------------------------------------

=head2 getSubscribeUrl (  )

Formats the url to subscribe to the thread

=cut

sub getSubscribeUrl {
	my $self = shift;
	return $self->getUrl("func=subscribe");
}


#-------------------------------------------------------------------
sub getThread {
	return shift;
}

#-------------------------------------------------------------------

=head2 getUnarchiveUrl ( ) 

Formats the url to set the status of a thread unarchived.

=cut

sub getUnarchiveUrl {
	my $self = shift;
	$self->getUrl("func=unarchive");
}

#-------------------------------------------------------------------

=head2 getUnlockUrl ( )

Formats the url to unlock the thread

=cut

sub getUnlockUrl {
	my $self = shift;
	return $self->getUrl("func=unlockThread");
}


#-------------------------------------------------------------------

=head2 getUnstickUrl ( )

Formats the url to unstick the thread

=cut

sub getUnstickUrl {
	my $self = shift;
	return $self->getUrl("func=unstick");
}

#-------------------------------------------------------------------

=head2 getUnsubscribeUrl ( )

Formats the url to unsubscribe from the thread

=cut

sub getUnsubscribeUrl {
	my $self = shift;
	return $self->getUrl("func=unsubscribe");
}


#-------------------------------------------------------------------

=head2 isLocked ( )

Returns a boolean indicating whether this thread is locked from new posts and other edits.

=cut

sub isLocked {
        my ($self) = @_;
        return $self->get("isLocked");
}


#-------------------------------------------------------------------

=head2 incrementReplies ( lastPostDate, lastPostId )

Increments the replies counter for this thread.

=head3 lastPostDate

The date of the reply that caused the replies counter to be incremented.

=head3 lastPostId

The id of the reply that caused the replies counter to be incremented.

=cut

sub incrementReplies {
        my ($self, $dateOfReply, $replyId) = @_;
        $self->update({replies=>$self->get("replies")+1, lastPostId=>$replyId, lastPostDate=>$dateOfReply});
        $self->getParent->incrementReplies($dateOfReply,$replyId);
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter for this thread.

=cut

sub incrementViews {
        my ($self) = @_;
        $self->update({views=>$self->get("views")+1});
        $self->getParent->incrementViews;
}

#-------------------------------------------------------------------

=head2 isMarkedRead ( )

Returns a boolean indicating whether this thread is marked read for the user.

=cut

sub isMarkedRead {
        my $self = shift;
	return 1 if $self->isPoster;
      my ($isRead) = $self->session->db->quickArray("select count(*) from Post_read where userId=".$self->session->db->quote($self->session->user->userId)." and threadId=".$self->session->db->quote($self->getId)." and postId=".$self->session->db->quote($self->get("lastPostId")));
        return $isRead;
}

#-------------------------------------------------------------------

=head2 isSticky ( )

Returns a boolean indicating whether this thread should be "stuck" a the top of the forum and not be sorted with the rest of the threads.

=cut

sub isSticky {
        my ($self) = @_;
        return $self->get("isSticky");
}


#-------------------------------------------------------------------

=head2 isSubscribed ( )

Returns a boolean indicating whether the user is subscribed to this thread.

=cut

sub isSubscribed {
	my $self = shift;
	return $self->session->user->isInGroup($self->get("subscriptionGroupId"));
}

#-------------------------------------------------------------------

=head2 lock ( )

Sets this thread to be locked from edits.

=cut

sub lock {
        my ($self) = @_;
        $self->update({isLocked=>1});
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->getParent->get("threadTemplateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;	
	if ($self->get("subscriptionGroupId") eq "") {
		$self->createSubscriptionGroup;
	}
	if ($self->session->form->process("assetId") eq "new") {
        	$self->getParent->incrementThreads($self->get("dateUpdated"),$self->getId) unless ($self->isReply);
	}
	if ($self->getParent->canEdit) {
		my $karmaScale = $self->session->form("karmaScale","integer") || 1;
		$self->update({karmaScale=>$karmaScale, karmaRank=>$self->get("karma")/$karmaScale});
	}
}


#-------------------------------------------------------------------

=head2 rate ( rating )

Stores a rating against this post.

=head3 rating

An integer between 1 and 5 (5 being best) to rate this post with.

=cut

sub rate {
	my $self = shift;
	my $rating = shift;
	unless ($self->hasRated) {
		$self->session->db->write("insert into Post_rating (assetId,userId,ipAddress,dateOfRating,rating) values ("
			.$self->session->db->quote($self->getId).", ".$self->session->db->quote($self->session->user->userId).", ".$self->session->db->quote($self->session->env->get("REMOTE_ADDR")).",
		".$self->session->datetime->time().", ".$self->session->db->quote($rating).")");
		my ($count) = $self->session->db->quickArray("select count(*) from Post left join asset on Post.assetId=asset.assetId where Post.threadId=".$self->session->db->quote($self->getId)." and Post.rating>0");
		$count = $count || 1;
		my ($sum) = $self->session->db->quickArray("select sum(Post.rating) from Post left join asset on Post.assetId=asset.assetId where Post.threadId=".$self->session->db->quote($self->getId)." and Post.rating>0");
		my $average = round($sum/$count);
		$self->update({rating=>$average});
		if ($self->session->setting->get("useKarma")) {
			my $poster = WebGUI::User->new($self->session, $self->get("ownerUserId"));
			$poster->karma($rating*$self->getParent->get("karmaRatingMultiplier"),"collaboration rating","someone rated post ".$self->getId);
			my $rater = WebGUI::User->new($self->session->user->userId);
			$rater->karma(-$self->getParent->get("karmaSpentToRate"),"collaboration rating","spent karma to rate post ".$self->getId);
		}
		$self->getParent->recalculateRating;
	}
}


#-------------------------------------------------------------------

=head2 setLastPost ( id, date )

Sets the last reply of this thread.

=head3 id

The assetId of the most recent post.

=head3 date

The date of the most recent post.

=cut

sub setLastPost {
        my $self = shift;
        my $id = shift;
        my $date = shift;
        $self->update({lastPostId=>$id, lastPostDate=>$date});
        $self->getParent->setLastPost($id,$date);
}


#-------------------------------------------------------------------

=head2 setParent ( newParent ) 

We're overloading the setParent in Asset because we don't want threads to be able to be posted to anything other than other collaboration systems.

=head3 newParent 
        
An asset object to make the parent of this asset.

=cut

sub setParent {
        my $self = shift;
        my $newParent = shift;
        return 0 unless ($newParent->get("className") eq "WebGUI::Asset::Wobject::Collaboration");
        # specify the Asset package here directly because we don't want to use the ruls in WebGUI::Asset::Post, as they don't fit for Threads.
        return $self->WebGUI::Asset::setParent($newParent);
}  



#-------------------------------------------------------------------

=head2 stick ( )

Makes this thread sticky.

=cut

sub stick {
        my ($self) = @_;
        $self->update({isSticky=>1});
}

#-------------------------------------------------------------------

=head2 subscribe (  )

Subscribes the user to this thread.

=cut

sub subscribe {
	my $self = shift;
	$self->createSubscriptionGroup;
	my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
  $group->addUsers([$self->session->user->userId]);
}

#-------------------------------------------------------------------

=head2 trash

Moves thread to the trash and decrements reply counter on thread.

=cut

sub trash {
        my $self = shift;
        $self->SUPER::trash;
        $self->getParent->decrementThreads;
        if ($self->getParent->get("lastPostId") eq $self->getId) {
                my $parentLineage = $self->getThread->get("lineage");
                my ($id, $date) = $self->session->db->quickArray("select Post.assetId, Post.dateSubmitted from Post, asset where asset.lineage like ".$self->session->db->quote($parentLineage.'%')." and Post.assetId<>".$self->session->db->quote($self->getId)." and Post.assetId=asset.assetId and asset.state='published' order by Post.dateSubmitted desc");
                $self->getParent->setLastPost('','') ? $self->getParent->setLastPost($id,$date) : $id;
        }
}


#-------------------------------------------------------------------

=head2 unarchive ( ) 

Unarchives this thread.

=cut
 
sub unarchive {
	my $self = shift;
	foreach my $post (@{$self->getPosts}) {
		$post->setStatusUnarchived;
	}
}

#-------------------------------------------------------------------

=head2 unlock ( )

Negates the lock method.

=cut

sub unlock {
        my ($self) = @_;
        $self->update({isLocked=>0});
}

#-------------------------------------------------------------------

=head2 unstick ( )

Negates the stick method.

=cut

sub unstick {
        my ($self) = @_;
        $self->update({isSticky=>0});
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Negates the subscribe method.

=cut

sub unsubscribe {
	my $self = shift;
  my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
  $group->deleteUsers([$self->session->user->userId]);
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
        $self->markRead;
        $self->incrementViews unless ($self->session->form->process("func") eq 'rate');
        $self->session->scratch->set("discussionLayout",$self->session->form->process("layout"));
        my $var = $self->getTemplateVars;
	$self->getParent->appendTemplateLabels($var);

        $var->{'user.isVisitor'} = ($self->session->user->userId eq '1');
        $var->{'user.isModerator'} = $self->getParent->canEdit;
        $var->{'user.canPost'} = $self->getParent->canPost;
        $var->{'user.canReply'} = $self->canReply;
        $var->{'repliesAllowed'} = $self->getParent->get("allowReplies");

        $var->{'layout.nested.url'} = $self->getLayoutUrl("nested");
        $var->{'layout.flat.url'} = $self->getLayoutUrl("flat");
        my $layout = $self->session->scratch->get("discussionLayout") || $self->session->user->profileField("discussionLayout");
        $var->{'layout.isFlat'} = ($layout eq "flat");
        $var->{'layout.isNested'} = ($layout eq "nested" || !$var->{'layout.isFlat'});

        $var->{'user.isSubscribed'} = $self->isSubscribed;
        $var->{'subscribe.url'} = $self->getSubscribeUrl;
        $var->{'unsubscribe.url'} = $self->getUnsubscribeUrl;

        $var->{'isArchived'} = $self->get("status") eq "archived";
        $var->{'archive.url'} = $self->getArchiveUrl;
        $var->{'unarchive.url'} = $self->getUnarchiveUrl;

        $var->{'isSticky'} = $self->isSticky;
        $var->{'stick.url'} = $self->getStickUrl;
        $var->{'unstick.url'} = $self->getUnstickUrl;

        $var->{'isLocked'} = $self->isLocked;
        $var->{'lock.url'} = $self->getLockUrl;
        $var->{'unlock.url'} = $self->getUnlockUrl;

	$var->{'transfer.karma.form'} = WebGUI::Form::formHeader($self->session, {action=>$self->getUrl})
		.WebGUI::Form::hidden($self->session, {
			name=>"func",
			value=>"transferKarma"
			})
		.WebGUI::Form::integer($self->session, {
			name=>"karma",
			value=>10
			})
		.WebGUI::Form::submit($self->session)
		.WebGUI::Form::formFooter($self->session);

        my $p = WebGUI::Paginator->new($self->session,$self->getUrl,$self->getParent->get("postsPerPage"));
	my $sql = "select asset.assetId, asset.className, assetData.revisionDate as revisionDate, assetData.url as url from asset 
		left join assetData on assetData.assetId=asset.assetId
		left join Post on Post.assetId=assetData.assetId and assetData.revisionDate=Post.revisionDate
		where asset.lineage like ".$self->session->db->quote($self->get("lineage").'%')
		."	and asset.state='published'
		and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId
			and (
				assetData.status in ('approved','archived')
						 or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag"));
	$sql .= "		or assetData.status='pending'" if ($self->getParent->canEdit);
	$sql .= "		or (assetData.ownerUserId=".$self->session->db->quote($self->session->user->userId)." and assetData.ownerUserId<>'1')
			))
		group by assetData.assetId
		order by ";
	if ($layout eq "flat") {
		$sql .= "Post.dateSubmitted";
	} else {
		$sql .= "asset.lineage";
	}
	my $currentPageUrl = $self->session->url->getRequestedUrl;
	$p->setDataByQuery($sql, undef, undef, undef, "url", $currentPageUrl);
	foreach my $dataSet (@{$p->getPageData()}) {
		next unless ($dataSet->{className} eq "WebGUI::Asset::Post" || $dataSet->{className} eq "WebGUI::Asset::Post::Thread"); #handle non posts!
		my $reply = WebGUI::Asset::Post->new($self->session, $dataSet->{assetId}, $dataSet->{className}, $dataSet->{revisionDate});
		$reply->{_thread} = $self; # caching thread for better performance
		my %replyVars = %{$reply->getTemplateVars};
		$replyVars{isCurrent} = ($reply->get("url") eq $currentPageUrl);
		$replyVars{isThreadRoot} = $self->getId eq $reply->getId;
		$replyVars{depth} = $reply->getLineageLength - $self->getLineageLength;
		$replyVars{depthX10} = $replyVars{depth}*10;
        	my @depth_loop;
		#@{$replyVars{indent_loop}} = {};
        	for (my $i=0; $i<$replyVars{depth}; $i++) {
                	push(@{$replyVars{indent_loop}},{depth=>$i});
        	}
		push (@{$var->{post_loop}}, \%replyVars);
	}		
	$p->appendTemplateVars($var);
        $var->{'add.url'} = $self->getParent->getNewThreadUrl;
 
	my $previous = $self->getPreviousThread;
	$var->{"previous.url"} = $previous->getUrl if (defined $previous);
	my $next = $self->getNextThread;
	$var->{"next.url"} = $next->getUrl if (defined $next);

	$var->{"search.url"} = $self->getParent->getSearchUrl;
        $var->{"collaboration.url"} = $self->getThread->getParent->getUrl;
        $var->{'collaboration.title'} = $self->getParent->get("title");
        $var->{'collaboration.description'} = $self->getParent->get("description");
	return $self->processTemplate($var,undef,$self->{_viewTemplate});
}


#-------------------------------------------------------------------

=head2 www_archive ( )

The web method to archive all the posts in this thread.

=cut

sub www_archive {
	my $self = shift;
	$self->archive if ($self->canEdit);
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_lock (  )

The web method to lock a thread.

=cut

sub www_lockThread {
	my $self = shift;
	$self->lock if $self->getParent->canEdit;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_stick ( )

The web method to make a thread sticky.

=cut

sub www_stick {
	my $self = shift;
	$self->stick if $self->getParent->canEdit;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_subscribe ( )

The web method to subscribe to a thread.

=cut

sub www_subscribe {
	my $self = shift;
	$self->subscribe if $self->canSubscribe;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_transferKarma ( )

Transfers karma from the current user to this thread.

=cut

sub www_transferKarma {
	my $self = shift;
	my $amount = $self->session->form->get("karma","integer");
	# cant have them giving more karma then they have
	if ($amount <= $self->session->user->karma) {
		$self->session->user->karma($amount, "Thread ".$self->getId, "Transferring karma to a thread.");
		my $newKarma = $self->get("karma")+$amount;
		$self->update({karma=>$newKarma,karmaRank=>$newKarma/$self->get("karmaScale")});
	}
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unarchive ( )

The web method to unarchive all the posts in this thread.

=cut

sub www_unarchive {
	my $self = shift;
	$self->unarchive if ($self->canEdit);
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unlock ( )

The web method to unlock a thread.

=cut

sub www_unlockThread {
	my $self = shift;
	$self->unlock if $self->getParent->canEdit;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unstick (  )

The web method to make a sticky thread normal again.

=cut

sub www_unstick {
	my $self = shift;
	$self->unstick if $self->getParent->canEdit;
	$self->www_view;
}

#-------------------------------------------------------------------

=head2 www_threadUnsubscribe ( )

The web method to unsubscribe from a thread.

=cut

sub www_unsubscribe {
	my $self = shift;
	$self->unsubscribe if $self->canSubscribe;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_view (  )

Renders self->view based upon current style, subject to timeouts. Returns Privilege::noAccess() if canView is False.

=cut

sub www_view {
        my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
        unless ($self->canView) {
                if ($self->get("state") eq "published") { # no privileges, make em log in
                        return $self->session->privilege->noAccess();
                } elsif ($self->session->var->get("adminOn") && $self->get("state") =~ /^trash/) { # show em trash
                        $self->session->http->setRedirect($self->getUrl("func=manageTrash"));
                        return undef;
                } elsif ($self->session->var->get("adminOn") && $self->get("state") =~ /^clipboard/) { # show em clipboard
                        $self->session->http->setRedirect($self->getUrl("func=manageClipboard"));
                        return undef;
                } else { # tell em it doesn't exist anymore
                        $self->session->http->setStatus("410");
                        return WebGUI::Asset->getNotFound($self->session)->www_view;
                }
        }
        # must find a way to do this next line better
        $self->session->http->setCookie("wgSession",$self->session->var->{_var}{sessionId}) unless $self->session->var->{_var}{sessionId} eq $self->session->http->getCookies->{"wgSession"};
        $self->session->http->getHeader;    
        $self->prepareView;
        my $style = $self->getParent->processStyle("~~~");
        my ($head, $foot) = split("~~~",$style);
        $self->session->output->print($head);
        $self->session->output->print($self->view);
        $self->session->output->print($foot);
        return "chunked";
}



1;

