# author: LeFnord
# email:  pscholz.le@gmail.com
# date:   2013-05-18

# extending Dir class with an #entries method, which don't return dot files

class Dir
  def self.no_dot_entries(dir)
    Dir.entries(dir).select {|file| file =~ /^\w/ }
  end
end