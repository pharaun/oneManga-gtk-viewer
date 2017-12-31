#!/usr/bin/env ruby
# ruby-OneManga Viewer
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
#require 'DummyManga'
require 'SequelManga'
#require 'manga_viewer'
require 'manga_index'
require 'fetcher/OneManga'


test2 = SequelManga::SequelMangaConstructor.new false
#test2 = SequelManga::SequelMangaConstructor.new true
#test2.populate

#site2 = test2.getSite

#puts site2.to_s


#test3 = Fetcher::OneManga.new
#test3.populate
#site3 = test3.getSite
#puts site3.to_s

#DB = test2.getDb

#ds = DB[:titles]
#ds.filter(:alternate => true).group(:info_id).having('COUNT(info_id) > 1').each do |r|
#    info = SequelManga::Info[r[:info_id]]
#    puts info.title
#    puts "\t#{info.alt_titles.join(', ')}"
#end

#ds = DB[:infos]
#ds.select(:id).each do |r|
#    puts SequelManga::Info[r[:id]].cover_page_url
#end

#test = DummyManga::DummyMangaConstructor.new
#site = test.getSite
#puts test.to_s

#build_manga_viewer(site.mangas[0])

DB = test2.getDb
site = SequelManga::Site[1]
build_manga_index(site)
Gtk.main
