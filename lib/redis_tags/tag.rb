class Tag
  attr_accessor :name
  attr_reader :owner_class

  attr_reader :owner

  def initialize(owner, name)
    @owner_class = owner.class.to_s.downcase
    @name = name.downcase.strip
    @owner = owner
  end

  def Tag.starts_with?(use_engine, partial_tag_name)
    use_engine.smembers "tags:all:#{partial_tag_name}"
  end

  def Tag.register_tag_for_autocomplete(use_engine, tag_name)
    partial_tag_name = ""
    tag_name.each_char do |char|
      partial_tag_name += char
      use_engine.sadd "tags:all:#{partial_tag_name}", tag_name
    end
  end

  def count
    engine.scard redis_key
  end

  def Tag.tagged_with(klass, options = {})
#debugger
    key_array = []
    if options[:tags].to_a.size == 1
      if options[:random].to_i > 0
        klass.redis_tags_engine.srandmember Tag.tagged_with_key_for(klass, options[:tags]), options[:random].to_i
      else
        klass.redis_tags_engine.smembers Tag.tagged_with_key_for(klass, options[:tags])
      end
    else
      options[:tags].to_a.each do |tag_name|
        key_array << Tag.tagged_with_key_for(klass, tag_name)
      end
      klass.redis_tags_engine.sinterstore Tag.intersect_key_for(klass, options[:tags]), *key_array
      if options[:random].to_i > 0
        klass.redis_tags_engine.srandmember Tag.intersect_key_for(klass, options[:tags]), options[:random].to_i
      else
        klass.redis_tags_engine.smembers Tag.intersect_key_for(klass, options[:tags])
      end
    end
  end

  protected

  def Tag.intersect_key_for(klass, tags)
    "#{klass.to_s.downcase}:inter:#{tags.sort.collect{ |tag_name| tag_name.downcase.strip.gsub(" ", '-') }.join(":")}"
  end

  def Tag.tagged_with_key_for(klass, tag_name)
    "#{klass.to_s.downcase}:tagged_with:#{tag_name.to_s.downcase.strip.gsub(" ", '-')}"
  end

  def engine
    self.owner.class.redis_tags_engine
  end

  def redis_key
    "#{self.owner_class}:tagged_with:#{self.name.downcase.gsub(" ", '-')}"
  end
end