require 'spec_helper'

describe Tag do

  before(:each) do
      Book.redis_tags_engine.flushdb
  end

  it "should initialize a new Tag instance" do
    @b = Book.new
    @t = Tag.new(@b, "koksi")
    @t.name.should == "koksi"
    @t.owner_class.should == "book"
    
    @t.count.should be_zero
  end

  it "should intersect more than 1 tag" do
    @book1 = Book.new
    @book2 = Book.new
#debugger
    @book1.tags_collection = "elad, deddy, erez"

    @book1.save
    @book2.tags_collection = "elad, deddy"
    @book2.save

    [@book1.id, @book2.id].should =~ Tag.tagged_with(Book, {:tags => ["elad", "deddy"]}).collect(&:to_i)
  end

  it "should intersect 1 tag" do
    @book1 = Book.new
    @book2 = Book.new

    @book1.tags_collection = "elad, deddy, erez"
    @book1.save
    @book2.tags_collection = "elad, deddy"
    @book2.save

    [@book1.id, @book2.id].should =~ Tag.tagged_with(Book, {:tags => ["elad"]}).collect(&:to_i)
  end

  it "should log autocomplete options for each tag" do
    @book = Book.new
    @book.tags_collection = "elad", "eli", "eliran hamelech shel ramle"
    @book.save
    Book.tagged_with_prefix("el").should =~ ["elad", "eli", "eliran hamelech shel ramle"]
    Book.tagged_with_prefix("ela").should =~ ["elad"]
    Book.tagged_with_prefix("eli").should =~ ["eli", "eliran hamelech shel ramle"]
  end
end
