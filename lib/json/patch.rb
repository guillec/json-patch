require 'json'
require 'json/patch/railtie' if defined?(Rails)

module JSON
  PatchError                           = Class.new(StandardError)
  PatchOutOfBoundException             = Class.new(StandardError)
  PatchObjectOperationOnArrayException = Class.new(StandardError)

  def self.patch(target_doc, operations_doc)
    target_doc            = JSON.parse(target_doc)
    operations_doc        = JSON.parse(operations_doc)
    result_doc            = JSON::Patch.new(target_doc, operations_doc).call
    JSON.dump(result_doc)
  end

  class Patch

    def initialize(target_doc, operations_doc)
      @target_doc     = target_doc
      @operations_doc = operations_doc
    end

    def call
      return @target_doc if @operations_doc.empty?
      @operations_doc.each do |operation|
        operation = operation.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
        if allowed?(operation)
          return send(operation[:op].to_sym, @target_doc, operation)
        end
      end
    end

    private
    def allowed?(operation)
      operation.fetch(:op) { raise JSON::PatchError }
      raise JSON::PatchError unless ["add","remove","replace","move","copy","test"].include?(operation[:op])
      operation.fetch(:path) { raise JSON::PatchError }
      true
    end

    def add(target_doc, operation_doc)
      path  = operation_doc[:path]
      value = operation_doc.fetch(:value) { raise JSON::PatchError  }

      add_operation(target_doc, path, value)
      target_doc
    end

    def remove(target_doc, operation_doc)
      path = operation_doc.fetch(:path) { raise JSON::PatchError }

      remove_operation(target_doc, path)
      target_doc
    end

    def replace(target_doc, operation_doc)
      remove(target_doc, operation_doc)
      add(target_doc, operation_doc)
      target_doc
    end

    def move(target_doc, operation_doc)
      src   = operation_doc.fetch(:from) { raise JSON::PatchError }
      dest  = operation_doc[:path]
      value = remove_operation(target_doc, src)

      add_operation(target_doc, dest, value)
      target_doc
    end

    def copy(target_doc, operation_doc)
      src   = operation_doc.fetch(:from) { raise JSON::PatchError }
      dest  = operation_doc[:path]
      value = find_value(target_doc, operation_doc, src)

      add_operation(target_doc, dest, value)
      target_doc
    end

    def test(target_doc, operation_doc)
      path       = operation_doc[:path]
      value      = find_value(target_doc, operation_doc, path)
      test_value = operation_doc.fetch(:value) { raise JSON::PatchError }

      raise JSON::PatchError if value != test_value
      target_doc if value == test_value
    end

    def add_operation(target_doc, path, value)
      path_array  = split_path(path)
      ref_token   = path_array.pop
      target_item = build_target_array(path_array, target_doc)

      add_array(target_doc, path_array, target_item, ref_token, value) if target_item.kind_of? Array
      add_object(target_doc, target_item, ref_token, value) unless target_item.kind_of? Array
    end

    def add_object(target_doc, target_item, ref_token, value)
      raise JSON::PatchError if target_item.nil? 
      if ref_token.nil?
        target_doc.replace(value)
      else
        target_item[ref_token] = value
      end
    end

    def add_array(doc, path_array, target_item, ref_token, value)
      return unless valid_index?(target_item, ref_token)
      if ref_token == "-"
        new_array = target_item << value
      else
        new_array = target_item.insert ref_token.to_i, value
      end
      add_to_target_document(doc, path_array, target_item, new_array)
    end

    def valid_index?(item_array, index)
      raise JSON::PatchObjectOperationOnArrayException unless index =~ /\A-?\d+\Z/ || index == "-"
      index = index == "-" ? item_array.length : index.to_i
      raise JSON::PatchOutOfBoundException if index.to_i > item_array.length || index.to_i < 0
      true
    end

    def remove_operation(target_doc, path)
      path_array  = split_path(path)
      ref_token   = path_array.pop
      target_item = build_target_array(path_array, target_doc)
      raise JSON::PatchObjectOperationOnArrayException if target_item.nil?

      if Array === target_item
        target_item.delete_at ref_token.to_i if valid_index?(target_item, ref_token)
      else
        target_item.delete ref_token
      end
    end

    def find_value(target_doc, operation_doc, path)
      path_array  = split_path(path)
      ref_token   = path_array.pop
      target_item = build_target_array(path_array, target_doc)
      if Array === target_item
        if is_a_number?(ref_token)
        target_item.at ref_token.to_i
        else
          raise JSON::PatchObjectOperationOnArrayException
        end
      else
        target_item[ref_token]
      end
    end

    def is_a_number?(s)
      s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
    end

    def build_target_array(path_array, target_doc)
      path_array.inject(target_doc) do |doc, item|
        key = (doc.kind_of?(Array) ? item.to_i : item)
        if doc.kind_of?(Array)
          doc[key] 
        else
          doc.has_key?(key) ? doc[key] : doc[key.to_sym] unless doc.kind_of?(Array)
        end
      end
    end

    def add_to_target_document(doc, path, target_item, array)
      path.inject(doc) do |obj, part|
        key = (Array === doc ? part.to_i : part)
        doc[key]
      end
    end

    def split_path(path)
      escape_characters = {'^/' => '/', '^^' => '^', '~0' => '~', '~1' => '/'}
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
