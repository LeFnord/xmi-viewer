require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/contrib/all'

require 'haml'
require 'sass'
require 'coffee-script'
require 'awesome_print'
require 'pathname'
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
  not_found do
    redirect '/404.html'
  end
  
  get '/javascripts/:name.js' do
    content_type 'text/javascript', :charset => 'utf-8'
    coffee :"../assets/javascripts/#{params[:name]}"
  end
  
  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss :"../assets/stylesheets/#{params[:name]}"
  end
  
  get '/landing' do
    haml :landing, :layout => :layout_landing
  end
  
  get "/" do
    @path = "set path: #{settings.file_dir}"
    @documents = Finder.documents_of
    
    haml :index
  end
    
  get %r{/?((?<path>[\w\-\_]*)/)(?<name>[\w\-\_]+).json} do
    ap "bar"
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
  
  get %r{/?((?<coll>[\w\-\_]*))} do
    ap "foo"
    @documents = Finder.documents_of dir: params[:coll]
    
    if request.xhr?
      haml(:'partials/_docs', layout: false)
    else
      redirect '/'
    end
  end
  
  
  # get "/path" do
  #   $stdout.puts "in dir: #{params[:q]}".red
  #   input = params[:q].split('/')
  #   path = input[0..-2].join('/')
  #   path = '/' if path.empty?
  #   dir = input.last
  #   
  #   
  #   
  #   # if Dir.exist?(path)
  #   #   $stdout.print "path: #{path}\n".blue
  #   #   $stdout.print "dir: #{dir}\n".blue
  #   #   @entries = Dir.no_dot_entries(path)
  #   #   foo = []
  #   #   @entries.each{ |x| foo << x if x.start_with?(dir) }
  #   #   @entries = foo unless foo.empty?
  #   # end
  #   # ap @entries
  #   # json @entries
  # end
  
  # get '/dir' do
  #   $stdout.puts "in dir: #{params[:q]}".red
  #   true
  # end
  
  post '/upload' do
    Documents.store_files collection: params[:collection], files: params[:files]
    
    redirect '/'
  end
  
  run! if app_file == $0
end
