require 'test_helper'
require 'json/patch'

describe "Section 4: Operation objects" do

  describe "Operation objects MUST have at least one 'op' member" do
    let(:target_document) { %q'{}' }
    let(:operation_document) { %q'[{"path":"/a/b/c"}]' }

    it "will raise exception when no 'op' member exist" do
      assert_raises(JSON::PatchError) do 
        JSON.patch(target_document, operation_document)
      end
    end
  end

  describe "Operation objects 'op' member MUST be one of the correct values" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:add_operation_document) { %q'[{"op":"add","path":"/foo/1","value":"qux"}]' }
    let(:remove_operation_document) { %q'[{ "op": "remove", "path": "/baz" }]' }
    let(:replace_operation_document) { %q'[{"op":"replace","path":"/foo/1","value":"qux"}]' }
    let(:move_operation_document) { %q'[{"op":"replace","from":"foo","path":"/foo/1","value":"qux"}]' }
    let(:copy_operation_document) { %q'[{"op":"replace","from":"foo","path":"/foo/1","value":"qux"}]' }
    let(:test_operation_document) { %q'[{"op":"test", "path":"/foo/1","value":"baz"}]' }
    let(:error_operation_document) { %q'[{"op": "hammer time"}]' }

    it "can contain a 'add' value" do
      assert JSON.patch(target_document, add_operation_document)
    end

    it "can contain a 'remove' value" do
      assert JSON.patch(target_document, remove_operation_document)
    end

    it "can contain a 'replace' value" do
      assert JSON.patch(target_document, replace_operation_document)
    end

    it "can contain a 'move' value" do
      assert JSON.patch(target_document, move_operation_document)
    end

    it "can contain a 'copy' value" do
      assert JSON.patch(target_document, copy_operation_document)
    end

    it "can contain a 'test' value" do
      assert JSON.patch(target_document, test_operation_document)
    end

    it "will raise exception when 'op' member contains invalid 'hammer time' value" do
      assert_raises(JSON::PatchError) do 
        JSON.patch(target_document, error_operation_document)
      end
    end
  end

  describe "Operation objects MUST have at least one path member" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:operation_document) { %q'[{"op":"add", "value":"qux"}]' }

    it "will raise exception when no 'path' member exist" do
      assert_raises(JSON::PatchError) do
        JSON.patch(target_document, operation_document)
      end
    end
  end

  describe "Operation members not define by the action MUST be ignored" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:operation_document) { %q'[{"op":"add","path":"/foo/1","value":"qux", "ignore":"This please"}]' }

    it "ignores the 'ignore' member of the add operation_document" do
      expected  = %q'{"foo":["bar","qux","baz"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

end

describe "Section 4.1: The add operation" do

  describe "If the target location specifies an array index" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:operation_document) { %q'[{"op":"add","path":"/foo/1","value":"qux"}]' }

    it "inserts the value into the array at specified index" do
      expected  = %q'{"foo":["bar","qux","baz"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "If the target location species a object member that does not exist" do
    let(:target_document) { %q'{"foo":"bar"}' }
    let(:operation_document) { %q'[{ "op": "add", "path": "/baz", "value": "qux" }]' }

    it "it will add the object to the target_document" do
      expected  = %q'{"foo":"bar","baz":"qux"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "If the target location species a member that does exist" do
    let(:target_document) { %q'{"foo":"bar","baz":"wat"}' }
    let(:operation_document) { %q'[{ "op": "add", "path": "/baz", "value": "qux" }]' }

    it "it replaces the value" do
      expected  = %q'{"foo":"bar","baz":"qux"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "The add operation MUST contina a 'value' member" do
    let(:target_document) { %q'{"foo":"bar","baz":"wat"}' }
    let(:operation_document) { %q'[{ "op": "add", "path": "/baz" }]' }

    it "will raise exception if no 'value' member" do
      assert_raises(JSON::PatchError) do
        JSON.patch(target_document, operation_document)
      end
    end
  end

=begin
TODO
When the operation is applied, the target location MUST reference one of:

1. The root of the target document - whereupon the specified value
becomes the entire content of the target document.

2. A member to add to an existing object - whereupon the supplied
value is added to that object at the indicated location.  If the
member already exists, it is replaced by the specified value.

3.  An element to add to an existing array - whereupon the supplied
value is added to the array at the indicated location.  Any
elements at or above the specified index are shifted one position
to the right.  The specified index MUST NOT be greater than the
number of elements in the array.  If the "-" character is used to
index the end of the array (see [RFC6901]), this has the effect of
appending the value to the array.
=end

end

describe "Section 4.2: The remove operation" do

  describe "Removing a object member" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "remove", "path": "/baz" }]' }

    it "will remove memeber of object at the target location" do
      expected = %q'{"foo":"bar"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "Removing a array element" do
    let(:target_document) { %q'{"foo":["bar","qux","baz"]}' }
    let(:operation_document) { %q'[{ "op": "remove", "path": "/foo/1" }]' }

    it "will remove object in array at the target location" do
      expected = %q'{"foo":["bar","baz"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "Target location MUST exist for the remove operation" do
    let(:target_document) { %q'{"foo":["bar","qux","baz"]}' }
    let(:operation_document) { %q'[{ "op": "remove"}]' }

    it "will raise an exception if no target is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end

end

describe "Section 4.3: The replace operation" do

  describe "Replacing a value" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "replace", "path": "/baz", "value": "boo" }]' }

    it "will replace old value with a new value at target location" do
      expected  = %q'{"foo":"bar","baz":"boo"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "The replace operation document MUST contain a 'value' member" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "replace", "path": "/baz" }]' }

    it "will raise an exception if no 'value' is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end

  describe "The replace operation MUST have a target location" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "replace", "value": "boo" }]' }

    it "will raise an exception if no target is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end
end

describe "Section 4.4: The move operation" do

  describe "The move operation" do
    let(:target_document) { %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault"}}' }
    let(:operation_document) { %q'[{ "op": "move", "from":"/foo/waldo", "path": "/qux/thud" }]' }

    it "will remove the value at a specified location and add it to the target location" do
      expected  = %q'{"foo":{"bar":"baz"},"qux":{"corge":"grault","thud":"fred"}}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "The move operation" do
    let(:target_document) { %q'{"foo":["add","grass","cows","eat"]}' }
    let(:operation_document) { %q'[{ "op": "move", "from":"/foo/1", "path": "/foo/3" }]' }

    it "will move a array element to new location" do
      expected  = %q'{"foo":["add","cows","eat","grass"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "The move operation MUST hav a 'from' memeber" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "move", "value": "boo" }]' }

    it "will raise an exception if no from 'from' location is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end

=begin
TODO The "from" location MUST NOT be a proper prefix of the "path"
   location; i.e., a location cannot be moved into one of its children.
=end

end

describe "Section 4.5: The copy operation" do

  describe "The copy operation" do
    let(:target_document) { %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault"}}' }
    let(:operation_document) { %q'[{ "op": "copy", "from":"/foo/waldo", "path": "/qux/waldo" }]' }

    it "will copy a value from a specified location to the target location" do
      expected  = %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault","waldo":"fred"}}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "The copy operation MUST have a 'from' member" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "copy", "path": "/foo" }]' }

    it "will raise an exception if no 'from' location is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end

end

describe "Section 4.6: The test operation" do

#The "test" operation tests that a value at the target location is equal to a specified value.

  describe "The test operation MUST contain a 'value' member" do
    let(:target_document) { %q'{"baz":"qux","foo":["a",2,"c"]}' }
    let(:operation_document) { %q'[{ "op": "test", "path": "/baz"}, {"op": "test", "path": "/foo/1"}]' }

    it "will raise a exception if no 'value' is specified" do
      assert_raises(JSON::PatchError) do
        JSON.patch(target_document, operation_document)
      end
    end
  end

  describe "The test operation target location MUST be equal to the 'value' member" do
    let(:target_document) { %q'{"baz":"qux","foo":["a",2,"c"]}' }
    let(:operation_document) { %q'[{ "op": "test", "path": "/baz", "value": "qux"}, {"op": "test", "path": "/foo/1", "value": "bar"}]' }

    it "will return true because the values are equal" do
      assert JSON.patch(target_document, operation_document)
    end
  end

  describe "Testing that strings have the same number of Unicode characters and their code points are byte-to-byte equal" do
    let(:target_document) { %q'{"baz":"qux","foo":["a",2,"c"]}' }
    let(:operation_document) { %q'[{ "op": "test", "path": "/baz", "value": "qux"}]' }

    it "will return true since the strings are equal" do
      assert JSON.patch(target_document, operation_document)
    end
  end

  describe "Testing that numbers are equal if their values are numerically equal" do
    let(:target_document) { %q'{"baz": 1,"foo":["a",2,"c"]}' }
    let(:operation_document) { %q'[{ "op": "test", "path": "/baz", "value": 1}]' }

    it "will return true since the numbers are equal" do
      assert JSON.patch(target_document, operation_document)
    end
  end

  describe "Testing that arrays are equal if they contain then same number of values and these values are equal" do
    let(:target_document) { %q'{"baz": 1,"foo":["a",2,"c"]}' }
    let(:operation_document) { %q'[{"op": "test", "path": "/foo", "value": ["a",2,"c"]}]' }

    it "will return true since arrays and values are equal" do
      assert JSON.patch(target_document, operation_document)
    end
  end

  describe "Testing that objects are equal if they contain then same number of members and each member has same keys and values" do
    let(:target_document) { %q'{"baz": 1,"foo":{"foo": "bar","hammer": "time"}}' }
    let(:operation_document) { %q'[{"op": "test", "path": "/foo", "value": {"foo": "bar", "hammer":"time"}}]' }

    it "will return true since objects equal" do
      assert JSON.patch(target_document, operation_document)
    end
  end

=begin
  TODO
  5  literals (false, true, and null): are considered equal if they are
     the same.

  Also, note that ordering of the serialization of object members is
     not significant.
=end

describe "JSON::Patch object" do

  describe "JSON::Patch.new " do
    let(:target_document) { {"foo" => { "bar" => "baz", "waldo" => "fred" }, "qux" => { "corge" => "grault" } } }
    let(:operation_document) { [{ "op"=> "copy", "from" => "/foo/waldo", "path" => "/qux/waldo" }] }

    it "can handle plain ruby objects" do
      expected  = %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault","waldo":"fred"}}'
      assert_equal expected, JSON::Patch.new(target_document, operation_document).call
    end
  end

end


end
