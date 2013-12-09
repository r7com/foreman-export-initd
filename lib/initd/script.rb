class Initd::Script

  attr_reader :daemon, :name, :description, :concurrency

  def templates_dir
    Pathname.new(__FILE__).dirname.dirname.dirname.join('templates')
  end

  def initialize(path, script, args, concurrency, user)
    @path = path
    @daemon = {
        :name => path.basename,
        :script => script,
        :args => args.join(' '),
        :user => user
    }
    @name = @daemon[:name]
    @description = @daemon[:name]
    @concurrency = concurrency
  end

  def content
    template = templates_dir.join('script.erb')
    ERB.new(template.read, nil, '<>').result(binding)
  end

  def export
    FileUtils.mkdir_p(File.dirname(@path))
    File.new(@path, 'w').write(content)
    File.chmod(0755, @path)
  end
end
