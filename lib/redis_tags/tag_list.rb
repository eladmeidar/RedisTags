module RedisTags
  class TagList < Array

    attr_reader :owner, :owner_class, :owner_id, :tags
    
    def initialize(owner)

      @owner = owner
      @owner_class = owner.class.to_s.downcase
      @owner_id = owner.id
      @tags = engine.smembers(self.redis_key)
      super(engine.smembers(self.redis_key))
    end

    def <<(tag_name)
      tag_name = tag_name.downcase.strip
      engine.multi do
        tag_name = tag_name.downcase.strip
        engine.sadd self.redis_key, tag_name
        engine.sadd "#{self.owner_class}:tagged_with:#{tag_name.gsub(" ", '-')}", self.owner_id
      end
      super(tag_name)
    end

    def delete(tag_name)
       engine.multi do
        tag_name = tag_name.downcase.strip
        engine.srem self.redis_key, tag_name
        engine.srem "#{self.owner_class}:tagged_with:#{tag_name.gsub(" ", '-')}", self.owner_id
      end
      super(tag_name)
    end

    def append_mutli(tags)
      if tags.is_a?(String)
        tags = tags.split(",").collect {|tag| tag.strip.downcase}
      end
      engine.multi do
        tags.each do |tag_name|
          tag_name = tag_name.downcase.strip
          engine.sadd self.redis_key, tag_name
          engine.sadd "#{self.owner_class}:tagged_with:#{tag_name.gsub(" ", '-')}", self.owner_id
        end
      end
      self + tags
    end

    def engine
      self.owner.class.redis_tags_engine
    end

    def redis_key
      "#{self.owner_class}:#{self.owner_id}:tag_list"
    end
  end
end