require "redis_tags/version"
require "redis_tags/tag"
require "redis_tags/tag_list"

module RedisTags
  
  def self.included(base)
    base.class_eval do

      extend ClassMethods
      include InstanceMethods

      #after_save :update_tags_to_redis

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

    def tagged_with(options = {})
      Tag.tagged_with(self, options)
    end

    def tagged_with_prefix(partial_tag_name)
      Tag.starts_with?(self.redis_tags_engine, partial_tag_name)
    end
  end

  module InstanceMethods

    def tag_list
      if self.class.acts_as_taggable_on_steroids_legacy_mode?
        legacy_tag_list = super()
        tags_collection = legacy_tag_list
        legacy_tag_list
      else
        tags_collection
      end
    end

    def tags_collection
      @tag_list ||= RedisTags::TagList.new(self)
    end

    def tag_with(tag)
      tags_collection << tag
    end

    def tags_collection=(new_tag_list)
      tags_collection.delete_all
      @tag_list = RedisTags::TagList.new(self).append_multi(new_tag_list)
    end

    private

    # After save callback, confirms that redis is saved after object exists.
    def update_tags_to_redis
      tags_collection = @tag_list
    end
  end
end
