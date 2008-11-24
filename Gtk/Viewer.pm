package Gtk::Viewer;
use warnings;
use strict;

use Gtk2 '-init';

use Gtk::Common;
use Exception;

our $VERSION = '0.03';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant IMAGE_WIDTH    => 200;
use constant IMAGE_HEIGHT   => 340;

###############################################################################
# Static Final Global Vars
###############################################################################
my $WINDOW_TITLE = 'Viewer';

my @MENU_ITEM = (
 #  name,		stock id,   label
 [  "ViewMenu",		undef,      "_View" ],
 [  "BookmarksMenu",	undef,      "_Bookmarks" ],
 #  name,       stock id,       label,		accelerator,    tooltip,	func 
 [  "ZoomIn",	'gtk-zoom-in',	"_Zoom In",	"<control>plus",   "Zoom In",	undef ],
 [  "ZoomOut",	'gtk-zoom-out',	"Zoom _Out",	"<control>minus",   "Zoom Out",	undef ],
 [  "Normal",	'gtk-zoom-100',	"_Normal Size",	"<control>0",   "Normal Size",	undef ],
 [  "BestFit",	'gtk-zoom-fit',	"_Best Fit",	undef,		"Best Fit",	undef ],

 [  "BookmarkManga",	undef,	"Bookmark This Manga",	"<control>D",   "Bookmark This Manga",    undef ],
);

my $MENU_INFO = "
<menu action='ViewMenu'>
    <separator/>
    <menuitem action='ZoomIn'/>
    <menuitem action='ZoomOut'/>
    <menuitem action='Normal'/>
    <menuitem action='BestFit'/>
</menu>

<menu action='BookmarksMenu'>
    <menuitem action='BookmarkManga'/>
    <separator/>
</menu>";

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class, $width, $height) = @_;

    my $self = {
	_gtk_window		=> undef,
	_gtk_chapter		=> undef,
	_gtk_page		=> undef,
	_gtk_image		=> undef,
	_gtk_back		=> undef,
	_gtk_forward		=> undef
    };
    bless $self, $class;

    $self->_initalize($width, $height);
    return $self;
}


###############################################################################
# Initalize this window with all of the GTK settings
###############################################################################
sub _initalize {
    my ($self, $width, $height) = @_;

    # Create and setup the root window
    $self->{_gtk_window} = Gtk2::Window->new();
    $self->{_gtk_window}->set_title($WINDOW_TITLE);
    $self->{_gtk_window}->set_default_size($width, $height);

    # TODO: May want to refactor this out and define the interface in the
    # initalizer
    $self->{_gtk_window}->signal_connect(delete_event => sub {
	    $self->{_gtk_window}->destroy(); TRUE});

    # Create the VBox that will hold the MenuBar and the page display, 
    # Along with chapter/page info
    my $root_vbox = Gtk2::VBox->new();
    $self->{_gtk_window}->add($root_vbox);
    $root_vbox->pack_start(Gtk::Common->new()->init_menu_bar(
		\@MENU_ITEM, $MENU_INFO), FALSE, FALSE, 0);

    
    # Hbox to hold the dropdown
    my $combo_hbox = Gtk2::HBox->new();
    $root_vbox->pack_start($combo_hbox, FALSE, FALSE, 0);

    # Combo-box
    $self->{_gtk_chapter} = Gtk2::Combo->new(); 
    $self->{_gtk_page} = Gtk2::Combo->new(); 
    
    $combo_hbox->pack_start(Gtk2::Label->new('Chapters:'), FALSE, FALSE, 0);
    $combo_hbox->pack_start($self->{_gtk_chapter}, FALSE, FALSE, 0);
    
    $combo_hbox->pack_start(Gtk2::Label->new('Pages:'), FALSE, FALSE, 0);
    $combo_hbox->pack_start($self->{_gtk_page}, FALSE, FALSE, 0);


    # Image
    $self->{_gtk_image} = Gtk2::Image->new();
    my $scroll_image = Gtk2::ScrolledWindow->new();
    $scroll_image->set_policy('automatic', 'automatic');
    $scroll_image->add_with_viewport($self->{_gtk_image});
    
    $root_vbox->pack_start($scroll_image, TRUE, TRUE, 0);

    
    # Hbox to hold the buttons
    my $button_hbox = Gtk2::HBox->new();
    $root_vbox->pack_start($button_hbox, FALSE, FALSE, 0);

    $self->{_gtk_back} = Gtk2::Button->new_from_stock('gtk-go-back');
    $self->{_gtk_forward} = Gtk2::Button->new_from_stock('gtk-go-forward');

    $button_hbox->pack_start($self->{_gtk_back}, FALSE, TRUE, 0);
    $button_hbox->pack_end($self->{_gtk_forward}, FALSE, TRUE, 0);

}


###############################################################################
# Display the window
###############################################################################
sub display_window {
    my ($self) = @_;
    
    $self->{_gtk_window}->show_all();
}


1;
__END__
