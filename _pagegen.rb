require "i18n"
I18n.available_locales = [:en]
class Page
  attr_reader :titulo, :data, :slug, :marca, :nivel, :data, :data

  @@instance_collector = []

  def initialize(tarjeta, marca, nivel)
    @data = tarjeta
    @titulo = [tarjeta['nombre'], marca['titulo'], nivel['titulo']].join(' ')
    @titulo_non_latin = I18n.transliterate(@titulo)
    @slug = to_slug(@titulo_non_latin)
    @marca = marca['titulo']
    @nivel = nivel['titulo']
    @nivel_identificador = nivel['identificador']

    writePage(@data, @slug, @marca, @nivel, @titulo, @nivel_identificador)

    @@instance_collector << self
  end

  def writePage(tarjeta, slug, marca, nivel, titulo, nivel_identificador)
    out_file = File.new("tarjetas/#{slug}.md", "w")
    out_file.puts(tarjeta.to_yaml)
    out_file.puts('layout: tarjeta')
    out_file.puts("marca: #{marca}")
    out_file.puts("nivel: #{nivel}")
    out_file.puts("titulo: #{titulo}")
    out_file.puts("nivel_identificador: #{nivel_identificador}")
    out_file.puts('---')
    out_file.close
 end

  def to_slug(string)
     ret = string.strip

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

  def self.all
    @@instance_collector
  end
end

require 'yaml'
@tarjetas_file = YAML.load_file('_data/contentful/spaces/tarjetas.yaml')
@tarjetas = @tarjetas_file['tarjetas']

@tarjetas.each do |tarjeta|
  tarjeta['marcas'].each do |marca|
    tarjeta['nivel'].each do |nivel|
      Page.new(tarjeta, marca, nivel)
    end
  end
end
