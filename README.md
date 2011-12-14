### Overview

[Foreman](https://github.com/ddollar/foreman) is a gem released by Heroku that allows you to easily manage multiple processes with a Procfile. It ensures all processes launch successfully, colorizes output, and allows you to kill all processes with a simple CTL+C. It's simple and elegant.

Its not perfect however. For one, it doesn't handle running processes from a different directory. It also doesn't deal well with the complexity of running processes under a different RVM. You are probably thinking, "well, those aren't really Foreman's responsibilities". I agree with you. This gem fills that gap.

### Usage

```
gem install subcontractor
```

or with bundler

```ruby
gem 'subcontractor', '0.1.0'
```

The gem provides an executable called ```subcontract``` that you will use from your Procfile. You can see what it does by running ```subcontract --help```

```
USAGE: subcontract [options] -- executable
    -r, --rvm RVM                    run in a specific RVM
    -d, --chdir PATH                 chdir to PATH before starting process
    -s, --signal SIGNAL              signal to send to process to kill it, default TERM
```

An example Procfile tells the story

```
rails: rails s
another_app: subcontract --rvm ruby-1.8.7-p249@another_app --chdir ../another_app --signal INT -- rails s -p 3001
```

Here another_app will be launch from the sibling directory another_app and will use the rvm ruby-1.8.7-p249@another_app. As you can see, the command that we wish to use to launch our application follows the double dashes (--).

You can also allow another_app to use its existing .rvmrc file

```
rails: rails s
another_app: subcontract --rvm "--with-rubies rvmrc" --chdir ../another_app --signal INT -- rails s -p 3001
```

### Contributions
* Fork the project
* Make your change
* Add your name and contact info the the Contributors section below
* Send a pull request (bonus points for feature branches)

### Contributors
* Tony Pitluga [github](http://github.com/pitluga) [twitter](http://twitter.com/pitluga)
