module RedisTags
  class RedisTagList < Array

    attr_reader :owner, :owner_class, :owner_id, :tags
    
    def initialize(owner, tags = nil)
      @owner = owner
      @owner_class = owner.class.to_s.downcase
      @owner_id = owner.id
      if tags.nil? && !(owner.id.nil?)
        super(engine.smembers(self.redis_key))
      else
        if tags.nil?
          tags = []
        end
        append_multi(tags)
      end
    end

    def <<(tag_name)
      tag_name = tag_name.downcase.strip
      if !(self.owner_id.nil?)
        engine.multi do
          engine.sadd self.redis_key, tag_name
          engine.zadd "#{self.owner_class}:tagged_with:#{tag_name.gsub(" ", '-')}", @owner.created_at.to_i.to_s, self.owner_id
        end
        engine.multi do
          RedisTags::RedisTag.register_tag_for_autocomplete(engine, tag_name)
        end
      end
      super(tag_name)
    end

    def delete(tag_name)
      tag_name = tag_name.downcase.strip
      if !(self.owner_id.nil?)
        engine.multi do
          engine.srem self.redis_key, tag_name
          engine.zrem "#{self.owner_class}:tagged_with:#{tag_name.gsub(" ", '-')}", self.owner_id
        end
      end
      super(tag_name)
    end

    def delete_all
      if !(self.owner_id.nil?)
        engine.multi do
          engine.del self.redis_key
          self.each do |tag_name|
            engine.srem "#{self.owner_class}:tagged_with:#{tag_name.gsub(" ", '-')}", self.owner_id
          end
        end
      end
      self.each do |tag_name|
        self.delete(tag_name)
      end
      self
    end

    def append_multi(tags)
      if tags.is_a?(String)
        tags = tags.split(",").collect {|tag| tag.strip.downcase}
      end
      tags.each do |tag|
        self << tag
      end
      self
    end

    def save
      my_tags = self.dup
      delete_all
      self.append_multi(my_tags)
    end

    def engine
      self.owner.class.redis_tags_engine
    end

    def redis_key
      "#{self.owner_class}:#{self.owner_id}:tag_list"
    end
  end
end