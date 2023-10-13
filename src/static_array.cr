struct StaticArray(T, N)
  macro [](*args)
    %array = uninitialized StaticArray(typeof({{*args}}), {{args.size}})
    {% for arg, i in args %}
      %array.to_unsafe[{{i}}] = {{arg}}
    {% end %}
    %array
  end

  def self.new(& : Int32 -> T) : self
    array = uninitialized self
    N.times { |i| array.to_unsafe[i] = yield i }
    array
  end

  def []=(index : Int32, value : T)
    index = check_in_bounds!(index)
    to_unsafe[index] = value
  end

  def [](index : Int32) : T
    index = check_in_bounds!(index)
    to_unsafe[index]
  end

  def []?(index : Int32) : T?
    if index = in_bounds?(index)
      to_unsafe[index]
    end
  end

  def size : Int32
    N
  end

  def to_slice : Slice(T)
    Slice.new(to_unsafe, N)
  end

  def to_unsafe : Pointer(T)
    pointerof(@buffer)
  end

  private def check_in_bounds!(index : Int32)
    unless in_bounds?(index)
      panic! "out of bounds (index=%lld, size=%lld)", index.to_u64, N.to_u64
    end
  end

  private def in_bounds?(index : Int32) : Bool
    index += N if index < 0
    0 <= index < N
  end
end
