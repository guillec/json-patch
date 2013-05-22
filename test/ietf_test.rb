require 'test_helper'
require 'json/patch'

describe "IETF JSON Patch Test" do

  TESTDIR = File.dirname File.expand_path __FILE__
  spec_json    = File.read File.join TESTDIR, 'json-patch-tests', 'tests.json'
  specs = JSON.load spec_json

  describe "Test JSON File" do
    specs.each_with_index do |spec, index|
      next unless spec['doc']


      comment = spec['comment']
      unless spec['disabled']

        describe "A JSON String " do
          it "#{comment || spec['error'] || index}" do

            target_doc     = JSON.dump(spec['doc']) if spec['doc']
            operations_doc = JSON.dump(spec['patch']) if spec['patch']
            expected_doc   = JSON.dump(spec['expected']) if spec['expected']

            if spec['error']
              assert_raises(ex(spec['error'])) do
                JSON.patch(target_doc, operations_doc)
              end
            else
              result_doc = JSON.patch(target_doc, operations_doc)
              assert_equal JSON.parse(expected_doc || target_doc), JSON.parse(result_doc)
            end
          end
        end

        describe "A Ruby Object" do
          it "#{comment || spec['error'] || index}" do

            target_doc     = eval(spec['doc'].to_s) if spec['doc']
            operations_doc = eval(spec['patch'].to_s) if spec['patch']
            expected_doc   = eval(spec['expected'].to_s) if spec['expected']

            if spec['error']
              assert_raises(ex(spec['error'])) do
                JSON::Patch.new(target_doc, operations_doc).call
              end
            else
              result_doc = JSON::Patch.new(target_doc, operations_doc).call
              assert_equal (expected_doc || target_doc), result_doc
            end
          end
        end

      end
    end
  end

  private
  def ex msg
    case msg
    when /Out of bounds/i then
      JSON::PatchOutOfBoundException
    when /Object operation on array target/ then
      JSON::PatchObjectOperationOnArrayException
    else
      JSON::PatchError
    end
  end

end
