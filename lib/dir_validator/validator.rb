class DirValidator::Validator
  
  attr_accessor(
    :root_path,
    :current_root,
    :validators,
    :exp_name,
    :warnings)

  def initialize(root_path)
    @root_path    = root_path
    @current_root = root_path
    @validators   = []
    @exp_name     = nil
    @warnings     = []
  end

  def file(opts = {})
    dv = DirValidator::Validator.new(@current_root)
    dv.exp_name = opts[:name] if opts[:name]
    @validators << dv
  end

  def validate
    if @exp_name
      f = File.join @current_root, @exp_name
      @warnings << "Not found: #{f}" unless File.file? f
    end
    @validators.each do |dv|
      dv.validate
    end
  end

  def all_warnings
    @warnings + @validators.map { |v| v.all_warnings }.flatten
  end

  def report
    validate
    all_warnings.each { |w| puts w }
  end

end
