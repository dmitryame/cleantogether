set :application, "cleantogether"

default_run_options[:pty] = true

# ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :runner, nil
# set :git_shallow_clone, 1

# set :deploy_to, "/u/apps/#{application}"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# this is a public repository, is used in readonly mode. The only way to change something in prod is through doing another prod deploy
set :repository,  "git://github.com/dmitryame/cleantogether.git" 
set :scm, "git"

#set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"

# set :scm_passphrase, "p@ssw0rd" #This is your custom users password
set :user, "deployer"

role :app, "cleantogether.com"
role :web, "cleantogether.com"
role :db,  "cleantogether.com", :primary => true


namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  
  
  task :copy_prod_configuration do
    run "cp /u/config/#{application}/database.yml #{release_path}/config/"
    run "cp /u/config/#{application}/environment.rb #{release_path}/config/"
  end
  
  after "deploy:update_code", "deploy:copy_prod_configuration"
end
