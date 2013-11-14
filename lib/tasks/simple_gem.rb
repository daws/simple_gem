require 'rspec/core/rake_task'
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
      print "Do you want to build version #{current_version} (Y/n): "
      input = STDIN.gets.strip
    
      if input.to_s[0,1] == 'Y'
        safe_create_dir(target_dir)
        spec = Gem::Specification.load(current_gemspec)
        spec.version = current_version
        gem_file = Gem::Package.build(spec)
        target_file = "#{target_dir}/#{gem_file}"
        File.rename gem_file, target_file
        puts "Successfully built #{gem_file} into #{target_dir}"
        [ current_version, target_file ]
      else
        raise %q{Aborting... update version file and run "rake build" again.}
      end
    end
    
    def build_production_gem
      if !`git status -s`.strip.empty?
        raise 'There are uncommitted changes in the tree - commit before building'
      end
    
      build_gem 'gems'
    end

    def tag(version)
      version ||= current_version
      `git tag #{version}`.strip
    end

  end
end

task :default => [ :spec ]

RSpec::Core::RakeTask.new(:spec)

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

