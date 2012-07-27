# A Validator has one Catalog, which contains all of the information
# about the Item objects discovered in the Validator.root_dir.
#
# @!visibility private
class DirValidator::Catalog

  FS        = '\\' + File::SEPARATOR
  DOTDIR    = '\.\.?\z'                      # A dotdir is . or .. at end-of-string,
  DOTDIR_RE = / ( \A | #{FS} ) #{DOTDIR} /x  # preceded by start-of-string or file-sep.

  # Takes a validator, because we need to pass the validator down
  # to the Item objects that are created.
  def initialize(validator)
    # The validator and an array of all Items in the Catalog.
    @validator = validator
    @items = nil

    # Two indexes of to boost the performance of the unmatched_items method.
    # Both indexes contain the catalog_id values of an remaining unmatched
    # Items. The catalog_id values also serve as indexes into the @items
    # array. The indexes have the following structure:
    #
    #   @unmatched[Item.catalog_id]          = true
    #   @bdi[Item.base_dir][Item.catalog_id] = true
    #
    # The @bdi index is more fined-grained and thus gives the largest
    # performance boost. For typical uses, calls to unmatched_items()
    # will have a base_dir, so we can use @bdi.
    @unmatched = {}
    @bdi       = {}
  end

  # Returns the discovered Items, loading them if needed.
  def items
    return @items ||= load_items()
  end

  # Scans the Validator.root_dir, creating a new Item for each file/dir
  # found, and adding the Item to the indexes used by the Catalog.
  def load_items
    catalog_id = -1
    @items     = []
    Dir.chdir(@validator.root_path) do
      Dir.glob('**/*', File::FNM_DOTMATCH).each do |path|
        # We want dotfiles, but not the . and .. dirs.
        next if path_is_dot_dir(path)
        # Create the new Item, and give it a unique ID, which is
        # also an index into the @items array.
        catalog_id += 1
        item = DirValidator::Item.new(@validator, path, catalog_id)
        @items << item
        # Add Item to the indexes.
        add_to_index(item)
      end
    end
    return @items
  end

  # Takes a path as a string. Returns true if it's . or .. directory.
  def path_is_dot_dir(path)
    return path =~ DOTDIR_RE ? true : false
  end

  # Takes an Item object and adds it to the Catalog indexes.
  def add_to_index(item)
    cid = item.catalog_id
    dn  = item.dirname2
    @bdi[dn]      ||= {}
    @bdi[dn][cid]   = true
    @unmatched[cid] = true
  end

  # Takes and Item and removes it from the Catalog indexes.
  def delete_from_index(item)
    cid = item.catalog_id
    dn  = item.dirname2
    @bdi[dn].delete(cid)
    @unmatched.delete(cid)
  end

  # Returns unmatched directories from the Catalog.
  def unmatched_dirs(base_dir = nil)
    return unmatched_items(base_dir).select { |i| i.is_dir }
  end

  # Returns unmatched files from the Catalog.
  def unmatched_files(base_dir = nil)
    return unmatched_items(base_dir).select { |i| i.is_file }
  end

  # Returns unmatches files and directories from the Catalog.
  def unmatched_items(base_dir = nil)
    # If a base_dir is given, we'll use the @bdi index. Otherwise,
    # we'll use the @unmatched index. When using @bdi, we also
    # must return [] if @bdi doesn't contain base_dir as a key.
    # We sort the catalog_id values to obtain a deterministic ordering.
    itms = items()
    h    = base_dir ? @bdi[base_dir] : @unmatched
    return [] unless h
    return h.keys.sort.map { |cid| itms[cid] }
  end

  # Takes an array of Items. Marks them as matched and removes them
  # from the Catalog indexes. We can't do this within unmatched_items()
  # because we don't know that time which of the returned Items will
  # survive the validation-methods name-filtering and quantity-filtering
  # criteria.
  def mark_as_matched(matched_items)
    matched_items.each do |i|
      i.mark_as_matched
      delete_from_index(i)
    end
  end

end
