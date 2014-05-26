# author LeFnord
# email  pscholz.le@gmail.com
# date   2014-05-26

class Finder
  
  def self.documents_of dir: nil, root: App.root
    return [] if dir.nil? || dir.empty?
    existend = []
    
    case 
    when Dir.exist?(dir)
      dir = dir
    when root && dir
      File.join(root,dir)
    when root && !dir
      dir = root
    end
    
    if Dir.exist?(dir)
      Dir.no_dot_entries(dir).each do |file|
        entry = File.join(dir,file)
        if File.directory?(entry)
          existend << documents_of(dir: entry)
        else
          file_parts = file.split('.')
          existend << {dir: dir.sub("#{App.root}",''), file: entry, name: file_parts.first } if file_parts.last == 'json'
        end
      end
    end
    
    existend.flatten
  end
  
end