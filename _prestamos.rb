require 'rubygems'
require 'nokogiri'
require 'open-uri'
require "i18n"
I18n.available_locales = [:en]

class Prestamo
  attr_accessor :title, :slug, :description, :link, :form, :benefits, :conditions, :requirements
  @@instance_collector = []
  def initialize(title, description, link, form, benefits, conditions, requirements)
    @title = title
    @slug = to_slug(title)
    @description = description
    @link = link
    @form = form
    @benefits = benefits
    @conditions = conditions
    @requirements = requirements
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
      ret.gsub! /_+/,"-"

      #strip off leading/trailing underscore
      ret.gsub! /\A[_\.]+|[_\.]+\z/,""

      ret.downcase
  end
  def writePage(prestamo)
   out_file = File.new("_prestamos/#{prestamo.slug}.md", "w")
   out_file.puts(prestamo.to_yaml.gsub(" !ruby/object:Prestamo", ''))
   out_file.puts('---')
   out_file.puts(prestamo.description)
   out_file.close
  end
  def print
    puts self.slug
  end
end

doc = Nokogiri::HTML(open("https://www.baccredomatic.com/es-cr/prestamos/personales"))
doc.css('.product-card-content').each do |item|

  @title = item.css('.card-header h2').text.capitalize
  @description = item.css('.product-card-desktop').inner_html
  @link = "https://www.baccredomatic.com#{item.css('a.action-button-details').first.attr('href')}"
  if item.css('a.account-button').any?
    @form = "https://www.baccredomatic.com#{item.css('a.account-button').first.attr('href')}"
  end

  info = Nokogiri::HTML(open(@link))

  @benefits =[]
  info.css('.info-block-product-desktop h2').each do |benefit|
    @benefits << benefit.text.gsub( /\r\n/m, "\n" )
  end

  @conditions = []
  info.css('.conditions-inner-grid-2 li').each_with_index do |condition, index|
    if index.even? or index == 0
      @conditions[index] = "<strong>#{condition.css('h3').text}</strong>"
    else
      if condition.css('.field-2').any?
        @texts = []
        condition.css('.field-2').each do |c|
          @texts << c.text
        end
        @conditions[index - 1] =  "#{@conditions[index - 1]} #{@texts.join(', ')}"
      else
        @conditions[index - 1] =  "#{@conditions[index - 1]} #{condition.css('.field-1').text}"
      end
    end
  end

  @requirements = []
  info.css('.requirements li').each do |requirement|
    @requirements << requirement.text
  end

  @item = Prestamo.new(@title, @description, @link, @form, @benefits, @conditions.compact!, @requirements)

end
