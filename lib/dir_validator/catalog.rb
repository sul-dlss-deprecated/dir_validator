class DirValidator::Catalog

  FS        = '\\' + File::SEPARATOR
  DOTDIR    = '\.\.?\z'                      # A dotdir is . or .. at end-of-string,
  DOTDIR_RE = / ( \A | #{FS} ) #{DOTDIR} /x  # preceded by start-of-string or file-sep.

  attr_accessor(:validator)

  def initialize(validator)
    @validator = validator
    @items     = nil
    @unmatched = {}    # Unmatched Items, with Item.catalog_id as the keys.
  end

  def items
    return @items ||= load_items()
  end

  def load_items
    catalog_id = -1
    @items     = []
    Dir.chdir(@validator.root_path) do
      Dir.glob('**/*', File::FNM_DOTMATCH).each do |path|
        next if path_is_dot_dir(path)
        catalog_id += 1
        i = DirValidator::Item.new(@validator, path, catalog_id)
        @items << i
        @unmatched[i.catalog_id] = true
      end
    end
    return @items
  end

  def path_is_dot_dir(path)
    return path =~ DOTDIR_RE ? true : false
  end

  def unmatched_items
    its = items()
    return @unmatched.keys.sort.map { |cid| its[cid] }
  end

  def unmatched_dirs
    return unmatched_items.select { |i| i.is_dir }
  end

  def unmatched_files
    return unmatched_items.select { |i| i.is_file }
  end

  def mark_as_matched(items)
    items.each do |i|
      i.matched = true
      @unmatched.delete(i.catalog_id)
    end
  end

end
