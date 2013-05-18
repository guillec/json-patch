require 'json'

module JSON
  PatchError = Class.new(StandardError)

  def self.patch(target_document, operation_document)
    target_document = JSON.parse(target_document)
    operation_documents = JSON.parse(operation_document)

    operation_documents.each do |operation_doc|
      raise PatchError if operation_doc["op"] == nil
      raise PatchError unless ["add","remove","replace","move","copy","test"].include?(operation_doc["op"])
      raise PatchError if operation_doc["path"] == nil
      return send(operation_doc["op"].to_sym, target_document, operation_doc)
    end
  end


  private

  ESC = {'^/' => '/', '^^' => '^', '~0' => '~', '~1' => '/'}
  def self.parse_target(path)
    if path == '/'
      ['']
    else
      path.sub(/^\//, '').split(/(?<!\^)\//).map! { |part|
        part.gsub!(/\^[\/^]|~[01]/) { |m| ESC[m] }
        part
      }
    end
  end

  def self.build_target_array(path_array, object)
    path_array.inject(object) do |obj, part|
      obj[(Array === obj ? part.to_i : part)]
    end
  end

  def self.add(target_document, operation_document)
    raise JSON::PatchError if operation_document["value"] == nil
    json_pointer = operation_document["path"]
    path_array =  parse_target(json_pointer)
    reference_token = path_array.pop
    dest = build_target_array(path_array, target_document)
    add_operation(target_document, path_array, dest, reference_token, operation_document["value"])
    JSON.dump(target_document)
  end

  def self.add_to_original(object, path, dest, new_array)
    path.inject(object) do |obj, part|
      obj[(Array === obj ? part.to_i : part)]
      if part == path.last
        object[part] = new_array
      end
    end
  end

  def self.add_operation(obj, path, dest, reference_token, value)
    if Array === dest
      new_array = dest.insert reference_token.to_i, value
      return self.add_to_original(obj, path, dest, new_array)
    else
      dest[reference_token] = value
    end
  end
  
  def self.remove(target_document, operation_document)
    raise JSON::PatchError if operation_document["path"] == nil
    json_pointer = operation_document["path"]
    path_array =  parse_target(json_pointer)
    reference_token = path_array.pop
    dest = build_target_array(path_array, target_document)
    remove_operation(target_document, path_array, dest, reference_token)
    JSON.dump(target_document)
  end

  def self.remove_operation(obj, path, dest, reference_token)
    if Array === dest
      dest.delete_at reference_token.to_i
    else
      obj.delete reference_token
    end
  end

  def self.replace(target_document, operation_document)
    raise JSON::PatchError if operation_document["path"] == nil
    raise JSON::PatchError if operation_document["value"] == nil
    json_pointer = operation_document["path"]
    path_array =  parse_target(json_pointer)
    reference_token = path_array.pop
    dest = build_target_array(path_array, target_document)
    remove_operation(target_document, path_array, dest, reference_token)
    add_operation(target_document, path_array, dest, reference_token, operation_document["value"])
    JSON.dump(target_document)
  end

  def self.remove_operation(obj, path, dest, reference_token)
    if Array === dest
      dest.delete_at reference_token.to_i
    else
      dest.delete reference_token
    end
  end

  def self.get_value_at(obj, path, dest, reference_token)
    if Array === dest
      dest.at reference_token.to_i
    else
      dest[reference_token]
    end
  end

  def self.move(target_document, operation_document)
    raise JSON::PatchError if operation_document["from"] == nil
    from_json_pointer = operation_document["from"]
    from_path_array =  parse_target(from_json_pointer)
    from_reference_token = from_path_array.pop
    from = build_target_array(from_path_array, target_document)
    moving_value = remove_operation(target_document, from_path_array, from, from_reference_token)

    to_json_pointer = operation_document["path"]
    to_path_array =  parse_target(to_json_pointer)
    to_reference_token = to_path_array.pop
    to = build_target_array(to_path_array, target_document)
    add_operation(target_document, to_path_array, to, to_reference_token, moving_value)

    JSON.dump(target_document)
  end

  def self.copy(target_document, operation_document)
    raise JSON::PatchError if operation_document["from"] == nil
    temp_doc = target_document.clone
    from_json_pointer = operation_document["from"]
    from_path_array =  parse_target(from_json_pointer)
    from_reference_token = from_path_array.pop
    from = build_target_array(from_path_array, temp_doc)
    moving_value = get_value_at(temp_doc, from_path_array, from, from_reference_token)

    to_json_pointer = operation_document["path"]
    to_path_array =  parse_target(to_json_pointer)
    to_reference_token = to_path_array.pop
    to = build_target_array(to_path_array, target_document)
    add_operation(target_document, to_path_array, to, to_reference_token, moving_value)
    JSON.dump(target_document)
  end

  def self.test(target_document, operation_document)
    raise JSON::PatchError if operation_document["value"] == nil
    json_pointer = operation_document["path"]
    path_array =  parse_target(json_pointer)
    reference_token = path_array.pop
    dest = build_target_array(path_array, target_document)
    value = get_value_at(target_document, path_array, dest, reference_token)
    value == operation_document["value"]
  end

end
