require 'date'
require 'erb'
require 'rubygems/command'
require 'active_support/inflector'

class Gem::Commands::SkeletonCommand < Gem::Command

  def initialize
    super 'skeleton', 'Create the skeleton for a new gem'
  end

  def arguments
    'GEMNAME       name of gem to create a skeleton for'
  end

  def usage
    "#{program_name} GEMNAME"
  end

  def execute
    gem_name = get_all_gem_names[0]
    camelized_gem_name = gem_name.camelize

    # make directory for gem
    if File.exists?(gem_name)
      raise "#{gem_name} directory already exists"
    else
      Dir.mkdir gem_name
    end

    safe_create_dir(File.join(gem_name, 'lib'))
    safe_create_dir(File.join(gem_name, 'lib', gem_name))
    safe_create_dir(File.join(gem_name, 'spec'))

    renderer = TemplateRenderer.new(gem_name)
    renderer.render('gitignore', '.gitignore')
    renderer.render('Gemfile', 'Gemfile')
    renderer.render('README.rdoc', 'README.rdoc')
    renderer.render('CHANGELOG.rdoc', 'CHANGELOG.rdoc')
    renderer.render('LICENSE.txt', 'LICENSE.txt')
    renderer.render('Rakefile', 'Rakefile')
    renderer.render('lib_base.rb', File.join('lib', "#{gem_name}.rb"))
    renderer.render('version.rb', File.join('lib', gem_name, 'version.rb'))
    renderer.render('spec_helper.rb', File.join('spec', 'spec_helper.rb'))
    renderer.render('gemspec', "#{gem_name}.gemspec")

    puts renderer.render('POST_INSTALL_MESSAGE')

  end

  private

  def safe_create_dir(dir_name)
    if File.exists?(dir_name)
      raise "#{dir_name} is not a directory" unless File.directory?(dir_name)
    else
      Dir.mkdir dir_name
    end
  end

  class TemplateRenderer

    attr_reader :gem_name

    def initialize(gem_name)
      @gem_name = gem_name
      @templates_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'templates'))
    end

    def get_binding
      binding
    end

    def render(template, target_file = nil)
      source_text = File.read("#{File.join(@templates_dir, template)}")
      source_object = ERB.new(source_text)
      result = source_object.result(get_binding)

      if target_file
        File.open(File.join(gem_name, target_file), 'w') do |f|
          f.write(result)
        end
      else
        result
      end
    end

  end

end
