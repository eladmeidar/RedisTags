class Book
  include RedisTags

  uses_redis_tags

  def id
    @id ||= rand(1000)
  end
end