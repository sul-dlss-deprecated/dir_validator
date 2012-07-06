class DirValidator::Warning

  attr_reader(:vid, :opts)

  def initialize(vid, opts)
    @vid  = vid
    @opts = opts
  end

  def to_s
    return "#{@vid}: #{@opts.inspect}"
  end

end
