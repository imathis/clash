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

## CLI

```
$ clash [dir] [tests] [options]          # Run tests
$ clash accept [dir] [tests] [options]   # Accept build: overwrite expected files with build files
$ clash new [path] [options]             # Add testing scaffold to or a new test site to [path] (defaults to `./test`)
```

### CLI options
  
```
-b, --build             Build mode: Runs only 'before' and 'build' actions
-c, --context NUMBER    On diff errors, show NUMBER of lines of surrounding context (default: 2)
-l, --list              Print a list of tests' numbers and titles (does not run tests)
-t, --trace             Display output from system commands in tests
-h, --help              Show help message
```

## The Clash file

A simple clash file with one test might look like this:

```
- 
  title: Test Build           # Name for your test
  dir: site                   # Dir containing your Jekyll test site
  build: true                 # Run Jekyll build
  compare: _expected _site    # Compare the contents of _expected/ to _site/
```

A clash test can be configured with the following options. Each of these is optional.

| Option           | Type           | Description                                                |
|:-----------------|:---------------|:-----------------------------------------------------------|
| title            | String         | A descriptive name for the test                            |
| dir              | String         | Scope tests to this directory.                             |
| before           | String/Array   | Run system command(s) before running tests.                |
| build            | Boolean        | Build the site with Jekyll.                                |
| config           | Hash           | Configure Jekyll, Octopress Ink plugins. (Info below)      |
| compare          | String/Array   | Compare files or directories. Format: "_expected _site"    |
| after            | String/Array   | Run system command(s) after running tests.                 |
| enforce_missing  | String/Array   | Ensure that these files are not found.                     |

Note: Above, String/Array means a configuration can accept either, for example:

```yaml
compare: _expected _site                     # Compare two directories
compare:                                     # Compare multiple items
  - _expected/index.html _site/index.html
  - _expected/atom.xml _site/atom.xml
  - _expected/posts _site/posts
```

The order, `expected` file before `site` file is important as it affects the readout of the diff when there are failures.

### Examples

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
$ clash awesome       # Run all tests in the 'awesome' directory, reading awesome/_clash.yml.
$ clash awesome 1     # Run the first test in the 'awesome' directory.
```

## Get Started

Here's how you can get started testing Jekyll plugins with Clash. First generate a testing scaffold.

```
$ clash new test  # Add a new clash testing scaffold to the `test` directory.
```

This will generate the following:

```
test/
  _clash.yml                 # Clash configuration file
  site/                      # Directory containing a Jekyll site 
    _config.yml              # Jekyll configuration
    _expected/               
      index.html             # File containing expected result
    index.html               # Source file for testing your plugin
```

And here is what your `_clash.yml` will look like:

```
- 
  title: Test Build           # Name for your test
  dir: site                   # Dir containing your Jekyll test site
  build: true                 # Run Jekyll build
  compare: _expected _site    # Compare the contents of _expected/ to _site/
```

Next add your plugin to the Jekyll test site and add a sample usage to the `index.html` file. You can build your site like this:

```
$ clash --build  # trigger a jekyll build
```

And once you're ready to go, run your test like this.

```
$ clash    # run tests
```

Unless you've already modified your expected files, this will fail, printing a diff of `_expected/index.html` and the build file `_site/index.html`.
You can accept the build result and copy it over the expected files like this:

```
$ clash accept   # Copy _site/ files to _expected/
```

Now when you run `$ clash` your tests will pass.

This example illustrated a simple test scenario, but Clash can also:

- Run tasks before and after tests. (Good for setup and cleanup)
- Test multiple sites.
- Test the same site multiple times using different Jekyll configurations.
- Compare single files or entire directories.

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
    - _config_a.yml
```

Here `_config_a.yml` will override settings in `_config.yml` when the site is built.

### Test Octopress Ink plugin configurations

If you are developing an Octopress Ink plugin with the slug `awesome-sauce` you can configure it by by using the config hash. Here's an example:

```
config:
  awesome-sauce: _awesome-sauce.yml  # any file name works
```

This will copy `site/_awesome-sauce.yml` to your plugin's configuration path at `site/_plugins/awesome-sauce/config.yml`. If there is already a configuration file in that location, it will be backed up and then restored after tests.


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
