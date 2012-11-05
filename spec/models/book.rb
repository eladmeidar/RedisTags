class Book
  include RedisTags

  uses_redis_tags

  def new
    @id = nil
  end

  def id
    @id
  end

  def save
    @id = rand(1000)
    after_save
  end

  def after_save
    update_tags_to_redis
  end
end