require "redis_tags/version"
require "redis_tags/tag"
require "redis_tags/tag_list"

module RedisTags
  
  def self.included(base)
    base.class_eval do

      extend ClassMethods
      include InstanceMethods

      @@redis_tags_engine = nil
    end
  end

  module ClassMethods

    def uses_redis_tags(options = {})
      @@redis_tags_engine = options[:engine] || Redis.new
    end

    def redis_tags_engine=(redis_instance)
      @@redis_tags_engine = redis_instance
    end

    def redis_tags_engine
      @@redis_tags_engine
    end

    def tagged_with(options = {})
      Tag.tagged_with(self, options)
    end
  end

  module InstanceMethods

    def tag_list
      @tag_list ||= RedisTags::TagList.new(self)
    end

    def tag_with(tag)
      tag_list << tag
    end

    def tag_list=(new_tag_list)
      @tag_list = RedisTags::TagList.new(self).append_mutli(new_tag_list)
    end
    
  end
end
