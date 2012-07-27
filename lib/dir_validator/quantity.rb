# @!visibility private
class DirValidator::Quantity

  attr_reader(:spec, :min_n, :max_n, :max_index)

  def initialize(spec)
    @spec = spec
    parse_spec
  end

  def parse_spec
    case @spec
    when '*'
      # 0+.
      @min_n     = 0
      @max_n     = 1.0 / 0
      @max_index = -1
    when '+'
      # 1+.
      @min_n     = 1
      @max_n     = 1.0 / 0
      @max_index = -1
    when '?'
      # Zero or one (ie, optional).
      @min_n     = 0
      @max_n     = 1
      @max_index = @max_n - 1
    when /\A (\d+)\+ \z/x
      # n+
      @min_n     = $1.to_i
      @max_n     = 1.0 / 0
      @max_index = -1
    when /\A (\d+) \z/x
      # n
      @min_n     = $1.to_i
      @max_n     = @min_n
      @max_index = @max_n - 1
    when /\A (\d+) - (\d+) \z/x
      # m-n
      @min_n     = $1.to_i
      @max_n     = $2.to_i
      @max_index = @max_n - 1
    else
      invalid_spec()
    end

    # Sanity check min and max.
    invalid_spec() if (@min_n > @max_n or @min_n < 0)
  end

  def invalid_spec
    raise ArgumentError, "Invalid quantitifer: #{@spec.inspect}."
  end

end
