class DirValidator::Catalog

  DOTDIR    = '\.\.?'
  DOTDIR_RE = / \A#{DOTDIR}\z | #{DOTDIR}\z /x

  attr_accessor(
    :validator)

  def initialize(validator)
    @validator = validator
    @items     = nil
  end

  def items
    @items ||= load_items()
  end

  def load_items
    @items = []
    Dir.chdir(@validator.root_path) do
      Dir.glob('**/*', File::FNM_DOTMATCH).each do |path|
        next if path_is_dot_dir(path)
        @items << DirValidator::Item.new(@validator, path)
      end
    end
    return @items
  end

  def path_is_dot_dir(path)
    return path =~ DOTDIR_RE
  end

  def unmatched_items
    return items.reject { |i| i.matched }
  end

  def unmatched_dirs
    return dirs.reject { |i| i.matched }
  end

  def unmatched_files
    return files.reject { |i| i.matched }
  end

  def dirs
    return items.select { |i| i.is_dir }
  end

  def files
    return items.select { |i| i.is_file }
  end

end
