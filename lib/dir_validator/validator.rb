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

  def process_items(items, vid, opts = {})
    if vid.class == Hash
      msg = "Validation identifier should not be a hash: #{vid.inspect}"
      raise ArgumentError, msg
    end

    quant = DirValidator::Quantity.new(opts[:n] || '1+')

    items = name_filtered(items, opts)
    items = quantity_limited(items, quant)

    sz = items.size
    add_warning(vid, "Expected #{quant.spec.inspect}, got #{sz}.") unless sz >= quant.min_n

    items.each { |i| i.matched = true }

    return items
  end

  def dirs(vid, opts = {})
    return process_items(@catalog.unmatched_dirs, vid, opts)
  end

  def files(vid, opts = {})
    return process_items(@catalog.unmatched_files, vid, opts)
  end

  def dir(vid, opts = {})
    return dirs( vid, opts.merge({:n => '1'}) )
  end

  def file(vid, opts = {})
    return files( vid, opts.merge({:n => '1'}) )
  end

  def name_filtered(items, opts)
    rgx = name_regex(opts)
    bd  = opts[:base_dir]
    if bd
      base_dir = bd + File::SEPARATOR unless bd.end_with?(File::SEPARATOR)
      items    = items.select { |i| i.path.start_with?(base_dir) }
    else
      base_dir = ''
    end
    return items.select { |i| i.match(rgx, base_dir) }
  end

  def name_regex(opts)
    name    = opts[:name]
    re      = opts[:re]
    pattern = opts[:pattern]
    nmrgx   = name    ? az_surround(Regexp.quote(name))     :
              pattern ? az_surround(pattern_to_re(pattern)) :
              re      ? re                                  : ''
    return Regexp.new(nmrgx)
  end

  def pattern_to_re(pattern)
    return pattern.gsub(/\*/, '.*').gsub(/\?/, '.')
  end

  def az_surround(s)
    return "\\A#{s}\\z"
  end

  def quantity_limited(items, quant)
    return items[0 .. quant.max_index]
  end

  def add_warning(vid, msg)
    @warnings << "#{vid}: #{msg}"
  end

  def validate
    warn_about_unmatched()
  end

  def report
    validate()
    @warnings.each { |w| puts w }
  end

  def warn_about_unmatched
    @catalog.unmatched_items.each do |item|
      add_warning('EXTRA', item.path)
    end
  end

end
