class DirValidator::Validator

  attr_accessor(
    :root_path,
    :catalog,
    :warnings)

  def initialize(root_path)
    @root_path = root_path
    @catalog   = DirValidator::Catalog.new(self)
    @warnings  = []
  end

  def dirs(vid, opts = {})
    quant = DirValidator::Quantity.new(opts[:n] || '1+')

    items = @catalog.unmatched_dirs
    items = name_filtered(items, opts)
    items = quantity_limited(items, quant)

    sz = items.size
    add_warning(vid, "Expected #{quant.spec.inspect}, got #{sz}.") unless sz >= quant.min_n

    items.each { |i| i.matched = true }

    return items
  end

  def dir(vid, opts = {})
    return dirs(vid, opts.merge({:n => '1'}))
  end

  def name_filtered(items, opts)
    rgx = name_regex(opts)
    return items.select { |i| i.path =~ rgx  }
  end

  def name_regex(opts)
    name    = opts[:name]
    re      = opts[:re]
    pattern = opts[:pattern]
    nmrgx   = name    ? Regexp.quote(name)     :
              pattern ? pattern_to_re(pattern) :
              re      ? re                     : ''
    return Regexp.new(nmrgx)
  end

  def pattern_to_re(pattern)
    return pattern.gsub(/\*/, '.*').gsub(/\?/, '.')
  end

  def quantity_limited(items, quant)
    return items[0 .. quant.max_index]
  end

  def add_warning(vid, msg)
    @warnings << "#{vid}: #{msg}"
  end

  def report
    @warnings.each { |w| puts w }
  end

end

__END__

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
