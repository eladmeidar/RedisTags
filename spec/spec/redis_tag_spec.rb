require 'spec_helper'

describe RedisTags::RedisTag do

  before(:each) do
      Book.redis_tags_engine.flushdb
  end

  it "should initialize a new RedisTag instance" do
    @b = Book.new
    @t = RedisTags::RedisTag.new(@b, "koksi")
    @t.name.should == "koksi"
    @t.owner_class.should == "book"
    
    @t.count.should be_zero
  end

  it "should intersect more than 1 tag" do
    @book1 = Book.new
    @book2 = Book.new
    @book1.tags_collection = "elad, deddy, erez"
    @book1.save

    @book2.tags_collection = "elad, deddy"
    @book2.save

    [@book1.id, @book2.id].should =~ RedisTags::RedisTag.has_tags(Book, {:tags => ["elad", "deddy"]}).collect(&:to_i)
  end

  it "should intersect 1 tag" do
    @book1 = Book.new
    @book2 = Book.new

    @book1.tags_collection = "elad, deddy, erez"
    @book1.save
    @book2.tags_collection = "elad, deddy"
    @book2.save

    [@book1.id, @book2.id].should =~ RedisTags::RedisTag.has_tags(Book, {:tags => ["elad"]}).collect(&:to_i)
  end

  it "should log autocomplete options for each tag" do
    @book = Book.new
    @book.tags_collection = "elad", "eli", "eliran hamelech shel ramle"
    @book.save
    Book.tags_starting_with("el").should =~ ["elad", "eli", "eliran hamelech shel ramle"]
    Book.tags_starting_with("ela").should =~ ["elad"]
    Book.tags_starting_with("eli").should =~ ["eli", "eliran hamelech shel ramle"]
  end
end
