# RedisTags

RedisTags is a simple graph based implementation of a tagging system.
Instead of using complex relational structure, this implementation consists of using Redis sets for reference and aggregation.

## Example:

Say we tag a `User` instance with a tag named `tzetzi`:

    @user = User.new
    @user.tags_collection << `tzetzi`
    @user.save                        # => <User: id:1> 

Now in Redis, we will have these keys:

1. A set that holds the ids of the users tagged by "tzetzi"

    user:tagged_with:tzetzi => [1]

2. A set that holds all the tags for a specific user instance

    user:1:tag_list => ["tzetzi"]

3. A complete breakdown of each tag per char, to allow simple autocomplete interface

    tag:all:t                     # => ["tzetzi"]
    tag:all:tz                    # => ["tzetzi"]
    tag:all:tze                   # => ["tzetzi"]
    tag:all:tzet                  # => ["tzetzi"]
    tag:all:tzetz                 # => ["tzetzi"]
    tag:all:tzetzi                # => ["tzetzi"]

## Installation

Add this line to your application's Gemfile:

    gem 'redis_tags'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis_tags

## Usage

    class User

        include RedisTags

        uses_redis_tags :engine => Redis.new
        
    end

    @user = User.new
    @user.tag_collection                  # => []
    @user.tag_collection << "elad"        # => ["elad"]
    @user.tag_collection = ["beata"]      # => ["beata"]
    @user.save

    User.has_tags(:tags => ["elad"])   # => [@user.id]
    User.tags_starting_with("el")         # => ["elad"]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
