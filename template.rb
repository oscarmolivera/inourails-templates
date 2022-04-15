# Inspire by the article: https://medium.com/@josisusan/rails-template-9d804bf47fab
# And by : https://github.com/infinum/default_rails_template/blob/master/template.rb
# And by : https://github.com/dao42/rails-template/blob/master/composer.rb
# And by : https://github.com/excid3/jumpstart/blob/master/template.rb

require 'io/console'

# Dir Source for the 3 basic Files
def source_paths
  [__dir__]
end

# Start with my own Gemfile
remove_file 'Gemfile'
copy_file 'Gemfile', 'Gemfile'

# First export DB variables to Environment in .bashrc
db_user = IO::console.getpass '** Database AdminUser Name? : '
db_password = IO::console.getpass ' ** Database AdminUser Password? : '
SECRETS_RB_FILE = <<-HEREDOC.strip_heredoc
  ENV['DATABASE_USERNAME'] = "#{db_user}"
  ENV['DATABASE_PASSWORD'] = "#{db_password}"
  ENV['SOCKET'] = '/var/run/mysqld/mysqld.sock'
HEREDOC
create_file 'config/secrets.rb', SECRETS_RB_FILE, force: true

# The Database YML FILE
DB_CONFIG = <<-HEREDOC.strip_heredoc
  development:
    adapter: mysql2
    encoding: utf8
    pool: 5
    host: localhost
    database: #{app_name}_development
    username: <%= ENV['DATABASE_USERNAME'] %> 
    password: <%= ENV['DATABASE_PASSWORD'] %>
    socket: <%= ENV['SOCKET'] %>
  

  test:
    adapter: mysql2
    encoding: utf8
    pool: 5
    host: localhost
    database: #{app_name}_test
    username: <%= ENV['DATABASE_USERNAME'] %> 
    password: <%= ENV['DATABASE_PASSWORD'] %>
    socket: <%= ENV['SOCKET'] %>
  
HEREDOC
create_file 'config/database.yml', DB_CONFIG, force: true


# Adding Localhost custom environment variables
def localhost_secrets
  content = <<-ENV_CONFIG
  
  # Load the app's custom environment variables here, so that they are loaded before environments/*.rb
  app_environment_variables = File.join(Rails.root, 'config', 'secrets.rb')
  load(app_environment_variables) if File.exist?(app_environment_variables)
  ENV_CONFIG
  insert_into_file 'config/environment.rb', content + "\n", after: "require_relative 'application'"
end


# Custom files
def copy_templates
  remove_file 'app/assets/stylesheets/application.css'
  remove_file '.gitignore'
  copy_file '.gitignore', '.gitignore'
end

after_bundle do
  # Custom local environment variables
  localhost_secrets

  # Adding all the custom files
  copy_templates

  # Migrate
  rails_command 'db:create'
  rails_command 'db:migrate'

  say 'Houston: You are good to go!', :green
  say "Get Inside with: "
  say "$ cd #{app_name}", :yellow
end
