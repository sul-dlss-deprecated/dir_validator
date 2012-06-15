class DirValidator::Validator
  
  attr_accessor(
    :root_path,
    :current_root,
    :validators,
    :exp_name,
    :top_parent,
    :warnings)

  def initialize(root_path, opts = {})
    @root_path    = root_path
    @current_root = root_path
    @validators   = []
    @exp_name     = nil
    @warnings     = []
    @catalog      = nil
    @top_parent   = opts[:top_parent] || self
  end

  def is_top_parent?
    return self.equal?(@top_parent)
  end

  def file(opts = {})
    dv = DirValidator::Validator.new(@current_root, :top_parent => @top_parent || self)
    dv.exp_name = opts[:name] if opts[:name]
    @validators << dv
  end

  def validate
    cat = catalog()
    if @exp_name
      @top_parent.warnings << "Not found: #{@exp_name}" unless cat.has_key?(@exp_name)
    end
    @validators.each do |dv|
      dv.validate
    end
  end

  def all_warnings
    @top_parent.warnings
  end

  def report
    validate
    all_warnings.each { |w| puts w }
  end

  def catalog
    return @top_parent.catalog unless is_top_parent?
    return @catalog if @catalog
    content  = Dir.chdir(@current_root) { Dir.glob('**/*', File::FNM_DOTMATCH) }
    @catalog = Hash[ content.sort.map { |item| [item, true] } ]
    return @catalog
  end

end
