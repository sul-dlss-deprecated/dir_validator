class DirValidator::Warning

  attr_reader(:vid, :message)

  def initialize(vid, message)
    @vid     = vid
    @message = message
  end

  def to_s
    return "#{@vid}: #{@message}"
  end

end
