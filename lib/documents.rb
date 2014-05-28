class Documents
  
  def self.create_collection collection: nil, files: nil
    new_dir = File.join(App.file_dir,collection)
    dir = FileUtils.mkdir_p(new_dir).last unless Dir.exists?(new_dir)
    dir = dir || new_dir
    
    if files
      files.each do |file|
        filename = file[:filename]
        tmpfile = file[:tempfile]
        target = "#{dir}/#{filename}"
        File.open(target, 'wb') {|f| f.write tmpfile.read }
      end
    end
    
  end
  
  def self.delete_collection collection: nil
    to_delete = File.join(App.file_dir,collection)
    FileUtils.remove_dir to_delete
  end
  
  # instance
  attr_accessor :json_file, :structure, :out
  
  # FixMe 2014-04-03: !!! make secure !!!
  def initialize(path: '', name: 'foo')
    @json_file = '{}'
    @json_file = File.open(path) if File.exist?(path)
    
    @structure = MultiJson.load(File.open(path))
    @out = {name: name}.merge!(@structure)
  end
  
end