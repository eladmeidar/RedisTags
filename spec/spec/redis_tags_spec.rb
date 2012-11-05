require 'spec_helper'

describe RedisTags do
  describe "#tags_list" do
    it "should return a empty array for a new object" do
      Book.new.tags_collection.should eql([])
    end

    it "should create multiple tags" do
      @book = Book.new
      @book.tags_collection = "elad, koko, loko"
      @book.save
      @book.tags_collection.should  eql(["elad", "koko", "loko"])
    end

    it "should save a new tag using <<" do
      @book = Book.new
      @book.tag_with "elad"
      @book.save
      @book.tags_collection.should eql(["elad"])
    end

    it "should save a new tag downcased" do
      @book = Book.new
      @book.tag_with "ELAD"
      @book.save
      @book.tags_collection.should eql(["elad"])
    end

    it "should support backward compatibility for acts_as_taggable_on_steroids (#tag_list)" do
      Book.class_eval do
        uses_redis_tags :acts_as_taggable_on_steroids_legacy_mode => true
      end

      @book = Book.new
      lambda {
        @book.tag_list
      }.should_not raise_error(NoMethodError)
    end

    it "should update Redis tags collection with backward compatibility for acts_as_taggable_on_steroids (#tag_list)" do
      Book.class_eval do
        uses_redis_tags :acts_as_taggable_on_steroids_legacy_mode => true
      end

      @book = Book.new([])

      @book.tags_collection.should eql([])
    end
  end
end