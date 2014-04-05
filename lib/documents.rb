require 'pathname'

class Documents
  
  def self.content_of dir: nil, root: nil
    Dir.no_dot_entries(dir).collect{|x| x }
  end
  
  attr_accessor :json_file, :structure, :out
  
  # FixMe 2014-04-03: !!! make secure !!!
  def initialize(path: '', name: 'foo')
    @json_file = '{}'
    @json_file = File.open(path) if File.exist?(path)

    @structure = MultiJson.load(@json_file)
    @out = {name: name}.merge(@structure)
  end
  
end