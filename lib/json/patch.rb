require 'json'

module JSON
  PatchError = Class.new(StandardError)

  def self.patch(target_doc, operations_doc)
    target_doc     = JSON.parse(target_doc)
    operations_doc = JSON.parse(operations_doc)
    JSON::Patch.new(target_doc, operations_doc).call
  end

  class Patch

    def initialize(target_doc, operations_doc)
      @target_doc     = target_doc
      @operations_doc = operations_doc
    end

    def call
      @operations_doc.each do |operation|
        raise PatchError if operation["op"] == nil
        raise PatchError unless ["add","remove","replace","move","copy","test"].include?(operation["op"])
        raise PatchError if operation["path"] == nil
        return send(operation["op"].to_sym, @target_doc, operation)
      end
    end

    private
    def add(target_doc, operation_doc)
      raise JSON::PatchError if operation_doc["value"] == nil
      path  = operation_doc["path"]
      value = operation_doc["value"]

      add_operation(target_doc, path, value)
      JSON.dump(target_doc)
    end

    def remove(target_doc, operation_doc)
      raise JSON::PatchError if operation_doc["path"] == nil
      path = operation_doc["path"]

      remove_operation(target_doc, path)
      JSON.dump(target_doc)
    end

    def replace(target_doc, operation_doc)
      raise JSON::PatchError if operation_doc["path"] == nil
      raise JSON::PatchError if operation_doc["value"] == nil

      remove(target_doc, operation_doc)
      add(target_doc, operation_doc)
      JSON.dump(target_doc)
    end

    def move(target_doc, operation_doc)
      raise JSON::PatchError if operation_doc["from"] == nil
      src   = operation_doc["from"]
      dest  = operation_doc["path"]
      value = remove_operation(target_doc, src)

      add_operation(target_doc, dest, value)
      JSON.dump(target_doc)
    end

    def copy(target_doc, operation_doc)
      raise JSON::PatchError if operation_doc["from"] == nil
      src   = operation_doc["from"]
      dest  = operation_doc["path"]
      value = find_value(target_doc, operation_doc, src)

      add_operation(target_doc, dest, value)
      JSON.dump(target_doc)
    end

    def test(target_doc, operation_doc)
      raise JSON::PatchError if operation_doc["value"] == nil
      path       = operation_doc["path"]
      value      = find_value(target_doc, operation_doc, path)
      test_value = operation_doc["value"]

      value == test_value
    end

    def add_operation(target_doc, path, value)
      path_array  = split_path(path)
      ref_token   = path_array.pop
      target_item = build_target_array(path_array, target_doc)

      if Array === target_item
        new_array = target_item.insert ref_token.to_i, value
        add_to_target_document(target_doc, path_array, target_item, new_array)
      else
        target_item[ref_token] = value
      end
    end

    def remove_operation(target_doc, path)
      path_array  = split_path(path)
      ref_token   = path_array.pop
      target_item = build_target_array(path_array, target_doc)

      if Array === target_item
        target_item.delete_at ref_token.to_i
      else
        target_item.delete ref_token
      end
    end

    def find_value(target_doc, operation_doc, path)
      path_array  = split_path(path)
      ref_token   = path_array.pop
      target_item = build_target_array(path_array, target_doc)

      if Array === target_item
        target_item.at ref_token.to_i
      else
        target_item[ref_token]
      end
    end

    def build_target_array(path_array, target_doc)
      path_array.inject(target_doc) do |doc, item|
        key = (Array === doc ? item.to_i : item)
        doc[key]
      end
    end

    def add_to_target_document(doc, path, target_item, array)
      path.inject(doc) do |obj, part|
        key = (Array === doc ? part.to_i : part)
        doc[key]
        if part == path.last
          doc[part] = array
        end
      end
    end

    def split_path(path)
      escape_charaters = {'^/' => '/', '^^' => '^', '~0' => '~', '~1' => '/'}
      if path == '/'
        ['']
      else
        path.sub(/^\//, '').split(/(?<!\^)\//).map! { |part|
          part.gsub!(/\^[\/^]|~[01]/) { |m| escape_characters[m] }
          part
        }
      end
    end
  end
end
