require 'pathname'

class Documents
  
  # def self.documents_of dir: nil, root: nil
  #   Dir.no_dot_entries(dir).collect{|x| x }
  # end
  def self.documents_of dir: nil, root: nil
    return false if dir.nil?
    return false if root.nil?
    
    existend_documents = []
    Dir.no_dot_entries(dir).each do |entry|
      file = File.join(dir,entry)
      if Dir.exists?(file)
        existend_documents << documents_of(dir: file, root: dir) unless entry == 'figures' || entry == 'archive'
      elsif entry.end_with?('.json')
        dirs = dir.split('/')
        actual_dir = dirs[-(dirs.length-root.split('/').length)..-1] - ['claims']
        if actual_dir.empty?
          existend_documents << {file_name: entry, name: entry.split('.').first}
        else
          existend_documents << {dir: actual_dir, file_name: File.join(actual_dir,entry), name: entry.split('.').first}
        end
      end
    end
    
    existend_documents
  end
  
  attr_accessor :json_file, :structure, :out
  
  # FixMe 2014-04-03: !!! make secure !!!
  def initialize(path: '', name: 'foo')
    @json_file = '{}'
    @json_file = File.open(path) if File.exist?(path)

    @structure = MultiJson.load(File.open(path))
    @out = {name: name}.merge!(@structure)
  end
  
end