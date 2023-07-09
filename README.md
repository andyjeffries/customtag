# CustomTag

> CustomTag allows you to use custom HTML tags in your Rails project and have them be replaced with standard HTML tags and attributes. Brought on by jealousy of extracting TailwindCSS classes to simple components in frontend frameworks.

## Usage

This gem allows you write custom HTML tags in your HTML output and have them replaced with other tags. For example you could do the following:

```html
<my-card>
  <h3>Your name here</h3>
  <div>Job title</div>
</my-card>
```

And it can be replaced with:

```html
<div class="p-4 bg-white border border-gray-200 shadow-lg">
  <h3>Your name here</h3>
  <div>Job title</div>
</div>
```

This keeps your TailwindCSS classes from being repeated all over your codebase, while not using `@apply` (<https://tailwindcss.com/docs/reusing-styles>). It's a middleground between full template systems like [Phlex](https://github.com/phlex-ruby/phlex) and [ViewComponent](https://viewcomponent.org) and just having lists of classes everywhere.

### Defining your tags

To define your tags is nice and easy. Have one or more classes that are loaded early (maybe in `config/initializers` in Rails, or directly required if you're using Sinatra or some other lightweight framework) that define the tags you're creating, and how to replace the matching content with HTML. For example, to define a class that performs a single replacement, you could do:

```ruby
class MyCard < CustomTag::Base
  register :my_card, self

  def self.build(_, attrs, content)
    attrs["class"] = "p-4 bg-white border border-gray-200 shadow-lg #{attrs["class"]}".strip
    super("div", attrs, content)
    # The super will simply build an HTML tag from the details given
  end
end
```

You can call the `register` method with any of `under_scored`, `hyphen-ated` or `CamelCased` tags names and it will automatically convert between them to accept any one of them as the same thing.

If you wish you can have multiple tags defined in a single class and use the first parameters of `build` to distinguish between them:

```ruby
class ApplicationCustomTags < CustomTag::Base
  register :my_card, self

  def self.build(tag_name, attrs, content)
    case tag_name
    when "my_card"
      my_card(attrs, content)
    when "..."
      # ...
    end
  end

  def self.my_card(attrs,content)
    attrs["class"] = "p-4 bg-white border border-gray-200 shadow-lg #{attrs["class"]}".strip
    "<div #{attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")}>#{content}</div>"
  end
end
```

### Middleware

If you're using Rails, the CustomTag Middleware will be automatically registered for you as the last middleware to be called. If you want to use it yourself in a non-Rails app, you can use it like this:

```ruby
require 'sinatra'
require 'custom_tag'

use CustomTag::Middleware

get '/hello' do
  '<some HTML here... />'
end
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    bundle add custom_tag

Or adding `gem "custom_tag"` to your `Gemfile` and running `bundle install`.

If bundler is not being used to manage dependencies, install the gem by executing:

    gem install custom_tag

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, edit the `CHANGELOG.md` file to explain the new release and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/andyjeffries/custom_tag>.
