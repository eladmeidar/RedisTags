require 'spec_helper'

describe RedisTags do
  describe "#tags_list" do
    it "should return a empty array for a new object" do
      Book.new.tag_list.should eql([])
    end

    it "should create multiple tags" do
      @book = Book.new
      @book.tag_list = "elad, koko, loko"
      @book.tag_list.should =~ ["elad", "koko", "loko"]
    end

    it "should save a new tag using <<" do
      @book = Book.new
      @book.tag_with "elad"
      @book.tag_list.should eql(["elad"])
    end

    it "should save a new tag downcased" do
      @book = Book.new
      @book.tag_with "ELAD"
      @book.tag_list.should eql(["elad"])
    end

  end
end