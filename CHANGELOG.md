# Changelog

### 2.0.1 - 2015-04-23
- Fix: now --version option prints Clash version. I know, right?

### 2.0.0 - 2015-04-07
- New: Clash loads config file from current directory or 'test' directory, supporting for the common convention by default.
- Change: Removed --file option for the sake of simplicity.
- Change: --debug option is now --trace to match Jekyll's CLI flag.
- Minor: Improved documentation, adding a getting started guide and organizing sections.
- Minor: CLI help is more thorough, printing through less rather than stdout.

### 1.6.1 - 2015-04-05
- Fix: accept option order was backwards.
- Fix: accept now properly syncs missing files.

### 1.6.0 - 2015-04-04
- New: Added --accept option for copying test build(s) to expected directory.

### 1.5.3 - 2015-03-30
- Fix: Jekyll cache is removed using the correct path.

### 1.5.2 - 2015-03-30
- Fix: Removes Jekyll's `.jekyll-metadata` cache before building sites.

### 1.5.1 - 2015-02-14
- Ensure proper plugins directory when configuring Octopress Ink plugins.

### 1.5.0 - 2015-01-25
- New: `init` command adds a testing scaffold.
- New: Run tests by line number, e.g. `clash :35`.
- New: `--build` option runs `before` and `build` commands only.

### 1.4.1 - 2015-01-09
- Minor Fix: Commands like this: `echo "stuff" > file` work again.

### 1.4.0 - 2015-01-09

- Silenced system output and tests are less noisy. [#10](https://github.com/imathis/clash/pull/10) - Thanks @parkr!
- Added `--debug` option so you can, Bring the noise!

### 1.3.1 - 2015-01-05

- Added support for Octopress docs

### 1.3.0 - 2014-11-28

- Added `--list` option to list tests' number and title.

### 1.2.1 - 2014-11-23

- Fixed missing newline on "File not fount" output.

### 1.2.0 - 2014-11-23

- Added Tasks: reuse system commands without duplication.

### 1.1.0 - 2014-09-01

- Test ranges, e.g. `clash 2-4`
- Run tests in a directory, e.g. `clash some_dir`

### 1.0.2 - 2014-07-13
- Sets JEKYLL_ENV to 'test'

### 1.0.1 - 2014-07-07
- compare no longer needs a comma (to be more like diff)

### 1.0.0 - 2014-07-07
- Initial release
