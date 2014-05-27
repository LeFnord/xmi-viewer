require 'spec_helper'

describe Finder do
  
  context "directory content" do
    
    context "empty or nil input" do
      it { expect(Finder.documents_of).not_to be_empty }
      it { expect(Finder.documents_of dir: '').not_to be_empty }
    end
    
    context "dir given" do
      
      # absolute path
      context "exist" do
        it { expect(Finder.documents_of dir: File.join('spec','claims','brat') ).not_to be_empty }
        it { expect(Finder.documents_of dir: File.join('spec','claims','brat') ).to be_a Array }
        it { expect(Finder.documents_of(dir: File.join('spec','claims','brat')).first ).to be_a Hash }
        it { expect(Finder.documents_of(dir: File.join('spec','claims','brat')).first ).to include(:file,:name) }
        it { expect(Finder.documents_of dir: File.join('spec','claims','brat') ).to have(1).item }
      end
      
      context "not exist" do
        it { expect(Finder.documents_of dir: File.join('spec','claims','br') ).to be_empty }
        it { expect(Finder.documents_of dir: File.join('spec','claims','br') ).to have(0).item }
      end
      
      context "include dir" do
        it { expect(Finder.documents_of dir: File.join('spec','claims') ).not_to be_empty }
        it { expect(Finder.documents_of dir: File.join('spec','claims') ).to have(2).item }
      end
      
    end
    
    # paths relative to root → needed, when root is user input
    context "root given" do
      
      context "exist" do
        it { expect(Finder.documents_of dir: File.join('spec','claims','brat'), root: App.root ).not_to be_empty }
        it { expect(Finder.documents_of dir: File.join('spec','claims','brat'), root: App.root ).to have(1).item }
        it { expect(Finder.documents_of dir: File.join('spec','claims'), root: App.root ).not_to be_empty }
        it { expect(Finder.documents_of dir: File.join('spec','claims'), root: App.root ).to have(2).item }
        it { expect(Finder.documents_of dir: File.join('brat'), root: App.file_dir ).not_to be_empty }
      end
      
      context "no dir given" do
        it { expect(Finder.documents_of root: App.file_dir ).not_to be_empty }
      end
      
      context "not exist" do
        it { expect(Finder.documents_of dir: File.join('spec','claims','br'), root: App.root ).to be_empty }
        it { expect(Finder.documents_of dir: File.join('spec','claims','br'), root: App.root ).to have(0).item }
      end
      
    end
    
  end
  
end