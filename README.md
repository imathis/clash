# Clash

Clash is an integration test framework designed for Jekyll developers. It helps you create Jekyll test sites, then build and compare them an expected result.

[![Build Status](https://travis-ci.org/imathis/clash.svg)](https://travis-ci.org/imathis/clash)
[![Gem Version](http://img.shields.io/gem/v/clash.svg)](https://rubygems.org/gems/clash)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://imathis.mit-license.org)

## Installation

Add this line to your Gemfile:

    gem 'clash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clash

## Overview

Here's what it looks like to test Jekyll plugins with Clash.

1. Run `$ clash init test` to generate the testing scaffold.
2. Add use-cases to the test site.
3. Run `$ clash test --build` and review the generated site.
4. If everything looks correct, copy site files to the `_expected` directory.
5. Run `$ clash test` and Clash will compare `_site/` to `_expected/`.
6. **Code with confidence!**

This example illustrates a simple test scenario, but Clash can also:

- Run tasks before and after tests. (Good for setup and cleanup)
- Test multiple sites.
- Test the same site multiple times using different Jekyll configurations.
- Compare single files or entire directories.

## Running tests

```
$ clash [path] [tests] [options]
```

To run only specific tests, pass test numbers separated by commas.

```
$ clash          # Run all tests.
$ clash 1        # Run only the first test.
$ clash 2,3      # Run the second and third tests.
$ clash 2-4      # Run the second, third, and fourth tests
$ clash :10      # Run the test on line 10
$ clash :10-:35  # Run all tests from line 10 to 35
```

Typically the clash file is kept in the same directory as the tests. If you are in that directory, you can run `$ clash` and it will run
as usual. If you're not, you'll need to pass the directory to the tests.

```
$ clash test     # Run all tests in the 'test' directory, reading test/_clash.yml.
$ clash test 1   # Run the first test in the 'test' directory.
```

### CLI options
  
```
-f, --file FILE         Use a specific test file (default: _clash.yml)
-b, --build             Build mode: Runs only 'before' and 'build' actions.
-l, --list              Print a list of tests' numbers and titles (does not run tests)
-c, --context NUMBER    On diff errors, show NUMBER of lines of surrounding context (default: 2)
-d, --debug             Display output from system commands in tests
-h, --help              Show this message
```

## Testing scaffold

To get started, you can add a test scaffold with the `init` command.

```
$ clash init [path] [--force]
```

Run `$ clash init test` to generate a testing scaffold in the `test` directory. Here's what it looks like:

```
test/
  _clash.yml        # Clash configuration file
  site/             # Directory containing a Jekyll site 
    _config.yml     # Jekyll configuration
    _expected       # Build comparison directory
      index.html    # File to compare
    index.html      # Source file for testing your site
```

The `_clash.yml` file contains a simple test which looks like this.

```
- 
  title: Test Build
  dir: site
  build: true
  compare: _expected _site
```

Now when you run `$ clash` from the test directory Jekyll will build the site and compare
`site/_expected` to `site/_site`, showing any differences between the directories.

Read on to learn about running and configuring tests.

## The Clash file

| Option           | Type           | Description                                              |
|:-----------------|:---------------|:---------------------------------------------------------|
| title            | String         | A descriptive name for the test                          |
| dir              | String         | Scope tests to this directory.
| before           | String/Array   | Run system command(s) before running tests.              |
| build            | Boolean        | Build the site with Jekyll.                              |
| config           | Hash           | Configure Jekyll, Octopress Ink plugins. (Info below)    |
| compare          | String/Array   | Compare files or directories. e.g. "_expected _site"     |
| after            | String/Array   | Run system command(s) after running tests.               |
| enforce_missing  | String/Array   | Ensure that these files are not found.                   |

Note: Above, String/Array means a configuration can accept either, for example:

```yaml
compare: _expected _site                     # Compare two directories
compare:                                     # Compare multiple items
  - _expected/index.html _site/index.html
  - _expected/atom.xml _site/atom.xml
  - _expected/posts _site/posts
```

### Testing multiple use-cases

If you're testing a plugin with multiple use-cases, it's a good idea to create a separate file for each scenario.

```
test/
  site/
    _expected/
    scenario-a.md
    scenario-b.html
    scenario-c.textile
```

### Testing multiple sites

If your plugin has a more complex setup, you can create several test sites and test them independently. Your directory structure might look like this:

```
test/
  site-1/
    _expected/
    index.html
  site-2/
    _expected/
    index.html
```

And your clash file would look like this:

```
- 
  title: Standard site build
  dir: site-1
  build: true
  compare: _expected _site

- 
  title: Check asset compression
  dir: site-2
  build: true
  compare: _expected _site
```

Other than the title, The difference between these two tests is the `dir` config, which changes the test directory for Clash.

### Test a site with multiple configurations.

Sometimes the only difference between your test scenarios is the site configuration. Rather than create two separate sites, Clash can run tests against a single site, using different configurations for each build.

Here's how you'd set up your test site:

```
test/
  site/
    _expected/   # Each cofiguration's comparison files are in nested subdirectories
      default/
      config_a/
      config_b/
    index.html
    _config.yml
    _config_a.yml
    _config_b.yml
```

Because you'll be comparing multiple builds of the same site, instead of keeping comparison files directly under the `_expected` directory, it's a good idea to group them in subdirectories underneath `_expected/`.

Here's how your clash file might look:

```
-
  title: Standard build            # Reads _config.yml file as usual
  dir: site
  build: true
  compare: _expected/default _site

-
  Title: Alternate Configuration A
  build: true
  dir: site
  config:
    jekyll: _config_a.yml          # Build with _config_a.yml
  compare: _expected/config_a _site
-
  Title: Alternate Configuration B
  build: true
  dir: site
  config:
    jekyll: _config_b.yml          # Build with _config_b.yml
  compare: _expected/config_b _site
```

When Clash builds your site with a custom configuration, it uses the command `jekyll build --config _config_a.yml`. You can even use multiple configurations like this.

```
config:
  jekyll:
    - _config.yml
    - _config_alt.yml
```

Here `_config_alt.yml` will override settings in `_config.yml` when the site is built.

### Test Octopress Ink plugin configurations

If you are developing an Octopress Ink plugin with the slug `awesome-sauce` you can configure it by by using the config hash. Here's an example:

```
config:
  awesome-sauce: _config_alt.yml
```

This will copy `site/_config_alt.yml` to your plugin's configuration path at `site/_plugins/awesome-sauce/config.yml`. If there is already a configuration file in that location, it will be backed up and then restored after tests.


## Tasks

If you find yourself adding repetitive before or after commands, you can create a task to reference these commands for reuse in other tests. Here's an example clash config file.

```
-
  tasks:
    reset_site: 
      - rm -rf _site
    remove_caches:
      - rm -rf .gist-cache
      - echo "Gist cache removed"
-
  title: Test build
  before: remove_caches
  build: true
  after: 
    - reset_site
    - echo "Gist build complete"
```

Notice the first test isn't a test at all. It's a hash of tasks, each with its own defined command(s). The test below calls tasks in its before and after blocks. Note that tasks can be used along with any other system command in before or after blocks.


## Contributing

1. Fork it ( https://github.com/imathis/clash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
