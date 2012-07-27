# @!attribute [r] vid
#   @see #initialize
#   @return [String]
# @!attribute [r] opts
#   @see #initialize
#   @return [Hash]
class DirValidator::Warning

  attr_reader(:vid, :opts)

  # @param  vid  [String] Validation identifier of the validation-method call
  #                       that led to the warning.
  # @param  opts [Hash]   Validation-method options hash, along with some additional
  #                       information about the context in which the warning was
  #                       generated.
  def initialize(vid, opts)
    @vid  = vid
    @opts = opts
  end

  # Returns a basic representation of the information contained in the warning.
  #
  # @return [String]
  def to_s
    return "#{@vid}: #{@opts.inspect}"
  end

end
