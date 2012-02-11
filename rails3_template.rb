# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

@recipes = [ "slim", "rspec", "authlogic", "seed_database", "cleanup", "ban_spiders", "git"]

def recipes;
  @recipes
end

def recipe?(name)
  ; @recipes.include?(name)
end

def say_custom(tag, text)
  ; say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}"
end

def say_recipe(name)
  ; say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..."
end

def say_wizard(text)
  ; say_custom(@current_recipe || 'wizard', text)
end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || "prompt").rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question)
  ; !yes_wizard?(question)
end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice, i|
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard("Enter your selection:") while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []

def after_bundler(&block)
  ; @after_blocks << [@current_recipe, block];
end

@after_everything_blocks = []

def after_everything(&block)
  ; @after_everything_blocks << [@current_recipe, block];
end

@before_configs = {}

def before_config(&block)
  ; @before_configs[@current_recipe] = block;
end


say_wizard "Checking configuration. Please confirm your preferences."

# >------------------------[ Get default Gemfile ]---------------------------------<

get "https://raw.github.com/sylow/Rails-3-App-Templates/master/Gemfile", "Gemfile"


# >---------------------------------[ AUTHLOGIC ]----------------------------------<

@current_recipe = "authlogic"
@before_configs["authlogic"].call if @before_configs["authlogic"]
say_recipe 'authlogic'

config = {}
config['authlogic'] = yes_wizard?("Would you like to use authlogic?") if true && true unless config.key?('authlogic')
@configs[@current_recipe] = config


if config['authlogic']
  gem 'authlogic'
  gem 'acl9'
else
  recipes.delete('authlogic')
end

# >---------------------------------[ RSpec ]---------------------------------<

after_bundler do
  say_wizard "RSpec recipe running 'after bundler'"
  generate 'rspec:install'

  say_wizard "Removing test folder (not needed for RSpec)"
  run 'rm -rf test/'

  inject_into_file 'config/application.rb', :after => "Rails::Application\n" do
    <<-RUBY

  # don't generate RSpec tests for views and helpers
  config.generators do |g|
    g.view_specs false
    g.helper_specs false
  end

    RUBY
  end
end

# >---------------------------[ ApplicationLayout ]---------------------------<

@current_recipe = "application_layout"
@before_configs["application_layout"].call if @before_configs["application_layout"]
say_recipe 'ApplicationLayout'


@configs[@current_recipe] = config

# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/application_layout.rb

after_bundler do

  say_wizard "ApplicationLayout recipe running 'after bundler'"

  # Set up the default application layout
  if recipes.include? 'slim'
    remove_file 'app/views/layouts/application.html.erb'
    # There is Haml code in this script. Changing the indentation is perilous between HAMLs.
    create_file 'app/views/layouts/application.html.slim' do
      <<-SLIM
doctype html
html
  head
    title Application
    meta name="keywords" content="new app"

  body
    div id="content" class="example1"
      p Nest by indentation

      == yield

    div id="footer"
      | Copyright © 2012 sylow

      SLIM
    end
  end
end

# >--------------------------------[ Twitter Bootstrap ]----------------------<

gem 'twitter-bootstrap-rails'


# >--------------------------------[ Cleanup ]--------------------------------<

@current_recipe = "cleanup"
@before_configs["cleanup"].call if @before_configs["cleanup"]
say_recipe 'Cleanup'


@configs[@current_recipe] = config

# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/cleanup.rb

after_bundler do

  say_wizard "Cleanup recipe running 'after bundler'"

  # remove unnecessary files
  %w{
    README
    doc/README_FOR_APP
    public/index.html
    public/images/rails.png
  }.each { |file| remove_file file }

  # add placeholder READMEs
  get "https://github.com/fortuity/rails-template-recipes/raw/master/sample_readme.txt", "README"
  get "https://github.com/fortuity/rails-template-recipes/raw/master/sample_readme.textile", "README.textile"
  gsub_file "README", /App_Name/, "#{app_name.humanize.titleize}"
  gsub_file "README.textile", /App_Name/, "#{app_name.humanize.titleize}"

  # remove commented lines from Gemfile
  # thanks to https://github.com/perfectline/template-bucket/blob/master/cleanup.rb
  gsub_file "Gemfile", /#.*\n/, "\n"
  gsub_file "Gemfile", /\n+/, "\n"

end


# >------------------------------[ BanSpiders ]-------------------------------<

@current_recipe = "ban_spiders"
@before_configs["ban_spiders"].call if @before_configs["ban_spiders"]
say_recipe 'BanSpiders'

config = {}
config['ban_spiders'] = yes_wizard?("Would you like to set a robots.txt file to ban spiders?") if true && true unless config.key?('ban_spiders')
@configs[@current_recipe] = config

# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/ban_spiders.rb

if config['ban_spiders']
  say_wizard "BanSpiders recipe running 'after bundler'"
  after_bundler do
    # ban spiders from your site by changing robots.txt
    gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
    gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'
  end
else
  recipes.delete('ban_spiders')
end


# >----------------------------------[ Git ]----------------------------------<

@current_recipe = "git"
@before_configs["git"].call if @before_configs["git"]
say_recipe 'Git'


@configs[@current_recipe] = config

# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/git.rb

after_everything do

  say_wizard "Git recipe running 'after everything'"

  # Git should ignore some files
  remove_file '.gitignore'
  get "https://github.com/fortuity/rails3-gitignore/raw/master/gitignore.txt", ".gitignore"


  # Initialize new Git repo
  git :init
  git :add => '.'
  git :commit => "-aqm 'new Rails app initialized'"
  # Create a git branch
  git :checkout => ' -b working_branch'
  git :add => '.'
  git :commit => "-m 'Initial commit of working_branch'"
end


@current_recipe = nil

# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running 'bundle install'. This will take a while."
run 'bundle install'
say_wizard "Running 'after bundler' callbacks."
@after_blocks.each { |b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call }

@current_recipe = nil
say_wizard "Running 'after everything' callbacks."
@after_everything_blocks.each { |b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call }

@current_recipe = nil
say_wizard "Finished running the app template."
say_wizard "Your new Rails app is ready. Any problems?"
