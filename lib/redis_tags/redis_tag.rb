module RedisTags
  class RedisTag
    attr_accessor :name
    attr_reader :owner_class

    attr_reader :owner

    def initialize(owner, name)
      @owner_class = owner.class.to_s.downcase
      @name = name.downcase.strip
      @owner = owner
    end

    def self.starts_with?(use_engine, partial_tag_name)
      use_engine.smembers "tags:all:#{partial_tag_name}"
    end

    def self.register_tag_for_autocomplete(use_engine, tag_name)
      partial_tag_name = ""
      tag_name.each_char do |char|
        partial_tag_name += char
        use_engine.sadd "tags:all:#{partial_tag_name}", tag_name
      end
    end

    def count
      engine.zcard redis_key
    end

    def self.has_tags(klass, options = {})
      key_array = []
      if options[:tags].to_a.size == 1
        if options[:random].to_i > 0
          klass.redis_tags_engine.zrandmember RedisTags::RedisTag.tagged_with_key_for(klass, options[:tags]), options[:random].to_i
        elsif options[:since]
          klass.redis_tags_engine.zrangebyscore RedisTags::RedisTag.tagged_with_key_for(klass, options[:tags]), options[:since].to_i, Time.now.to_i
        else
          klass.redis_tags_engine.zrangebyscore RedisTags::RedisTag.tagged_with_key_for(klass, options[:tags]), Time.now.to_i - 7 * 60 * 60 * 24, Time.now.to_i
        end
      else
        options[:tags].to_a.each do |tag_name|
          key_array << RedisTag.tagged_with_key_for(klass, tag_name)
        end

        klass.redis_tags_engine.zinterstore RedisTags::RedisTag.intersect_key_for(klass, options[:tags]), key_array, {:aggregate => :max}

        if options[:random].to_i > 0
          klass.redis_tags_engine.zrandmember RedisTags::RedisTag.intersect_key_for(klass, options[:tags]), options[:random].to_i
        elsif options[:since]
          klass.redis_tags_engine.zrangebyscore RedisTags::RedisTag.intersect_key_for(klass, options[:tags]), options[:since].to_i, Time.now.to_i
        else
          klass.redis_tags_engine.zrangebyscore RedisTags::RedisTag.intersect_key_for(klass, options[:tags]), (Time.now.to_i - 7 * 60 * 60 * 24), Time.now.to_i
        end
      end
    end

    protected

    def self.intersect_key_for(klass, tags)
      "#{klass.to_s.downcase}:inter:#{tags.sort.collect{ |tag_name| tag_name.downcase.strip.gsub(" ", '-') }.join(":")}"
    end

    def self.tagged_with_key_for(klass, tag_name)
      "#{klass.to_s.downcase}:tagged_with:#{tag_name.to_s.downcase.strip.gsub(" ", '-')}"
    end

    def engine
      self.owner.class.redis_tags_engine
    end

    def redis_key
      "#{self.owner_class}:tagged_with:#{self.name.downcase.gsub(" ", '-')}"
    end
  end
end