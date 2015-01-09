# Clash

Clash is a super simple testing framework for static sites.

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

## Usage

```
clash [path] [test] [options]
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
-f, --file    FILE      Use a specific test file (default: .clash.yml)
-c, --context NUMBER    On diff errors, show NUMBER of lines of surrounding context (default: 2)
-l, --list              Print a list of tests' numbers and titles (does not run tests)
-d, --debug             Display output from system commands in tests
-h, --help              Show this message
```

Clash reads its configuration from a .clash.yml file in the root of your project. Use the --file
option to choose a different configuration file.

### Example usage:

If you have a simple liquid tag you want to test:

 1. Create a simple Jekyll site with tags.
 2. Create one or more pages which test the tags features.
 3. Manually check that the compiled site looks right.
 4. Copy `_site` to `_expected`.
 5. Create a test file like the one below.
 6. **Code with confidence!**

### Simple configuration:

Clash will build your site with Jekyll, and compare the contents of _expected/ to _site/.

```
build: true
compare: _expected _site
```

Of course, there is a lot more you can do.

## Configuration

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
  name: Check site build
  build: true
  compare: _expected _site
-
  name: Check asset compression
  compare: _cdn_expected _cdn_build
```

Note: When running multiple tests, adding a name can help the reading of test failures.

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
  before: remove_caches
  build: true
  after: 
    - reset_site
    - echo "Gist build complete"
```

Notice the first test isn't a test at all. It's a hash of tasks, each with its own defined command(s). The test below calls tasks in its before and after blocks. Note that tasks can be used along with any other system command in before or after blocks.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/clash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
