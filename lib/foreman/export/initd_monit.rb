require 'foreman-export-initd'

class Foreman::Export::InitdMonit < Foreman::Export::Base

  def export_path
    Pathname.new location
  end

  def setup
    @exported = []
    say "creating: #{export_path}"
    FileUtils.mkdir_p(export_path)
  end

  def cleanup
    Dir.glob export_path.join("#{app}-*") do |filename|
      contents = File.new(filename, 'r').read
      next unless contents.match(/# Autogenerated by foreman/)
      next if @exported.include? filename.to_s
      say 'removing ' + filename
      File.unlink filename
    end
  end

  def export_file (path, contents)
    write_file(path, contents)
    File.chmod(0755, path)
    @exported.push path.to_s
  end

  def concurrency(name)
    engine.formation[name]
  end

  def path(name)
    export_path.join("#{app}-#{name}")
  end

  def export
    error('Must specify a location') unless location

    setup
    engine.each_process do |name, process|
      concurrency = concurrency name
      path = path name
      if concurrency > 0
        say 'Warning: Initd exporter ignores concurrency > 1' if concurrency > 1
        contents = Initd::MonitConfig.new(app, path).content
        export_file path, contents
      end
    end
    cleanup
  end
end
