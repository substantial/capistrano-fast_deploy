# Capistrano::FastDeploy

A couple Capistrano tweaks to speed up deploys:

* All changes occur in `current` folder, git clones directly to this
  folder and uses `reset` to deploy.
* Symlinks in `deploy:finalize_update` all happen in one ssh connection
* Rollback uses git as well

This overrides the following default capistrano tasks:

* `deploy:update_cod` - Uses `git reset` instead of the standard
  `:scm` and `:deploy_via`providers.
* `deploy:finalize_update` - Concatenates all symlink commands from
  `shared_children into a single ssh command. Also adds support for
  `mapped_shared_children` so you can add additional symlinks like this:

```ruby
set :mapped_shared_children, {
  'config/database.yml' => 'config/database.yml'
}
```
* `deploy:create_symlink` - This is now a no-op, there are no longer
  individual release directories.
* `deploy:rollback`, `deploy:rollback:repo`, `deploy:rollback:cleanup` -
  Goes back to the previous place that `HEAD`
  was pointing (`HEAD@{1}`). You don't want to do this if you go and
  monkey around with your `current` folder manually.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-fast_deploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-fast_deploy

## Usage

Add the following to your deploy.rb:

```ruby
require 'capistrano/fast_deploy'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Attribution

* http://ariejan.net/2011/09/14/lighting-fast-zero-downtime-deployments-with-git-capistrano-nginx-and-unicorn
* https://github.com/blog/470-deployment-script-spring-cleaning
