class Tag
  attr_accessor :name
  attr_reader :owner_class

  attr_reader :owner

  def initialize(owner, name)
    @owner_class = owner.class.to_s.downcase
    @name = name
    @owner = owner
  end

  def count
    engine.scard redis_key
  end

  # Add expiry maybe?
  def Tag.tagged_with(klass, options = {})
    key_array = []
    if options[:tags].to_a.size == 1
      if options[:random].to_i > 0
        klass.redis_tags_engine.srandmember "#{klass.to_s.downcase}:tagged_with:#{options[:tags].first.to_s.downcase.gsub(" ", '-')}", options[:random].to_i
      else
        klass.redis_tags_engine.smembers "#{klass.to_s.downcase}:tagged_with:#{options[:tags].first.to_s.downcase.gsub(" ", '-')}"
      end
    else
      options[:tags].to_a.each do |tag_name|
        key_array << "#{klass.to_s.downcase}:tagged_with:#{tag_name.downcase.gsub(" ", '-')}"
      end
      klass.redis_tags_engine.sinterstore "#{klass.to_s.downcase}:inter:#{options[:tags].sort.collect{ |tag_name| tag_name.downcase.gsub(" ", '-') }.join(":")}", *key_array
      if options[:random].to_i > 0
        klass.redis_tags_engine.srandmember "#{klass.to_s.downcase}:inter:#{options[:tags].sort.collect{ |tag_name| tag_name.downcase.gsub(" ", '-') }.join(":")}", options[:random].to_i
      else
        klass.redis_tags_engine.smembers "#{klass.to_s.downcase}:inter:#{options[:tags].sort.collect{ |tag_name| tag_name.downcase.gsub(" ", '-') }.join(":")}"
      end
    end
  end

  protected

  def engine
    self.owner.class.redis_tags_engine
  end

  def redis_key
    "#{self.owner_class}:tagged_with:#{self.name.downcase.gsub(" ", '-')}"
  end
end