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

    @book1.tag_list = "elad, deddy, erez"
    @book2.tag_list = "elad, deddy"

    [@book1.id, @book2.id].should =~ Tag.tagged_with(Book, {:tags => ["elad", "deddy"]}).collect(&:to_i)
  end

  it "should intersect 1 tag" do
    @book1 = Book.new
    @book2 = Book.new

    @book1.tag_list = "elad, deddy, erez"
    @book2.tag_list = "elad, deddy"

    [@book1.id, @book2.id].should =~ Tag.tagged_with(Book, {:tags => ["elad"]}).collect(&:to_i)
  end
end
