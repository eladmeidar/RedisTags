class Book

  attr_accessor :id
  attr_reader :created_at
  attr_accessor :tag_list
  def Book.after_save(arg)
    
  end

  include RedisTags

  uses_redis_tags

  def initialize(tag_list = [])
    @id = nil
    @created_at = Time.now
    @tag_list = tag_list
  end

  def id
    @id
  end

  def save
    self.id = rand(1000)
    after_save
  end

  def after_save
    update_tags_to_redis
  end
end