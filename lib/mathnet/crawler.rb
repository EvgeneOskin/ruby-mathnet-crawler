# coding: utf-8
require 'mathnet/crawler/version'
require 'net/http'
require 'nokogiri'

module Mathnet # :nodoc:
  module Crawler # :nodoc:
    module Entry
      CSS_FILTER = 'a.SLink'

      def list(parent)
        client = HTTPClient.new
        document = client.get_document parent.children_url
        links = document.css(CSS_FILTER).select do |tag|
          @detail_url_reqexp.match tag['href']
        end
        links.collect do |tag|
          new parent, tag
        end
      end
    end

    class HTTPClient
      def initialize(host: 'www.mathnet.ru')
        @base_uri = URI('http://' + host)
      end

      def get_document(url)
        response = get url
        Nokogiri::HTML(response.body)
      end

      def get(path, follow: true)
        response = Net::HTTP.get_response(uri path)
        if follow
          follow_redirect response
        else
          response
        end
      end

      def follow_redirect(response, redirected_count: 10)
        fail ArgumentError, 'too many HTTP redirects' if redirected_count == 0

        case response
        when Net::HTTPSuccess then
          response
        when Net::HTTPRedirection then
          new_response = get response['location'], follow: false
          follow_redirect new_response, redirected_count: redirected_count - 1
        else
          response.value
        end
      end

      def uri(path)
        URI.join @base_uri, path
      end
    end

    class Library
      def children_url
        '/ej.phtml'
      end
    end

    class Journal
      @detail_url_reqexp = %r{/php/journal.phtml}

      extend Entry
      attr_reader :detail_url, :title

      def initialize(parent, tag)
        @parent = parent
        @title = tag['title']
        @detail_url = tag['href']
        detail_query = URI(@detail_url).query
        @archive_url = "/php/archive.phtml?wshow=contents&#{detail_query}"
      end

      def children_url
        @archive_url
      end
    end

    class Issue
      @detail_url_reqexp = %r{/php/archive.phtml?.*wshow=issue}

      extend Entry
      attr_reader :detail_url, :title

      def initialize(parent, tag)
        @parent = parent
        @title = tag['title']
        @detail_url = tag['href']
      end

      def children_url
        @detail_url
      end

      def journal_title
        @parent.title
      end
    end

    class Article
      @detail_url_reqexp = %r{/rus/}

      extend Entry
      attr_reader :detail_url, :title

      def initialize(parent, tag)
        @parent = parent
        @title = tag.text
        @detail_url = tag['href']
        @pdf_url_reqexp = %r{/php/getFT.phtml}
      end

      def children_url
        @detail_url
      end

      def full_text_url
        client = HTTPClient.new
        document = client.get_document @detail_url
        links = document.css(Entry::CSS_FILTER).select do |tag|
          @pdf_url_reqexp.match tag['href']
        end
        fail ArgumentError, 'there is no full text link.' if links.empty?
        links.first['href']
      end

      def full_text(&block)
        client = HTTPClient.new
        payload = client.get full_text_url
        if payload['Content-Type'] != 'text/html'
          block.call payload.body
        end
      end

      def journal_title
        @parent.journal_title
      end 
    end
  end
end
