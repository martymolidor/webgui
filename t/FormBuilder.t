# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use warnings;
use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::BestPractices;

use Carp;
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Constructor and properties
use_ok( 'WebGUI::FormBuilder' );

my $fb = WebGUI::FormBuilder->new( $session );
isa_ok( $fb, 'WebGUI::FormBuilder' );
is( $fb->method, 'POST', 'method default' );
ok( !$fb->action, 'action default' );
is( $fb->enctype, 'multipart/form-data', 'enctype default' );
ok( !$fb->name, 'name default' );

$fb = WebGUI::FormBuilder->new( $session,
    action      => '/myurl',
    enctype     => 'application/x-www-form-urlencoded',
    name        => 'search',
    method      => 'get',
    extras      => q{onclick="alert('hi');"},
);
isa_ok( $fb, 'WebGUI::FormBuilder' );
is( $fb->method, 'get' );
is( $fb->action, '/myurl' );
is( $fb->enctype, 'application/x-www-form-urlencoded' );
is( $fb->name, 'search' );
is( $fb->extras, q{onclick="alert('hi');"} );

# Test mutators
is( $fb->method("POST"), "POST" );
is( $fb->method, "POST" );
is( $fb->action('/otherurl'), '/otherurl' );
is( $fb->action, '/otherurl' );
is( $fb->enctype('multipart/form-data'), 'multipart/form-data' );
is( $fb->enctype, 'multipart/form-data' );
is( $fb->name('myname'), 'myname' );
is( $fb->name, 'myname' );
is( $fb->extras(""), "" );
is( $fb->extras, "" );

# getHeader
like( $fb->getHeader, qr{ method="POST"} );
like( $fb->getHeader, qr{ action="/otherurl"} );
like( $fb->getHeader, qr{ enctype="multipart/form-data"} );
like( $fb->getHeader, qr{ name="myname"} );

$fb->extras(q{onclick="alert()"});
like( $fb->getHeader, qr{ onclick="alert\(\)"} );

#----------------------------------------------------------------------------
# Adding objects
# -- This tests the HasTabs, HasFieldsets, and HasFields roles

# addTab with properties
my $tab = $fb->addTab( name => "mytab", label => "My Tab" );
isa_ok( $tab, 'WebGUI::FormBuilder::Tab' );
is( $fb->getTab('mytab'), $tab, 'getTab returns exact object' );
is( $fb->tabsets, $fb->tabsets, 'tabsets always returns same arrayref' );
cmp_deeply(
    $fb->tabsets,
    [ $fb->getTabset( "default" ) ],
    'tabsets',
);
cmp_deeply( 
    $fb->tabsets->[0]->tabs,
    [ $tab ],
    'tabs',
);

# addTab with objects
my $field = $tab->addField( 
    'WebGUI::Form::Text' => (
        name        => 'search',
        value       => "Search Now",
    ) 
);
my $fset = $tab->addFieldset(
    name        => 'advanced',
    label       => 'Advanced Search',
);
my $subtab = $tab->addTab(
    name        => 'more',
    label       => 'More',
);

my $newTab = $fb->addTab( $tab, name => 'newname' );
isa_ok( $newTab, 'WebGUI::FormBuilder::Tab' );
isnt( $newTab, $tab, 'addTab creates a new object from the properties' );
is( $newTab->name, 'newname', 'addTab allows property overrides' );
is( $newTab->label, 'My Tab', 'label was not overridden' );
ok( $newTab->fields->[0], 'field exists' );
is( $newTab->fields->[0]->get('name'), 'search', 'field has same name' );
ok( $newTab->fieldsets->[0], 'fieldset exists' );
is( $newTab->fieldsets->[0]->name, 'advanced', 'fieldset has same name' );
ok( $newTab->tabsets->[0], 'subtabset exists' );
is( $newTab->tabsets->[0]->name, 'default', 'subtabset has correct name' );
ok( $newTab->tabsets->[0]->tabs->[0], 'subtab exists' );
is( $newTab->tabsets->[0]->tabs->[0]->name, 'more', 'subtab has correct name' );

cmp_deeply( 
    $fb->tabsets->[0]->tabs,
    [ $tab, $newTab ],
    'added tab',
);
is( $fb->getTab('newname'), $newTab, 'new tab can be gotten' );

# deleteTab
my $deletedTab = $fb->deleteTab( 'newname' );
is( $deletedTab, $newTab, 'deleteTab returns object' );
cmp_deeply(
    $fb->tabsets->[0]->tabs,
    [ $tab ],
    'deleted tab',
);
ok( !$fb->getTab('newname'), 'deleted tab cannot be gotten' );

# addFieldset with properties
$fb     = WebGUI::FormBuilder->new( $session );
$fset   = $fb->addFieldset(
    name        => 'advanced',
    label       => 'Advanced Search',
);
is( $fb->getFieldset('advanced'), $fset, 'getFieldset returns exact object' );
is( $fb->fieldsets, $fb->fieldsets, 'fieldsets always returns same arrayref' );
cmp_deeply( 
    $fb->fieldsets,
    [ $fset ],
    'fieldsets',
);

# addFieldset with objects
$field = $fset->addField( 
    'WebGUI::Form::Text' => (
        name        => 'search',
        value       => "Search Now",
    ) 
);
my $subfset = $fset->addFieldset(
    name        => 'advanced',
    label       => 'Advanced Search',
);
$tab = $fset->addTab(
    name        => 'more',
    label       => 'More',
);

my $newFset = $fb->addFieldset( $fset, name => 'newname' );
isa_ok( $newFset, 'WebGUI::FormBuilder::Fieldset' );
isnt( $newFset, $fset, 'addFieldset creates a new object from the properties' );
is( $newFset->name, 'newname', 'addFieldset allows property overrides' );
is( $newFset->label, 'Advanced Search', 'label was not overridden' );
ok( $newFset->fields->[0], 'field exists' );
is( $newFset->fields->[0]->get('name'), 'search', 'field has same name' );
ok( $newFset->fieldsets->[0], 'subfieldset exists' );
is( $newFset->fieldsets->[0]->name, 'advanced', 'subfieldset has same name' );
ok( $newFset->tabsets->[0]->tabs->[0], 'tab exists' );
is( $newFset->tabsets->[0]->tabs->[0]->name, 'more', 'tab has same name' );
cmp_deeply( 
    $fb->fieldsets,
    [ $fset, $newFset],
    'added fieldset',
);
is( $fb->getFieldset('newname'), $newFset, 'new fieldset can be gotten' );

# deletefieldset
my $deletedFieldset = $fb->deleteFieldset( 'newname' );
is( $deletedFieldset, $newFset, 'deletefieldset returns object' );
cmp_deeply(
    $fb->fieldsets,
    [ $fset ],
    'deleted fieldset',
);
ok( !$fb->getFieldset('newname'), 'deleted fieldset cannot be gotten' );

# addField with properties
$fb         = WebGUI::FormBuilder->new( $session );
$field   = $fb->addField( 
    'Text' => (
        name        => 'search',
        value       => 'Search Now',
    )
);

isa_ok( $field, 'WebGUI::Form::Text' );
is( $fb->getField('search'), $field, 'getField returns exact object' );
is( $fb->fields, $fb->fields, 'fields always returns same arrayref' );
cmp_deeply( 
    $fb->fields,
    [ $field ],
    'fields',
);

# addField with object
my $field2 = $fb->addField(
    WebGUI::Form::Text->new( $session, {
        name        => 'type',
        label       => "Asset Type",
    } )
);
isa_ok( $field2, 'WebGUI::Form::Text' );
is( $fb->getField('type'), $field2, 'getField returns exact object' );
cmp_deeply(
    $fb->fields,
    [ $field, $field2 ],
    'fields 2',
);

# deleteField
my $field3 = $fb->deleteField( 'type' );
is( $field3, $field2, 'deleteField returns same field' );
ok( !$fb->getField('type'), 'field is deleted' );
cmp_deeply(
    $fb->fields,
    [ $field ],
    'field is deleted from fields',
);

# addFieldAt
$fb     = WebGUI::FormBuilder->new( $session );
$field  = $fb->addField( 'Text', name => "zero" );

$tab    = $fb->addTab( tabset => 'one', name => 'one' );
$fset   = $fb->addFieldset( name => 'three', label => 'Three' );
$field2 = $fb->addFieldAt( WebGUI::Form::Text->new( $session, name => "two" ), 2 );

cmp_deeply( 
    $fb->objects,
    [ $field, $fb->getTabset('one'), $field2, $fset ], 
    'objects array is correct',
);
cmp_deeply( 
    $fb->fields,
    [ $field, $field2 ], 
    'fields array is correct',
);

#----------------------------------------------------------------------------
# Serialize and deserialize

$fb      = WebGUI::FormBuilder->new( $session );
$fset    = $fb->addFieldset( name => 'search', label => 'Search' );
$fset->addField( 'text', name => 'keywords', label => 'Keywords' );
$tab     = $fb->addTab( name => 'advanced', label => 'Advanced Search' );
$tab->addField( 'text', name => 'type', label => 'Type' );
$fb->addField( 'submit', name => 'submit', label => 'Submit' );


#----------------------------------------------------------------------------
# toTemplateVars

$fb  = WebGUI::FormBuilder->new( $session );
$field = $fb->addField( 'Text', name => 'field1' );
my $fieldset = $fb->addFieldset( name => 'two', label => 'Two' );
my $fieldsetField = $fieldset->addField( 'Text', name => 'two one' );
$tab = $fb->addTab( name => 'three 1', label => 'Three 1' );
$tab->addField( 'Text', name => 'three 1 1' );
my $tab2 = $fb->addTab( name => 'three 2', label => 'Three 2' );
$tab2->addField( 'Checkbox', name => 'three 2 1' );
$tab2->addField( 'Checkbox', name => 'three 2 1' );
$field2 = $fb->addField( 'Submit', name => 'submit' );
$field3 = $fb->addField( 'Button', name => 'cancel' );

my $expected_var = {
    header       => $fb->getHeader,
    footer       => $fb->getFooter,
    %{ object_vars( $fb ) },
};

# Add the prefix
$expected_var = { map { ("fb_$_" => delete $expected_var->{$_}) } keys %$expected_var };

cmp_deeply(
    $fb->toTemplateVars('fb_'),
    $expected_var,
    'toTemplateVars complete and correct'
);

done_testing;

sub field_vars {
    my $field = shift;
    my $var = {
        field   => $field->toHtmlWithWrapper,
        field_input => $field->toHtml,
        %{$field->toTemplateVars}, # not testing field's toTemplateVars method
    };
    return $var;
}

sub fieldset_vars {
    my $fieldset = shift;
    return {
        name    => $fieldset->name,
        label   => $fieldset->label,
        legend  => $fieldset->legend,
        isFieldset => 1,
        %{object_vars( $fieldset )},
    };
}

sub tabset_vars {
    my $tabset = shift;
    my $var = {
        name    => $tabset->name,
        isTabset => 1,
        tabs    => [ map { { %{object_vars( $_ )}, name => $_->name, label => $_->label } } @{$tabset->tabs} ],
    };
    for my $tab ( @{ $var->{tabs} } ) {
        my $name = $tab->{name};
        $var->{ "tabs_${name}" } = ignore(); # Ignore html for tabs, just as long as it's there
        for my $key ( keys %$tab ) {
            $var->{ "tabs_${name}_${key}" } = $tab->{ $key };
        }
    }
    return $var;
}

sub object_vars {
    my $f = shift;
    my $var = {};

    # Stream of objects
    for my $obj ( @{$f->objects} ) {
        use Scalar::Util qw(blessed);
        given ( blessed $obj ) {
            when ( undef ) {
                push @{$var->{objects}}, $obj;
            }
            when ( $_->isa( 'WebGUI::FormBuilder::Tabset' ) ) {
                my $props  = tabset_vars( $obj );
                my $name   = $props->{name};
                for my $key ( keys %$props ) {
                    $var->{ "tabset_${name}_${key}" } = $props->{$key};
                }
                push @{ $var->{tabsetloop} }, $props;
                push @{$var->{objects}}, $props;
            }
            when ( $_->isa( 'WebGUI::FormBuilder::Fieldset' ) ) {
                my $props  = fieldset_vars( $obj );
                my $name   = $props->{name};
                for my $key ( keys %$props ) {
                    $var->{ "fieldset_${name}_${key}" } = $props->{$key};
                }
                push @{ $var->{fieldsetloop} }, $props;
                push @{$var->{objects}}, $props;
            }
            when ( $_->isa( 'WebGUI::Form::Control' ) ) {
                my $props   = field_vars( $obj );
                my $name    = $props->{name};
                for my $key ( keys %$props ) {
                    $var->{ "field_${name}_${key}" } = $props->{$key};
                }
                push @{$var->{ "field_${name}_loop" }}, $props;
                push @{ $var->{fieldloop} }, $props;
                $var->{ "field_${name}" } = $props->{field};
                push @{$var->{objects}}, $props;
            }
        }
    }

    return $var;
}

#vim:ft=perl


