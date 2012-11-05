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
    self.tags_collection = RedisTags::TagList.new(self).append_multi(@tag_list)
  end
end