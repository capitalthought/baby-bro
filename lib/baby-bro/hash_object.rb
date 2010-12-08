class HashObject
  def initialize hash_obj, no_exception_on_missing_key = false
    @hash_obj = hash_obj
    @no_exception_on_missing_key = no_exception_on_missing_key
  end    
  
  def [] key
    @hash_obj[key]
  end
  
  def keys
    return @hash_obj.keys
  end
  
  def merge hash
    HashObject.new(@hash_obj.merge( hash ))
  end
  
  def merge! hash
    @hash_obj.merge!( hash )
    self
  end

  def method_missing method, *args
    key = method.to_s
    if @hash_obj.keys.include? key
      obj = @hash_obj[key]
      obj = HashObject.new(obj) if obj.is_a? Hash
      return obj
    elsif @hash_obj.keys.include? key.to_sym
      obj = @hash_obj[key.to_sym]
      obj = HashObject.new(obj) if obj.is_a? Hash
      return obj
    elsif matches = key.match( /(\w*)=/ )
      key = matches[1].to_sym
      @hash_obj[key]=args.first
    else
      raise "No field in Hash object: #{key}" unless @no_exception_on_missing_key
    end
  end
end
