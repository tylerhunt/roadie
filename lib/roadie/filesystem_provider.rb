module Roadie
  # Asset provider that looks for files on your local filesystem.
  #
  # It will be locked to a specific path and it will not access files above
  # that directory.
  class FilesystemProvider
    # Raised when FilesystemProvider is asked to access a file that lies above
    # the base path.
    class InsecurePathError < Error; end

    include AssetProvider
    attr_reader :path

    def initialize(path = Dir.pwd)
      @path = path
    end

    # @return [Stylesheet, nil]
    def find_stylesheet(name)
      file_path = build_file_path(name)
      if File.exist? file_path
        Stylesheet.new file_path, File.read(file_path)
      end
    end

    # @raise InsecurePathError
    # @return [Stylesheet]
    def find_stylesheet!(name)
      file_path = build_file_path(name)
      if File.exist? file_path
        Stylesheet.new file_path, File.read(file_path)
      else
        clean_name = File.basename file_path
        raise CssNotFound.new(clean_name, %{#{file_path} does not exist. (Original name was "#{name}")})
      end
    end

    private
    def build_file_path(name)
      raise InsecurePathError, name if name.include?("..")
      File.join(@path, name[/^([^?]+)/])
    end
  end
end
