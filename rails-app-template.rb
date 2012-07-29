
 # foreman for managing external processes and environment variables
gem "foreman", "~> 0.49.0"
create_file ".env.example"
create_file ".env"
append_file ".gitignore", "\n/.env"
prepend_file "config/environment.rb", "$stdout.sync = true\n"
create_file "Procfile.development", <<-EOS
web:    bin/rails s thin
guard:  bin/guard
EOS

gem_group :development do
  # thin webserver
  gem "thin", "~> 1.4.1"

  # marginalia adds better sql logging
  gem "marginalia", "~> 1.1.0"
  append_file "config/application.rb", "\nrequire 'marginalia/railtie'"

  # sextant lets you view routes in a browser
  # FIXME: remove this in rails 4 as the feature will be built in
  gem "sextant", "~> 0.1.3"

  # silence asset noise in log file
  gem "quiet_assets", "~> 1.0.1"

  # guard for automating filewatchers
  gem "guard", "~> 1.2.3"
  gem "guard-rspec", "~> 1.2.0"
  gem "guard-cucumber", "~> 1.2.0"
  gem "ruby_gntp", "~> 0.3.4" # growl notifier
end

gem_group :development, :test do
  # rspec test framework
  gem "rspec-rails", "~> 2.11.0"
end

gem_group :test do
  # cucumber test framework and friends
  gem "cucumber-rails", "~> 1.3.0"
  gem "database_cleaner", "~> 0.8.0"
  gem "launchy", "~> 2.1.1"
  gem "capybara", "~> 1.1.2"
end

# bundle it and generate binstubs
run "bundle install --binstubs --without production"

# post-bundle steps
generate "rspec:install"
generate "cucumber:install"
run "bin/guard init rspec"
run "bin/guard init cucumber"

# clean up default files
remove_file "public/index.html"
remove_file "app/assets/images/rails.png"

# generate markdown-formatted readme
remove_file "README.rdoc"
create_file "README.mdown", <<-EOS
# Running

1. edit `config/database.yml` as needed
2. add any environment variables to `.env`
3. run `bin/foreman start -f Procfile.development`
EOS

# create sample database configuration and exclude from source control
run "cp config/database.yml config/database.example.yml"
append_file ".gitignore", "\n/config/database.yml"

# first time setup (cold boot)
run "bin/rake db:migrate"
run "bin/rake db:seed"
run "bin/rake db:test:prepare"

# intialize git and commit all the things
git :init
git add: "."
git commit: "-am 'initial commit, applied template to stock app'"
