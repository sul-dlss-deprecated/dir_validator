class DirValidator::Validator

  attr_accessor(
    :root_path,
    :catalog,
    :warnings)

  FILE_SEP = File::SEPARATOR

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
    # Filter the items to those in the base_dir.
    # If there is no base_dir, no filtering occurs.
    base_dir = normalized_base_dir(opts)
    sz       = base_dir.size
    items    = items.select { |i| i.path.start_with?(base_dir) } if sz > 0

    # Set the item.target values.
    # If there is no base_dir, the target is the same as item.path.
    items.each { |i| i.target = i.path[sz .. -1] }

    # Filter items to immediate children, unless user wants to recurse.
    items = items.reject { |i| i.target.include?(FILE_SEP) } unless opts[:recurse]

    # Return the items having targets matching the name regex.
    rgx = name_regex(opts)
    return items.select { |i| i.target_match(rgx) }
  end

  def normalized_base_dir(opts)
    bd  = opts[:base_dir]
    return '' unless bd
    bd += FILE_SEP unless bd.end_with?(FILE_SEP)
    return bd
  end

  def name_regex(opts)
    name    = opts[:name]
    re      = opts[:re]
    pattern = opts[:pattern]
    return Regexp.new(
      name    ? name_to_re(name)       :
      pattern ? pattern_to_re(pattern) :
      re      ? re                     : ''
    )
  end

  def name_to_re(name)
    return az_wrap(Regexp.quote(name))
  end

  def pattern_to_re(pattern)
    return az_wrap(Regexp.quote(pattern).gsub(/\\\*/, '.*').gsub(/\\\?/, '.'))
  end

  def az_wrap(s)
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
