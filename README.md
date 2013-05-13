# githubMarkdown

Cli script which transform [markdown](http://daringfireball.net/projects/markdown/syntax) to html using *Github Flavored Markdown* specifications.

Original script comes from [Docter](https://github.com/alampros/Docter), and update for this case.

All pygments language supported are available [here](http://pygments.org/languages/)

## Requirements

* Ruby & [Gem](http://rubygems.org/)
* [Redcarpet 2](https://github.com/vmg/redcarpet)
* [Pygments.rb](https://github.com/tmm1/pygments.rb)
* Various gem

```bash
$ gem install redcarpet pygments.rb
```

## Usage

1. Clone this repository
2. ```cd``` to the repo
3. Just place your markdown file to this directory
4. Don't forget to run ```chmod +x githubMarkdown.rb```
5. Execute

```bash
$ ./githubMarkdown.rb [-t] input.md ouput.html 
```
-t : Display tables content (replace ::generate_toc mark)

## Changes

### 2013-04-26

* Initial commit 
