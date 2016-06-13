### Notice

####I'm looking for a new maintainer for this project. I have not been a good steward and it seems to be useful to people. Any takers?


### Overview

[Foreman](https://github.com/ddollar/foreman) is a gem released by Heroku that allows you to easily manage multiple processes with a Procfile. It ensures all processes launch successfully, colorizes output, and allows you to kill all processes with a simple CTL+C. It's simple and elegant.

Its not perfect however. For one, it doesn't handle running processes from a different directory. It also doesn't deal well with the complexity of running processes under a different RVM. You are probably thinking, "well, those aren't really Foreman's responsibilities". I agree with you. This gem fills that gap.

### Usage

```
gem install subcontractor
```

or with bundler

```ruby
gem 'subcontractor', '0.8.0'
```

The gem provides an executable called ```subcontract``` that you will use from your Procfile. You can see what it does by running ```subcontract --help```

```
USAGE: subcontract [options] -- executable
    -r, --rvm RVM                    run in a specific RVM (use `.` for ruby from `PATH`)
    -b, --rbenv RBENV                run in a specific RBENV (use `.` for local rbenv)
    -h, --chruby CHRUBY              run in a specific CHRUBY
    -c, --choose-env ENV             run in either a specified RBENV, RVM or CHRUBY, whichever is present
    -d, --chdir PATH                 chdir to PATH before starting process
    -s, --signal SIGNAL              signal to send to process to kill it, default TERM
```

An example Procfile tells the story

```
rails: rails s
another_app: subcontract --rvm ruby-1.8.7-p249@another_app --chdir ../another_app --signal INT -- rails s -p 3001
```

Here another_app will be launch from the sibling directory another_app and will use the rvm ruby-1.8.7-p249@another_app. As you can see, the command that we wish to use to launch our application follows the double dashes (--).

You can also allow another_app to use its existing .rvmrc file. This will load the .rvmrc file out of the current folder once it has been changed to the folder specified by --chdir

```
rails: rails s
another_app: subcontract --rvm . --chdir ../another_app --signal INT -- rails s -p 3001
```

You can use specific rbenv version.

```
rbenv_app: bundle exec subcontract --rbenv 'ree-1.8.7-2012.02' --chdir ~/rbenv_app -- bundle exec rails server -p 3001
```

Or you can use whatever the local rbenv settings are for a project. This will load whatever `rbenv local` returns out of the current folder once it has been changed to the folder specified by --chdir

```
rbenv_app: bundle exec subcontract --rbenv . --chdir ~/rbenv_app -- bundle exec rails server -p 3001
```

If you have team members using both rvm and rbenv on a project then use --choose-env to use whatever version manager is present on the system. If both are present rbenv is chosen.

```
mixed_env_manager_app: bundle exec subcontract --choose-env . --chdir ~/mixed_env_manager_app -- bundle exec rails server -p 3001
```


### Contributions
* Fork the project
* Make your change
* Add your name and contact info the the Contributors section below
* Send a pull request (bonus points for feature branches)

### Contributors
* Tony Pitluga [github](http://github.com/pitluga) [blog](http://tony.pitluga.com/) [twitter](http://twitter.com/pitluga)
* Drew Olson [github](http://github.com/drewolson) [blog](http://fingernailsinoatmeal.com/) [twitter](http://twitter.com/drewolson)
* Paul Gross [github](http://github.com/pgr0ss) [blog](http://www.pgrs.net) [twitter](http://twitter.com/pgr0ss)
* Rune Skjoldborg Madsen [github](https://github.com/runemadsen)
* Masahiro Ihara [github](http://github.com/ihara2525) [twitter](http://twitter.com/ihara2525)
* Michael Nussbaum [github](https://github.com/mnussbaum)
