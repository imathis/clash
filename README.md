# Clash

Clash is an integration test framework designed for Jekyll developers.

[![Build Status](https://travis-ci.org/imathis/clash.svg)](https://travis-ci.org/imathis/clash)
[![Gem Version](http://img.shields.io/gem/v/clash.svg)](https://rubygems.org/gems/clash)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://imathis.mit-license.org)

## Installation

Add this line to your application's Gemfile:

    gem 'clash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clash

## Example usage:

If you have a simple liquid tag you want to test:

 1. Run `$ clash init test`  which generates a test scaffold.
 2. Modify the Jekyll site in `test/scenario-1` to use your plugin.
 3. Run `$ clash test`, ignore failures, and check that `test/scenario-1/_site` looks right.
 4. Copy `_site` to `_expected`.
 5. Run `$ clash test` and the test will pass.
 6. **Code with confidence!**

## Testing scaffold

To get started, you can add a test scaffold with the `init` command.

```
$ clash init [path] [--force]
```

For example, `$ clash init test` will generate a ready-to-test Jekyll site scaffold in the `test` directory. Here's what it
looks like:

```
test/
  _clash.yml        # Clash test list
  scenario-1/       # Directory containing a Jekyll site 
    _config.yml     # Jekyll configuration
    _expected       # Build comparison directory
      index.html    # File to compare
    index.html      # Source file for testing your site
```

The `_clash.yml` file contains a simple test which looks like this.

```
- 
  title: Test Build
  dir: scenario-1
  build: true
  compare: _expected _site
```

Now when you run `$ clash` from the test directory Jekyll will build the site in `scenario-1` and compare
`scenario-1/_expected` to `scenario-1/_site`, showing any differences between the directories. Now you can just modify the
Jekyll site to use a plugin you are developing and test the output.

Read on to learn about running and configuring tests.

## Usage

```
$ clash [path] [test] [options]
```

To run only specific tests, pass test numbers separated by commas.

```
$ clash test     # Compare files in the 'test' directory
$ clash          # run all tests
$ clash 1        # run only the first test
$ clash 2,3      # run the second and third tests
$ clash test 1   # Run the first test in the 'test' directory.
```

### CLI options
  
```
-f, --file    FILE      Use a specific test file (default: _clash.yml)
-c, --context NUMBER    On diff errors, show NUMBER of lines of surrounding context (default: 2)
-l, --list              Print a list of tests' numbers and titles (does not run tests)
-d, --debug             Display output from system commands in tests
-h, --help              Show this message
```

Clash reads its configuration from a _clash.yml file. Use the --file
option to choose a different configuration file.

## Clash file configuration

| Option           | Type           | Description                                              |
|:-----------------|:---------------|:---------------------------------------------------------|
| title            | String         | Include a descriptive name with test output.             |
| before           | String/Array   | Run system command(s) before running tests.              |
| build            | Boolean        | Build the site with Jekyll.                              |
| config           | Hash           | Configure Jekyll, Octopress or Ink plugins. (Info below) |
| compare          | String/Array   | Compare files or directories. e.g. "a.md b.md"           |
| enforce_missing  | String/Array   | Ensure that these files are not found.                   |
| after            | String/Array   | Run system command(s) after running tests.               |

Note: in the table above, String/Array means a single argument can be a string, but mutliples
can be passed as an array. For example:

```yaml
compare: _expected _site                     # Compare two directories
compare:                                     # Compare multiple items
  - _expected/index.html _site/index.html
  - _expected/atom.xml _site/atom.xml
  - _expected/posts _site/posts
```

To run multiple tests each test should be an array, for example:

```
-
  title: Check site build
  build: true
  compare: _expected _site
-
  title: Check asset compression
  compare: _cdn_expected _cdn_build
```

Note: When running multiple tests, adding a title can help the reading of test failures.

### Configuring Jekyll, Octopress and Octopress Ink plugins

```
build: true
config:
  jekyll:    
    - _configs/config.yml
    - _configs/test1.yml
  octopress: _configs/octopress.yml
  feed:      _configs/feed.yml
```

In this example:

- Jekyll will build with `--config _configs/config.yml,_configs/test1.yml`
- _configs/octopress.yml will be copied to ./_octopress.yml (and removed after tests)
- _configs/feed.yml will be copied to ./_plugins/feed/config.yml (and removed after tests)

This will not overwrite existing files as they will be backed up an restored after tests.


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
