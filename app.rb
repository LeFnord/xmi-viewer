# frozen_string_literal: true

require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/contrib/all'

require 'haml'
require 'sass'
require 'coffee-script'
require 'awesome_print'
require 'pathname'
require 'fileutils'
require 'multi_json'

# require own files
Dir["lib/**/*.rb"].each {|f| require "./#{f}"}

class App < Sinatra::Base
  
  register Sinatra::Contrib
  #
  # Configuration
  #
  configure do
    set :root, __dir__
    
    set :server, :thin
    set :sessions, true
    set :lock, true
    
    set default_encoding: 'UTF-8'
    set :haml, { format: :html5 } 
    set :file_dir, Proc.new { File.join(settings.root,'public','files') }
    
  end
  
  configure :development do
    register Sinatra::Reloader
    Dir["lib/**/*.rb"].each {|f| also_reload "./#{f}" }
    set :logging, true
  end

  configure :production do
    set :haml, { ugly: true }
  end
  
  #
  # Helpers
  #
  # contribute helpers
  helpers Sinatra::Cookies
  # own helpers
  helpers Sinatra::Partials
  helpers Sinatra::LinkTo
  helpers Sinatra::UrlHandle
  
  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
    
    def is_to_old_browser?
      if request.user_agent.include?("MSIE") && !request.user_agent.include?("MSIE 11.0")
        return true
      else
        return false
      end
    end
    
    def img name
      "<img src='images/#{name}' alt='#{name}' />"
    end
    
  end
  
  # 
  # Filters
  # 
  # before do
  # end
  
  #
  # Routes
  #
  
  # get assets
  get '/javascripts/:name.js' do
    content_type 'text/javascript', :charset => 'utf-8'
    coffee :"../assets/javascripts/#{params[:name]}"
  end
  
  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss :"../assets/stylesheets/#{params[:name]}"
  end
  
  # routes to pages
  not_found do
    redirect '/404.html'
  end
  
  get '/landing' do
    haml :landing, :layout => :layout_landing
  end
  
  get "/" do
    @path = "set path: #{settings.file_dir}"
    @documents = Finder.documents_of
    
    haml :index
  end
  
  # get a single file for visualization
  get %r{/?((?<path>[\w\-\_/]*)/)(?<name>[\w\-\_]+).json} do
    if params[:path].empty? || params[:path] == 'claims'
      doc_path = params[:name]  + '.json'
    else params[:path] != '/'
      doc_path = params[:path] + '/' + params[:name]  + '.json'
    end
    
    doc_path = File.join(File.join(settings.file_dir,doc_path))
    @document = Documents.new path: doc_path, name: params[:name]
    
    if request.xhr?
      json @document.out
    else
      redirect '/'
    end
  end
  
  # reload file list, from specified folder (=collection)
  get %r{/?((?<collection>[\w\-\_/]*))} do
    @documents = Finder.documents_of dir: params[:collection]
    
    if request.xhr?
      haml(:'partials/_docs', layout: false)
    else
      redirect '/'
    end
  end
  
  # file uploading (multiple allowed)
  post '/upload' do
    Documents.create_collection collection: params[:collection], files: params[:uploads] unless params[:collection].nil?
    
    redirect '/'
  end
  
  delete '/collection' do
    Documents.delete_collection collection: params[:collection]
    
    @documents = Finder.documents_of
    if request.xhr?
      haml(:'partials/_docs', layout: false)
    else
      redirect '/'
    end
  end
  
  run! if app_file == $0
end
