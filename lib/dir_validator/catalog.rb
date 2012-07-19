class DirValidator::Catalog

  FS        = '\\' + File::SEPARATOR
  DOTDIR    = '\.\.?\z'                      # A dotdir is . or .. at end-of-string,
  DOTDIR_RE = / ( \A | #{FS} ) #{DOTDIR} /x  # preceded by start-of-string or file-sep.

  def initialize(validator)
    @validator = validator
    @items     = nil
    @unmatched = {}  # Index of unmatched Items, keyed using Item.catalog_id.
    @bdi       = {}  # Index of Items, keyed using Item.base_dir.
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
        item = DirValidator::Item.new(@validator, path, catalog_id)
        @items << item
        add_to_index(item)
      end
    end
    return @items
  end

  def path_is_dot_dir(path)
    return path =~ DOTDIR_RE ? true : false
  end

  def unmatched_items(base_dir = nil)
    all_items = items()
    return @unmatched.keys.sort.map { |i| all_items[i] } unless base_dir
    return [] unless @bdi[base_dir]
    return @bdi[base_dir].keys.sort.map { |i| all_items[i] }.reject { |item| item.matched }
  end

  def unmatched_dirs(base_dir = nil)
    return unmatched_items(base_dir).select { |i| i.is_dir }
  end

  def unmatched_files(base_dir = nil)
    return unmatched_items(base_dir).select { |i| i.is_file }
  end

  def mark_as_matched(matched_items)
    matched_items.each do |i|
      i.mark_as_matched
      delete_from_index(i)
    end
  end

  def add_to_index(item)
    cid = item.catalog_id
    dn  = item.dirname2
    @bdi[dn] = {} unless @bdi[dn]
    @bdi[dn][cid]   = true
    @unmatched[cid] = true
  end

  def delete_from_index(item)
    cid = item.catalog_id
    dn  = item.dirname2
    @bdi[dn].delete(cid)
    @unmatched.delete(cid)
  end

end
