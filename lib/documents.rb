require 'pathname'

class Documents
  
  attr_accessor :json_file, :structure, :out
  
  # FixMe 2014-04-03: !!! make secure !!!
  def initialize(path: '', name: 'foo')
    @json_file = '{}'
    @json_file = File.open(path) if File.exist?(path)
    
    @structure = MultiJson.load(File.open(path))
    @out = {name: name}.merge!(@structure)
  end
  
  def self.store_files collection: nil, files: nil
    ap collection
    ap files
  end
  
end