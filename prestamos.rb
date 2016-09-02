require 'rubygems'
require 'nokogiri'
require 'open-uri'
require "i18n"
I18n.available_locales = [:en]

class Prestamo
  attr_accessor :title, :slug
  @@instance_collector = []
  def initialize(title, description)
    @title = title
    @slug = to_slug(title)
    @description = description
    writePage(self)
    self.print
  end
  def to_slug(string)

    non_latin = I18n.transliterate(string)

     ret = non_latin.strip

     #blow away apostrophes
     ret.gsub! /['`]/,""

     # @ --> at, and & --> and
     ret.gsub! /\s*@\s*/, " at "
     ret.gsub! /\s*&\s*/, " and "

     #replace all non alphanumeric, underscore or periods with underscore
      ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'

      #convert double underscores to single
      ret.gsub! /_+/,"_"

      #strip off leading/trailing underscore
      ret.gsub! /\A[_\.]+|[_\.]+\z/,""

      ret.downcase
   end
  def writePage(prestamo)
   out_file = File.new("_prestamos/#{prestamo.slug}.md", "w")
   #out_file.puts(prestamo.to_yaml)
   out_file.puts('---')
   out_file.puts("title: #{prestamo.title}")
   out_file.puts('---')
   out_file.close
  end
  def print
    puts self.slug
  end
end

doc = Nokogiri::HTML(open("https://www.baccredomatic.com/es-cr/prestamos/personales"))
doc.css('.product-card-content').each do |item|

  @title = item.css('.card-header h2').text.capitalize
  @description = item.css('.product-card-desktop').text

  @item = Prestamo.new(@title, @description);

end
