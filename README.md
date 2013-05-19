# JSON::Patch
[![Build Status](https://travis-ci.org/guillec/json-patch.png)](https://travis-ci.org/guillec/json-patch)
[![Code Climate](https://codeclimate.com/github/guillec/json-patch.png)](https://codeclimate.com/github/guillec/json-patch)

This gem augments Ruby's built-in JSON library to support JSON Patch
(identified by the json-patch+json media type). http://tools.ietf.org/html/rfc6902

## Installation

Add this line to your application's Gemfile:

    gem 'json-patch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-patch

## Usage

Then, use it:

```ruby
# The example from http://tools.ietf.org/html/rfc6902#appendix-A

# Add Object Member
target_document = <<-JSON
  { "foo": "bar"}
JSON

operations_document = <<-JSON
[
  { "op": "add", "path": "/baz", "value": "qux" }
]
JSON

JSON.patch(target_document, operations_document)
# => 
{ "baz": "qux", "foo": "bar" }


# Add Array Element
target_document = <<-JSON
  { "foo": [ "bar", "baz" ] }
JSON

operations_document = <<-JSON
[
  { "op": "add", "path": "/foo/1", "value": "qux" }
]
JSON

JSON.patch(target_document, operations_document)
# => 
{ "foo": [ "bar", "qux", "baz" ] }
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
