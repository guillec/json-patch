require 'test_helper'
require 'json/patch_document'

describe "Section 4" do

=begin
 Operation objects MUST have exactly one "op" member, whose value
 indicates the operation to perform.
=end

  describe "MUST have at least one op member" do
    let(:target_document) { %q'{}' }
    let(:operation_document) { %q'[{"path":"/a/b/c"}]' }

    it "contains 'op' member" do
      assert_raises(JSON::PatchError) do 
        JSON.patch(target_document, operation_document)
      end
    end
  end

=begin
Its value MUST be one of "add", "remove", "replace", "move", "copy", or "test"; 
other values are errors.
=end

  describe "MUST be one of the correct values" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:add_operation_document) { %q'[{"op":"add","path":"/foo/1","value":"qux"}]' }
    let(:remove_operation_document) { %q'[{ "op": "remove", "path": "/baz" }]' }
    let(:replace_operation_document) { %q'[{"op":"replace","path":"/foo/1","value":"qux"}]' }
    let(:move_operation_document) { %q'[{"op":"replace","from":"foo","path":"/foo/1","value":"qux"}]' }
    let(:copy_operation_document) { %q'[{"op":"replace","from":"foo","path":"/foo/1","value":"qux"}]' }
    let(:error_operation_document) { %q'[{"op": "hammer time"}]' }

    it "'op' member contains 'add' value" do
      assert JSON.patch(target_document, add_operation_document)
    end

    it "'op' member contains 'remove' value" do
      assert JSON.patch(target_document, remove_operation_document)
    end

    it "'op' member contains 'replace' value" do
      assert JSON.patch(target_document, replace_operation_document)
    end

    it "'op' member contains 'move' value" do
      assert JSON.patch(target_document, move_operation_document)
    end

    it "'op' member contains 'copy' value" do
      assert JSON.patch(target_document, copy_operation_document)
    end

    it "raises error when 'op' member contains invalid 'hammer time' value" do
      assert_raises(JSON::PatchError) do 
        JSON.patch(target_document, error_operation_document)
      end
    end
  end
 
=begin
Additionally, operation objects MUST have exactly one "path" member.
=end

  describe "MUST have at least one path member" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:operation_document) { %q'[{"op":"add", "value":"qux"}]' }

    it "contains 'path' member" do
      assert_raises(JSON::PatchError) do
        JSON.patch(target_document, operation_document)
      end
    end
  end

=begin
The meanings of other operation object members are defined by
operation (see the subsections below).  Members that are not
explicitly defined for the operation in question MUST be ignored
(i.e., the operation will complete as if the undefined member did not
appear in the object).
=end

  describe "Other operation members not define by the action MUST be ignored" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:operation_document) { %q'[{"op":"add","path":"/foo/1","value":"qux", "ignore":"This please"}]' }

    it "ignores the 'ignore' member of the add operation_document " do
      expected  = %q'{"foo":["bar","qux","baz"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

end

describe "Section 4.1" do

=begin
The "add" operation performs one of the following functions,
depending upon what the target location references:

  1. If the target location specifies an array index, a new value is
  inserted into the array at the specified index.
=end

  describe "If target location specifies an array index a new value is inserted" do
    let(:target_document) { %q'{ "foo":["bar","baz"] }' }
    let(:operation_document) { %q'[{"op":"add","path":"/foo/1","value":"qux"}]' }

    it "inserts value into the array at specified index" do
      expected  = %q'{"foo":["bar","qux","baz"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

=begin
If the target location specifies an object member that does not
already exist, a new member is added to the object.
=end

  describe "If the target location species a member that doesnt exist" do
    let(:target_document) { %q'{"foo":"bar"}' }
    let(:operation_document) { %q'[{ "op": "add", "path": "/baz", "value": "qux" }]' }

    it "it is added to the object" do
      expected  = %q'{"foo":"bar","baz":"qux"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

=begin
If the target location specifies an object member that does exist,
that member's value is replaced.
=end

  describe "If the target location species a member that does exist" do
    let(:target_document) { %q'{"foo":"bar","baz":"wat"}' }
    let(:operation_document) { %q'[{ "op": "add", "path": "/baz", "value": "qux" }]' }

    it "it is added to the object" do
      expected  = %q'{"foo":"bar","baz":"qux"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

=begin
  The add operation MUST contain a "value" memeber
=end

  describe "The add operation MUST contina a 'value' member" do
    let(:target_document) { %q'{"foo":"bar","baz":"wat"}' }
    let(:operation_document) { %q'[{ "op": "add", "path": "/baz" }]' }

    it "will raise error if no value member" do
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

describe "Section 4.2" do

=begin
  The remove value removes the value at the target location
=end

  describe "Removing a object member at a target location" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "remove", "path": "/baz" }]' }
    it "will remove memeber of object" do
      expected = %q'{"foo":"bar"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "Removing a array element a target location" do
    let(:target_document) { %q'{"foo":["bar","qux","baz"]}' }
    let(:operation_document) { %q'[{ "op": "remove", "path": "/foo/1" }]' }
    it "will remove object in array" do
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

describe "Section 4.3" do

=begin
The "replace" operation replaces the value at the target location
with a new value.  The operation object MUST contain a "value" member
whose content specifies the replacement value.
=end

  describe "Replacing a value at a target" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "replace", "path": "/baz", "value": "boo" }]' }
    it "will replace old value with a new value" do
      expected  = %q'{"foo":"bar","baz":"boo"}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

=begin
The target location MUST exist for the operation to be successful.
=end

  describe "Target location MUST exist for the replace operation" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "replace", "value": "boo" }]' }
    it "will raise an exception if no target is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end
end

describe "Section 4.4" do

=begin
The "move" operation removes the value at a specified location and
adds it to the target location.
=end

  describe "Moving operation" do
    let(:target_document) { %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault"}}' }
    let(:operation_document) { %q'[{ "op": "move", "from":"/foo/waldo", "path": "/qux/thud" }]' }
    it "will move a object element to new location" do
      expected  = %q'{"foo":{"bar":"baz"},"qux":{"corge":"grault","thud":"fred"}}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

  describe "Moving operation" do
    let(:target_document) { %q'{"foo":["add","grass","cows","eat"]}' }
    let(:operation_document) { %q'[{ "op": "move", "from":"/foo/1", "path": "/foo/3" }]' }
    it "will move a array element to new location" do
      expected  = %q'{"foo":["add","cows","eat","grass"]}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

=begin
The "from" location MUST exist.
=end

  describe "From location MUST exist for the move operation" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "move", "value": "boo" }]' }
    it "will raise an exception if no from location is specified" do
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

describe "Section 4.5" do

=begin
The "copy" operation copies the value at a specified location to the
target location.
=end

  describe "Copy operation" do
    let(:target_document) { %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault"}}' }
    let(:operation_document) { %q'[{ "op": "copy", "from":"/foo/waldo", "path": "/qux/waldo" }]' }
    it "will copy a value from a specified location to the target location" do
      expected  = %q'{"foo":{"bar":"baz","waldo":"fred"},"qux":{"corge":"grault","waldo":"fred"}}'
      assert_equal expected, JSON.patch(target_document, operation_document)
    end
  end

#The "from" location MUST exist for the operation to be successful.

  describe "From location MUST exist for the copy operation" do
    let(:target_document) { %q'{"foo":"bar","baz":"qux"}' }
    let(:operation_document) { %q'[{ "op": "copy", "path": "/foo" }]' }
    it "will raise an exception if no from location is specified" do
      assert_raises(JSON::PatchError) do
       JSON.patch(target_document, operation_document)
      end
    end
  end

end
