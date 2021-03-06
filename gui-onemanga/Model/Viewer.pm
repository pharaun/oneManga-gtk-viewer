package Model::Viewer;
use warnings;
use strict;

use Gtk2 '-init';
use Data::Dumper;

use Util::Exception;

our $VERSION = '0.02';

use constant TRUE   => 1;
use constant FALSE  => 0;

use constant COLUMN_CHAPTER_ID	    => 0;
use constant COLUMN_CHAPTER_NUMBER  => 1;
use constant COLUMN_CHAPTER_NAME    => 2;
use constant COLUMN_CHAPTER_PAGE_ID => 3;
use constant NUM_COLUMNS_CHAPTER    => 4;

use constant COLUMN_CHP_ID	    => 0;
use constant COLUMN_PAGE_ID	    => 1;
use constant COLUMN_PAGE_NUMBER	    => 2;
use constant COLUMN_PAGE_NAME	    => 3;
use constant COLUMN_PAGE_TMP_PIC    => 4;
use constant NUM_COLUMNS_PAGE	    => 5;


###############################################################################
# Static Final Global Vars
###############################################################################
# Sample Chapter data
# <Chapter Table ID>, <Chapter Number>, <Chapter Name>, <Beginning Chapter Page id>
my @chp_data = (
    { id => 0, number => 56, name => '56 - Viewer\'s Polls', page => 1 },
    { id => 1, number => 57, name => '57 - Tsuruta Festival', page => 4 },
    { id => 2, number => 58, name => '58 - Guest Appearance', page => 8 },
    { id => 3, number => 59, name => '59 - Hoooo!', page => 12 },
    { id => 4, number => 60, name => '60 - Terror', page => 16 },
    { id => 5, number => 61, name => '61 - Akumetsu\'s True Motive', page => 20 },
    { id => 6, number => 62, name => '62 - If I Don\'t Do It', page => 24 },
    { id => 7, number => 63, name => '63 - Accomplice', page => 28 },
);

# Sample Page Data
# <Chapter ID>, <Page ID>, <Page number>, <Page url/name>
my @pg_data = ( # Chp_id = 0
	[{ chp_id => 0, pg_id => 0, number => 1, name => '01', pic => '00.jpg' },
	 { chp_id => 0, pg_id => 1, number => 2, name => '02', pic => '01.jpg' },
	 { chp_id => 0, pg_id => 2, number => 3, name => '03', pic => '02.jpg' },
	 { chp_id => 0, pg_id => 3, number => 4, name => '04', pic => '03.jpg' }],
	# Chp_id = 1
	[{ chp_id => 1, pg_id => 4, number => 1, name => '05', pic => '04.jpg' },
	 { chp_id => 1, pg_id => 5, number => 2, name => '06', pic => '05-06.jpg' },
	 { chp_id => 1, pg_id => 6, number => 3, name => '07', pic => '07.jpg' },
	 { chp_id => 1, pg_id => 7, number => 4, name => '08', pic => '08.jpg' }],
	# Chp_id = 2
	[{ chp_id => 2, pg_id => 8, number => 1, name => '09', pic => '09.jpg' },
	 { chp_id => 2, pg_id => 9, number => 2, name => '10', pic => '10.jpg' },
	 { chp_id => 2, pg_id => 10, number => 3, name => '11', pic => '99.jpg' },
	 { chp_id => 2, pg_id => 11, number => 4, name => '12', pic => '99.jpg' }],
	# Chp_id = 3
	[{ chp_id => 3, pg_id => 12, number => 1, name => '13', pic => '99.jpg' },
	 { chp_id => 3, pg_id => 13, number => 2, name => '14', pic => '99.jpg' },
	 { chp_id => 3, pg_id => 14, number => 3, name => '15', pic => '99.jpg' },
	 { chp_id => 3, pg_id => 15, number => 4, name => '16', pic => '99.jpg' }],
	# Chp_id = 4
	[{ chp_id => 4, pg_id => 16, number => 1, name => '17', pic => '99.jpg' },
	 { chp_id => 4, pg_id => 17, number => 2, name => '18', pic => '99.jpg' },
	 { chp_id => 4, pg_id => 18, number => 3, name => '19', pic => '99.jpg' },
	 { chp_id => 4, pg_id => 19, number => 4, name => '20', pic => '99.jpg' }],
	# Chp_id = 5
	[{ chp_id => 5, pg_id => 20, number => 1, name => '21', pic => '99.jpg' },
	 { chp_id => 5, pg_id => 21, number => 2, name => '22', pic => '99.jpg' },
	 { chp_id => 5, pg_id => 22, number => 3, name => '23', pic => '99.jpg' },
	 { chp_id => 5, pg_id => 23, number => 4, name => '24', pic => '99.jpg' }],
	# Chp_id = 6
	[{ chp_id => 6, pg_id => 24, number => 1, name => '25', pic => '99.jpg' },
	 { chp_id => 6, pg_id => 25, number => 2, name => '26', pic => '99.jpg' },
	 { chp_id => 6, pg_id => 26, number => 3, name => '27', pic => '99.jpg' },
	 { chp_id => 6, pg_id => 27, number => 4, name => '28', pic => '99.jpg' }],
	# Chp_id = 7
	[{ chp_id => 7, pg_id => 28, number => 1, name => '29', pic => '99.jpg' },
	 { chp_id => 7, pg_id => 29, number => 2, name => '30', pic => '99.jpg' },
	 { chp_id => 7, pg_id => 30, number => 3, name => '31', pic => '99.jpg' },
	 { chp_id => 7, pg_id => 31, number => 4, name => '32', pic => '99.jpg' }]);

	

###############################################################################
# Constructor
###############################################################################
sub new {
    my ($class) = @_;

    my $self = {
	_chapter_model	=> undef,
	_page_model	=> undef,
	_cur_page_model	=> undef,
	_cur_page_pixbuf => undef
    };
    bless $self, $class;

    $self->_init();
    return $self;
}


###############################################################################
# Initalizer
###############################################################################
sub _init {
    my ($self) = @_;

    # <Chapter Table ID>, <Chapter Number>, <Chapter Name>, <Beginning Chapter Page id>
    my $return = Gtk2::ListStore->new('Glib::Int', 'Glib::Int', 'Glib::String', 'Glib::Int');

    # Filling the Model with data
    foreach (@chp_data) {
	my $iter = $return->append;
	$return->set($iter,
		COLUMN_CHAPTER_ID,	$_->{id},
		COLUMN_CHAPTER_NUMBER,  $_->{number},
		COLUMN_CHAPTER_NAME,	$_->{name},
		COLUMN_CHAPTER_PAGE_ID,	$_->{page}
	);
    }
    $self->{_chapter_model} = $return;
   

    # <Chapter ID>, <Page ID>, <Page number>, <Page url/name>
    my @return;
    foreach my $i (0 .. $#pg_data) {
	my $tmp = Gtk2::ListStore->new('Glib::Int', 'Glib::Int', 
	    'Glib::Int', 'Glib::String', 'Glib::String');
	
	foreach (@{$pg_data[$i]}) {
	    my $iter = $tmp->append;
	    $tmp->set($iter,
		    COLUMN_CHP_ID,	$_->{chp_id},
		    COLUMN_PAGE_ID,	$_->{pg_id},
		    COLUMN_PAGE_NUMBER,	$_->{number},
		    COLUMN_PAGE_NAME,	$_->{name},
		    COLUMN_PAGE_TMP_PIC,$_->{pic}
	    );
	}
	push (@return, $tmp);
    }
    
    $self->{_page_model} = \@return;
}

###############################################################################
# Return the Name of the Manga
###############################################################################
sub get_name {
    my ($self) = @_;

    return "Stub Manga";
}


###############################################################################
# Return a list of all of the chapters
###############################################################################
sub get_chapters {
    my ($self) = @_;

    return $self->{_chapter_model};
}


###############################################################################
# Return the chapters name column
###############################################################################
sub get_chapters_name_column {
    my ($self) = @_;
    return COLUMN_CHAPTER_NAME;
}


###############################################################################
# Return a list of the pages for an chapter
###############################################################################
sub get_pages {
    my ($self, $chapter_iter) = @_;
    
    my @pg_list = @{$self->{_page_model}};
    my $idx = $self->{_chapter_model}->get_value($chapter_iter, 
	    COLUMN_CHAPTER_ID);

    $self->{_cur_page_model} = $pg_list[$idx];

    return $pg_list[$idx];
}


###############################################################################
# Return the page name column
###############################################################################
sub get_pages_name_column {
    my ($self) = @_;
    return COLUMN_PAGE_NAME;
}


###############################################################################
# Return an PixBuf of the current page image
###############################################################################
sub load_page_pixbuf {
    my ($self, $page_iter) = @_;
    
    my $path = $self->{_cur_page_model}->get_value($page_iter, 
	    COLUMN_PAGE_TMP_PIC);
    
    $self->{_cur_page_pixbuf} = Gtk2::Gdk::Pixbuf->new_from_file("tmp-data/$path");
    return $self->{_cur_page_pixbuf};
}


###############################################################################
# Return the currently cached pixbuf, mainly for zooming functions
###############################################################################
sub cached_page_pixbuf {
    my ($self) = @_;
    return $self->{_cur_page_pixbuf};
}


###############################################################################
# Return the currently last "row" iter for the page model
###############################################################################
sub last_page_iter {
    my ($self, $chapter_iter) = @_;

    my $model = $self->get_pages($chapter_iter);
    my $tmp = $model->get_iter_first();

    while ($model->iter_next($tmp)) {$tmp = $model->iter_next($tmp);}

    return $tmp;
}


1;
__END__
