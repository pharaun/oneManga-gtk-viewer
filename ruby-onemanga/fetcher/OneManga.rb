# Deals with populating the db with oneManga data
module Fetcher
    require 'SequelManga'

    # Cache
    require 'fetcher/http_fetch'

    # Html parser
    require 'nokogiri'

    class OneManga
	def initialize(cache_only)
	    @cache_only = cache_only
	    @site = SequelManga::Site[:site_name => "One Manga"]
	    if @site.nil?
		@site = SequelManga::Site.new
		@site.site_name = "One Manga"
		@site.fetcher = "OneManga.rb"
		@site.site_url = "http://www.onemanga.com"
		@site.save
	    end

	    @url = @site.site_url.to_s
	    @directory_url = "#{@url}/directory/"

	    @fetch = HTTP_fetch.new @cache_only
	end

	# Hash operation for storing a string into a "key"
	def populate
	    dir = Nokogiri::HTML(@fetch.fetch(@directory_url))
	    exclude = ['All', 'Top 50', 'New', 'Updated', 'Completed']

	    # Manga Category
	    dir.xpath('/html/body/div[2]/div[3]/div[2]/div[3]/div[2]/ul/li/a').each do |cat|
		if (exclude.index(cat.content)).nil?
		    # Not in exclude list
		    category = SequelManga::Category.new
		    category.category = cat.content

		    @site.add_category(category)
		end
	    end

	    # Manga Info
	    manga_url = []
	    dir.css('td.ch-subject a').each do |manga|
		url = manga.values
		next if (url.length > 1)

		url = url.to_s
		manga_url << url
	    end
	    manga_url.uniq!

	    # Process each site
	    manga_url.each do |url|
		puts url
		data = Nokogiri::HTML(@fetch.fetch(@url + url))

		manga_info = SequelManga::Info.new
		manga_info.save

		# Manga Titles
		titledata = data.xpath('/html/body/div[2]/div[3]/div/h1[1]/child::text()')
		title = SequelManga::Title.new
		title.title = titledata.to_s.squeeze(' ').strip.gsub(/ Manga$/, '')
		title.alternate = false
		manga_info.add_title(title)

		# Alt Titles
		alttitledata = data.xpath('/html/body/div[2]/div[3]/div/h1[1]/span').first
		if (not alttitledata.nil?)
		    alttitledata.content.split(',').each do |atitle|
			alttitle = SequelManga::Title.new
			alttitle.title = atitle.strip
			alttitle.alternate = true
			manga_info.add_title(alttitle)
		    end
		end

		data.xpath('/html/body/div[2]/div[3]/div/div/div/table/tr').each do |chunk|
		    type = chunk.xpath('th').first.content.strip
		    value = chunk.xpath('td').first.content.strip

		    case type
		    when 'OM Rank:'
			manga_info.site_ranking = value.strip.to_i
		    when 'Categories:'
			value.split(',').each do |cat|
			    category = SequelManga::Category[:category => cat.strip]
			    if category.nil?
				category = SequelManga::Category.new
				category.category = cat.strip
			    end
			    manga_info.add_category(category)
			end
		    when 'Author:'
			value.split(',').each do |auth|
			    author = SequelManga::Author[:name => auth.strip]
			    if author.nil?
				author = SequelManga::Author.new
				author.name = auth.strip
			    end
			    manga_info.add_author(author)
			end
		    when 'Artist:'
			value.split(',').each do |art|
			    artist = SequelManga::Artist[:name => art.strip]
			    if artist.nil?
				artist = SequelManga::Artist.new
				artist.name = art.strip
			    end
			    manga_info.add_artist(artist)
			end
		    when 'Start Date:'
			manga_info.release_year = Time.utc(value.strip.to_i)
		    when 'Chapters:'
			if (value.strip) =~ /\d* - (.*) - (.*)/
			    manga_info.state = $1.to_sym
			    manga_info.schedule = $2.to_sym
			elsif (value.strip) =~ /\d* - (.*)/
			    manga_info.state = $1.to_sym
			end
		    end
		end

		# Deal with the Summary
		summary = []
		sum = data.xpath('/html/body/div[2]/div[3]/div/div/div[2]/p/child::text()').each do |p|
		    summary << p.to_s.squeeze(' ').strip
		end
		if (summary.length > 0)
		    manga_info.summary = summary.join("\n")
		else
		    manga_info.summary = nil
		end

		# Deal with the Cover page url for fetching the image latter
		img = data.xpath('/html/body/div[2]/div[3]/div/div/div/img').first['src']
		manga_info.cover_page_url = img

		manga_info.save
		@site.add_info(manga_info)

		if (not @cache_only)
		    sleep 1
		end
	    end
	    @site.save
	end

	def get_image(url)
	    # Return the image filename
	    @fetch.fetch_image(url)
	end
    end
end
