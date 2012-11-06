require "redis_tags/version"
require "redis_tags/redis_tag"
require "redis_tags/redis_tag_list"

module RedisTags
  
  def self.included(base)
    base.class_eval do

      extend ClassMethods
      include InstanceMethods

      after_save :update_tags_to_redis

      @@redis_tags_engine = nil
      @@acts_as_taggable_on_steroids_legacy = false
    end
  end

  module ClassMethods

    def uses_redis_tags(options = {})
      options = {:engine => Redis.new, :acts_as_taggable_on_steroids_legacy_mode => false}.merge!(options)
      @@redis_tags_engine = options[:engine]
      @@acts_as_taggable_on_steroids_legacy = options[:acts_as_taggable_on_steroids_legacy_mode]
    end

    def redis_tags_engine=(redis_instance)
      @@redis_tags_engine = redis_instance
    end

    def acts_as_taggable_on_steroids_legacy_mode?
      @@acts_as_taggable_on_steroids_legacy == true
    end

    def redis_tags_engine
      @@redis_tags_engine
    end

    def has_tags(options = {})
      RedisTags::RedisTag.has_tags(self, options)
    end

    def tags_starting_with(partial_tag_name)
      RedisTags::RedisTag.starts_with?(self.redis_tags_engine, partial_tag_name)
    end
  end

  module InstanceMethods

    def tags_collection
      if self.class.acts_as_taggable_on_steroids_legacy_mode?
        @_tag_list ||= RedisTags::RedisTagList.new(self, self.tag_list) 
      else
        @_tag_list ||= RedisTags::RedisTagList.new(self)
      end
    end

    def tag_with(tag)
      tags_collection << tag
    end

    def tags_collection=(new_tag_list)
      tags_collection.delete_all
      @_tag_list = RedisTags::RedisTagList.new(self, new_tag_list)
    end

    private

    # After save callback, confirms that redis is saved after object exists.
    def update_tags_to_redis
      tags_collection = RedisTags::RedisTagList.new(self, @_tag_list)
    end
  end
end
