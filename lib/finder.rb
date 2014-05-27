# author LeFnord
# email  pscholz.le@gmail.com
# date   2014-05-26

class Finder
  
  def self.documents_of dir: nil, root: App.file_dir
    # return [] if dir.nil? || dir.empty?
    existend = []
    
    case 
    when root && !dir
      dir = root
    when Dir.exist?(dir)
      dir = dir
    when root && dir
      dir = File.join(root,dir)
    end
    
    if Dir.exist?(dir)
      Dir.no_dot_entries(dir).each do |file|
        entry = File.join(dir,file)
        if File.directory?(entry)
          existend << documents_of(dir: entry)
        else
          file = entry.sub("#{App.file_dir}",'')
          file_dir = dir.sub("#{App.file_dir}",'')
          file_parts = file.split('.')
          existend << {dir: file_dir, file: file, name: file_parts.first } if file_parts.last == 'json'
        end
      end
    end
    
    existend.flatten
  end
  
  
end