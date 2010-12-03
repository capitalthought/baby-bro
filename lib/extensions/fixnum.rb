class Fixnum
  def seconds
    self
  end
  alias :second :seconds
  def minutes
    self * 60
  end
  alias :minute :minutes
  def hours
    self * 60 * 60
  end
  alias :hour :hours
  def days
    self * 60 * 60 * 24
  end
  alias :day :days
end
