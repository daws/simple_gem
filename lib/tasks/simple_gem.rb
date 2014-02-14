require 'rubygems/package'

module SimpleGem
  class << self

    attr_writer :current_version, :current_gemspec

    def current_version
      if !@current_version
        raise 'must define SimpleGem.current_version'
      end
      @current_version
    end

    def current_gemspec
      if !@current_gemspec
        raise 'must define SimpleGem.current_gemspec'
      end
      @current_gemspec
    end

    def safe_create_dir(dir_name)
      if File.exists?(dir_name)
        raise "#{dir_name} is not a directory" unless File.directory?(dir_name)
      else
        Dir.mkdir dir_name
        puts "* created directory #{dir_name}"
      end
    end

    def build_gem(target_dir)
      print "Do you want to build version #{current_version} (y/n): "
      input = STDIN.gets.strip
    
      if input.downcase.start_with? 'y'
        safe_create_dir(target_dir)
        spec = Gem::Specification.load(current_gemspec)
        spec.version = current_version
        gem_file = Gem::Package.build(spec)
        target_file = "#{target_dir}/#{gem_file}"
        File.rename gem_file, target_file
        puts "Successfully built #{gem_file} into #{target_dir}"
        [ current_version, target_file ]
      else
        puts %q{Aborting... update version file and run "rake build" again.}
        exit
      end
    end
    
    def build_production_gem
      if !`git status -s`.strip.empty?
        print 'There are uncommitted changes in the tree... are you sure you want to continue (y/n): '
        response = STDIN.gets.strip
        if !response.downcase.start_with? 'y'
          puts 'Build aborted'
          exit
        end
      end
    
      build_gem 'gems'
    end

    def tag(version)
      version ||= current_version
      `git tag #{version}`.strip
    end

  end
end

desc 'Builds a gemfile for production (into gems/)'
task :build do
  SimpleGem.build_production_gem
end

desc 'Builds a gemfile for development (into gems_dev/)'
task :build_dev do
  current_version = SimpleGem.current_version
  SimpleGem.current_version = "#{current_version}.#{Time.now.to_i}"
  SimpleGem.build_gem 'gems_dev'
  SimpleGem.current_version = current_version
end

desc 'Creates a git tag with the given version'
task :tag, :version do |t, args|
  SimpleGem.tag(args[:version])
end

