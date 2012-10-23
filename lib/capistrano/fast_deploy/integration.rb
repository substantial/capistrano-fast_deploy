require 'capistrano'

module Capistrano
  module FastDeploy
    module Integration
      def self.load_into(capistrano_config)
        capistrano_config.load do
          set(:latest_release)  { fetch(:current_path) }
          set(:release_path)    { fetch(:current_path) }
          set(:current_release) { fetch(:current_path) }

          set(:releases_path) { fetch(:current_path) }

          set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
          set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
          set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

          set :cleanup_targets, %w(log public/system tmp)
          set :release_directories, %w(log tmp)
          set :shared_symlinks, {
            'system' => 'public/system',
            'log' => 'log',
            'pids' => 'tmp/pids'
          }

          namespace :deploy do
            def git_reset(ref)
              update_command = []
              update_command << "if [ ! -d \"#{current_path}/.git\" ]; then git clone -q #{repository} #{current_path}; fi"
              update_command << "cd #{current_path}"
              update_command << ["git fetch -q origin && git reset --hard #{ref}"]
              update_command << "git rev-parse --verify HEAD > #{current_path}/REVISION"
              run update_command.join(' && ')
            end

            desc "Update the deployed code."
            task :update_code, :except => { :no_release => true } do
              git_reset(branch)

              on_rollback do
                git_reset("HEAD@{1}")
                finalize_update
                rollback.cleanup
              end

              finalize_update
            end

            desc "This is a no-op when fast_deploy is in use"
            task :create_symlink do
            end

            task :finalize_update, :except => { :no_release => true } do
              commands = []
              commands << "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

              # mkdir -p is making sure that the directories are there for some SCM's that don't
              # save empty folders
              shared_children.map do |d|
                if (d.rindex('/')) then
                  commands << "rm -rf #{latest_release}/#{d} && mkdir -p #{latest_release}/#{d.slice(0..(d.rindex('/')))}"
                else
                  commands << "rm -rf #{latest_release}/#{d}"
                end
                commands << "ln -s #{shared_path}/#{d.split('/').last} #{latest_release}/#{d}"
              end

              run commands.join(" && ")

              if fetch(:normalize_asset_timestamps, true)
                stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
                asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
                run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
              end
            end

            namespace :rollback do
              desc "Moves the repo back to the previous version of HEAD"
              task :repo, :except => { :no_release => true } do
                set :branch, "HEAD@{1}"
                deploy.default
              end

              desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
              task :cleanup, :except => { :no_release => true } do
                run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
              end

              desc "Rolls back to the previously deployed version."
              task :default do
                rollback.repo
                rollback.cleanup
              end
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::FastDeploy::Integration.load_into(Capistrano::Configuration.instance)
end
