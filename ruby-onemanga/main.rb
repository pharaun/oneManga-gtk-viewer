#!/usr/bin/env ruby
# ruby-OneManga Viewer
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
require 'DummyManga'

dummy = DummyManga::MangaPages.new

builder = Gtk::Builder.new
builder.add_from_file('view/manga-view.glade')

forward = builder.get_object('forward_button')
back = builder.get_object('back_button')

pages = builder.get_object('pages_combobox')
chapter = builder.get_object('chapter_combobox')

image = builder.get_object('image')

# Connect the Signals
forward.signal_connect('clicked') do

	puts "-"
	puts dummy
	puts "-"

    if dummy.next_volume? & !dummy.next_chapter? & !dummy.next_page?
	puts "Next volume"
	dummy = dummy.next_volume


	puts "+"
	puts dummy
	puts "+"

	if dummy.next_page?
	    puts "Next page - volume"
	    puts
	    image.pixbuf = dummy.next_page # "First page" of a new volume
	end

    elsif dummy.next_chapter? & !dummy.next_page?
	puts "Next chapter"
	dummy = dummy.next_chapter
	
	puts "*"
	puts dummy
	puts "*"
	
	if dummy.next_page?
	    puts "Next page - chapter"
	    puts
	    image.pixbuf = dummy.next_page # "first page" of a new chapter
	end

    elsif dummy.next_page?
	puts "Next page"
	puts
	image.pixbuf = dummy.next_page

    else
	puts "catchall"
    end
end

window = builder.get_object('viewer_window')

window.show_all
Gtk.main


###############################################################################
#window = Gtk::Window.new
#button = Gtk::Button.new("Hello World")
#
#window.set_title("Hello Ruby")
##window.border_width(10)
#
## Connect the button to a callback.
#button.signal_connect('clicked') { puts "Hello Ruby" }
#
## Connect the signals 'delete_event' and 'destroy'
#window.signal_connect('delete_event') {
#	puts "delete_event received"
#	false
#}
#window.signal_connect('destroy') {
#	puts "destroy event received"
#	Gtk.main_quit
#}
#
#window.add button
#window.show_all
#Gtk.main
