require 'fandango/movie'
require 'fandango/theater'

module Fandango
  class Parser

    class << self

      def parse(source)
        parser = new(source)
        parser.parse
      end

      def parse_times(source)
        parser = new(source)
        parser.parse_times
      end

      # Description content is wrapped in CDATA.
      # Parse it and return a parsed Nokogiri node.
      def parse_description(item_node)
        cdata = item_node.at_css('description')
        Nokogiri::HTML(cdata.content)
      end

    end

    def initialize(source)
      @source = source
    end

    def parse
      @doc = Nokogiri.XML(@source)
      @doc.css('item').map do |item_node|
        hash = {}
        description_node = self.class.parse_description(item_node)
        hash[:theater] = Theater.parse(item_node, description_node)
        hash[:movies] = Movie.parse(description_node)
        hash
      end
    end

    def parse_times
      @doc = Nokogiri.HTML(@source)
      @doc.css("a[class=showtime_itr]").map do |times_node|
        hash = {}
        ticket_url = times_node["href"]
        hash[:ticket_url] = ticket_url
        hash[:time] = times_node.css("span[class=showtime_pop]").text
        hash[:movie_id] = ticket_url.match(%r{([&?]|%3f|%26)mid=(?<id>\d+)})[:id]
        hash[:row_count] = ticket_url.match(%r{([&?]|%3f|%26)row_count=(?<id>\d+)})[:id]
        hash
      end
    end

  end
end
