#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Form;
use WebGUI::Form::ClassName;
use WebGUI::Session;
use HTML::Form;
use WebGUI::Form_Checking;

#The goal of this test is to verify that ClassName form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

my $testBlock = [
	{
		key => 'Class1',
		testValue => 'WebGUI-test::Asset',
		expected  => 'WebGUItest::Asset',
		comment   => 'invalid: dash',
	},
	{
		key => 'Class2',
		testValue => 'WebGUI/test::Asset',
		expected  => 'WebGUItest::Asset',
		comment   => 'invalid: slash',
	},
	{
		key => 'Class3',
		testValue => 'WebGUI::Test Class',
		expected => 'WebGUI::TestClass',
		comment   => 'invalid: space',
	},
	{
		key => 'Class4',
		testValue => 'WebGUI::Class4',
		expected  => 'EQUAL',
		comment   => 'valid: digit',
	},
	{
		key => 'Class5',
		testValue => 'WebGUI::Image::XY_Graph',
		expected  => 'EQUAL',
		comment   => 'valid: underscore',
	},
	{
		key => 'Class6',
		testValue => 'WebGUI::Class',
		expected  => 'EQUAL',
		comment   => 'valid: simple module',
	},
];

my $formClass = 'WebGUI::Form::ClassName';
my $formType = 'ClassName';

my $numTests = 7 + scalar @{ $testBlock } + 3;


plan tests => $numTests;

my ($header, $footer) = (WebGUI::Form::formHeader($session), WebGUI::Form::formFooter($session));

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'TestClass',
		value => 'WebGUI::Asset::File',
	})->toHtml,
	$footer;

my @forms = HTML::Form->parse($html, 'http://www.webgui.org');

##Test Form Generation

is(scalar @forms, 1, '1 form was parsed');

my @inputs = $forms[0]->inputs;
is(scalar @inputs, 2, 'The form has 2 input');

#Basic tests

my $input = $inputs[1];
is($input->name, 'TestClass', 'Checking input name');
is($input->type, 'hidden', 'Checking input type');
is($input->value, 'WebGUI::Asset::File', 'Checking default value');

##Test Form Output parsing

my $html = join "\n",
	$header, 
	$formClass->new($session, {
		name => 'StorageClass',
		value => 'WebGUI::Storage',
	})->toHtml,
	$footer;

@forms = HTML::Form->parse($html, 'http://www.webgui.org');
@inputs = $forms[0]->inputs;
my $input = $inputs[1];
is($input->name, 'StorageClass', 'Checking input name');
is($input->value, 'WebGUI::Storage', 'Checking default value');

##Test Form Output parsing

#note $formType;
WebGUI::Form_Checking::auto_check($session, $formType, $testBlock);

#
# test WebGUI::FormValidator::ClassName(undef,@values)
#
is(WebGUI::Form::ClassName->new($session)->getValue('t*est'), 'test', '$cname->getValue(arg)');
is($session->form->className(undef,'t*est'),                          'test', 'WebGUI::FormValidator::className');
