require 'test_helper'
require 'json/patch'

describe "01 tests.json" do
  let(:target_document) { %q'{}' }
  let(:operation_document) { %q'[]' }

  it "" do
    expected  = %q'{}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "02 tests.json" do
  let(:target_document) { %q'{"foo": 1}' }
  let(:operation_document) { %q'[]' }

  it "" do
    expected  = %q'{"foo": 1}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "03 tests.json" do
  let(:target_document) { %q'{"foo": 1, "bar": 2}' }
  let(:operation_document) { %q'[]' }

  it "" do
    expected  = %q'{"bar": 2, "foo": 1}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "04 tests.json" do
  let(:target_document) { %q'[{"foo": 1, "bar": 2}]' }
  let(:operation_document) { %q'[]' }

  it "" do
    expected  = %q'[{"bar": 2, "foo": 1}]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "05 tests.json" do
  let(:target_document) { %q'{"foo": { "foo": 1, "bar": 2}}' }
  let(:operation_document) { %q'[]' }

  it "" do
    expected  = %q'{"foo":{"bar": 2, "foo": 1}}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "06 tests.json" do
  let(:target_document) { %q'{"foo": null}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/foo", "value": 1}]' }

  it "" do
    expected  = %q'{"foo": 1}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "07 tests.json" do
  let(:target_document) { %q'[]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/0", "value": "foo"}]' }

  it "" do
    expected  = %q'["foo"]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "08 tests.json" do
  let(:target_document) { %q'["foo"]' }
  let(:operation_document) { %q'[]' }

  it "" do
    expected  = %q'["foo"]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "09 tests.json" do
  let(:target_document) { %q'{}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/foo", "value": "1"}]' }

  it "" do
    expected  = %q'{"foo":"1"}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "10 tests.json" do
  let(:target_document) { %q'{}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/foo", "value": 1}]' }

  it "" do
    expected  = %q'{"foo":1}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

# 11 is dissabled

describe "12 tests.json" do
  let(:target_document) { %q'{}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/", "value": 1}]' }

  it "" do
    expected  = %q'{"":1}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "13 tests.json" do
  let(:target_document) { %q'{"foo": 1}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar", "value": [1,2]}]' }

  it "" do
    expected  = %q'{"foo":1, "bar":[1,2]}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "14 tests.json" do
  let(:target_document) { %q'{"foo": 1, "baz": [{"qux": "hello"}]}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/baz/0/foo", "value": "world"}]' }

  it "" do
    expected  = %q'{"foo": 1, "baz": [{"qux": "hello", "foo": "world"}]} '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "15 tests.json" do
  let(:target_document) { %q'{"bar": [1, 2]}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar/8", "value": "5"}]' }

  it "" do
    assert_raises(JSON::PatchOutOfBoundException) do
      JSON.patch(target_document, operation_document)
    end
  end
end

describe "16 tests.json" do
  let(:target_document) { %q'{"bar": [1, 2]}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar/-1", "value": "5"}]' }

  it "" do
    assert_raises(JSON::PatchOutOfBoundException) do
      JSON.patch(target_document, operation_document)
    end
  end
end

describe "17 tests.json" do
  let(:target_document) { %q'{"foo": 1}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar", "value": true}]' }

  it "" do
    expected  = %q'{"foo": 1, "bar": true} '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "18 tests.json" do
  let(:target_document) { %q'{"foo": 1}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar", "value": false}]' }

  it "" do
    expected  = %q'{"foo": 1, "bar": false} '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "19 tests.json" do
  let(:target_document) { %q'{"foo": 1}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar", "value": null}]' }

  it "" do
    expected  = %q'{"foo": 1, "bar": null} '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "20 tests.json" do
  let(:target_document) { %q'{"foo": 1}' }
  let(:operation_document) { %q'[{"op": "add", "path": "/0", "value": "bar"}]' }

  it "" do
    expected  = %q'{"foo": 1, "0": "bar"} '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "21 tests.json" do
  let(:target_document) { %q'["foo"]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/1", "value": "bar"}]' }

  it "" do
    expected  = %q'["foo","bar"] '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "22 tests.json" do
  let(:target_document) { %q'["foo","sil"]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/1", "value": "bar"}]' }

  it "" do
    expected  = %q'["foo","bar","sil"] '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "23 tests.json" do
  let(:target_document) { %q'["foo","sil"]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/0", "value": "bar"}]' }

  it "" do
    expected  = %q'["bar","foo","sil"] '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "24 tests.json" do
  let(:target_document) { %q'["foo","sil"]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/2", "value": "bar"}]' }

  it "" do
    expected  = %q'["foo","sil","bar"] '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "25 tests.json" do
  let(:target_document) { %q'{"le0":"foo"}' }
  let(:operation_document) { %q'[{"op": "test", "path": "/le0", "value": "foo"}]' }

  it "" do
    expected  = %q'{"le0":"foo"} '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "26 tests.json" do
  let(:target_document) { %q'{"foo":"bar"}' }
  let(:operation_document) { %q'[{"op": "test", "path": "/le0", "value": "bar"}]' }

  it "" do
    assert_raises(JSON::PatchObjectOperationOnArrayException) do
      JSON.patch(target_document, operation_document)
    end
  end
end

describe "27 tests.json" do
  let(:target_document) { %q'["foo","sil"]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/bar", "value": 42}]' }

  it "" do
    assert_raises(JSON::PatchObjectOperationOnArrayException) do
      JSON.patch(target_document, operation_document)
    end
  end
end

describe "28 tests.json" do
  let(:target_document) { %q'["foo","sil"]' }
  let(:operation_document) { %q'[{"op": "add", "path": "/1", "value": ["bar","baz"]}]' }

  it "" do
    expected  = %q'["foo", ["bar", "baz"], "sil"] '
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "30 tests.json" do
  let(:target_document) { %q'{"foo": 1, "baz": [{"qux": "hello"}]}' }
  let(:operation_document) { %q'[{"op": "remove", "path": "/baz/0/qux"}]' }

  it "" do
    expected  = %q'{"foo": 1, "baz": [{}]}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "31 tests.json" do
  let(:target_document) { %q'{"foo": 1, "baz": [{"qux": "hello"}]}' }
  let(:operation_document) { %q'[{"op": "replace", "path": "/foo", "value": [1, 2, 3, 4]}]' }

  it "" do
    expected  = %q'{"foo": [1, 2, 3, 4], "baz": [{"qux": "hello"}]}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "32 tests.json" do
  let(:target_document) { %q'{"foo": [1, 2, 3, 4], "baz": [{"qux": "hello"}]}' }
  let(:operation_document) { %q'[{"op": "replace", "path": "/baz/0/qux", "value": "world"}]' }

  it "" do
    expected  = %q'{"foo": [1, 2, 3, 4], "baz": [{"qux": "world"}]}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "33 tests.json" do
  let(:target_document) { %q'["foo"]' }
  let(:operation_document) { %q'[{"op": "replace", "path": "/0", "value": "bar"}]' }

  it "" do
    expected  = %q'["bar"]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "34 tests.json" do
  let(:target_document) { %q'[""]' }
  let(:operation_document) { %q'[{"op": "replace", "path": "/0", "value": 0}]' }

  it "" do
    expected  = %q'[0]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "35 tests.json" do
  let(:target_document) { %q'[""]' }
  let(:operation_document) { %q'[{"op": "replace", "path": "/0", "value": true}]' }

  it "" do
    expected  = %q'[true]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "35 tests.json" do
  let(:target_document) { %q'[""]' }
  let(:operation_document) { %q'[{"op": "replace", "path": "/0", "value": true}]' }

  it "" do
    expected  = %q'[true]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "last tests.json" do
  let(:target_document) { %q'[ 1, 2 ]' }
  let(:operation_document) { %q'[ { "op": "add", "path": "/-", "value": { "foo": [ "bar", "baz" ] } } ]' }

  it "" do
    expected  = %q'[ 1, 2, { "foo": [ "bar", "baz" ] } ]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "penulitmo tests.json" do
  let(:target_document) { %q'{"foo":"bar"}' }
  let(:operation_document) { %q'[{"op": "add", "path": "", "value": {"baz": "qux"}}]' }

  it "" do
    expected  = %q'{"baz":"qux"}'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end

describe "very last one tests.json" do
  let(:target_document) { %q'[ 1, 2, [ 3, [ 4, 5 ] ] ]' }
  let(:operation_document) { %q'[ { "op": "add", "path": "/2/1/-", "value": { "foo": [ "bar", "baz" ] } } ]' }

  it "" do
    expected  = %q'[ 1, 2, [ 3, [ 4, 5, { "foo": [ "bar", "baz" ] } ] ] ]'
    result = JSON.patch(target_document, operation_document)
    assert_equal JSON.parse(expected), JSON.parse(result)
  end
end
