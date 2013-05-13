#!/usr/bin/env ruby
#  @author Philippe Vincent-Royol
#
#  Original file from https://github.com/alampros/Docter
#  Github-flavored markdown to HTML, in a command-line util.
#
#  $ cat README.md | ./github-flavored-markdown.rb
#
#  Notes:
#  You will need to install Pygments for syntax coloring
#  ```bash
#    $ sudo easy_install pygments
#  ```
#
#  Install the gems `redcarpet` and `Pygments`
#
#
require 'rubygems'
require 'redcarpet'
require 'pathname'
require 'pygments.rb'
require 'optparse'

$options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: githubMarkdown.rb [options] input.md output.html"
  
  $options[:toc] = false
  opts.on( '-t', '--toc', 'Add a table of contents - Replace ::generate_toc') do
    $options[:toc] = true
  end
  
  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

class HTMLwithPygments < Redcarpet::Render::XHTML
  @@number = -1
  
  def doc_header()
    ghf_css_path = File.join Dir.pwd, 'githubMarkdown.css'
	  #	puts Pygments.styles()
			# monokai manni perldoc borland colorful default murphy vs trac tango fruity autumn bw emacs vim pastie friendly native
			#	'<style>' + Pygments.css('.highlight',:style => 'vs') + '</style>'
    if UNSTYLED 
      '<div class="md"><article>'
    else
      '<style>' + File.read(ghf_css_path) + '</style><div class="md"><article>'
    end
	end
	
	def header( text, header_level )
	  @@number += 1
	  "<h#{header_level} id=\"toc_#{@@number}\">#{text}</h#{header_level}>"
  end
  
  def doc_footer
    '</article></div>'
  end
  
	def block_code(code, language)
		Pygments.highlight(code, :lexer => language, :options => {:encoding => 'utf-8'})
	end
end


def fromMarkdown(text)
	# options = [:fenced_code => true, :generate_toc => true, :hard_wrap => true, :no_intraemphasis => true, :strikethrough => true ,:gh_blockcode => true, :autolink => true, :xhtml => true, :tables => true]
	markdown = Redcarpet::Markdown.new(HTMLwithPygments,
		:fenced_code_blocks => true,
		:no_intra_emphasis => true,
		:autolink => true,
		:strikethrough => true,
		:lax_html_blocks => true,
		:superscript => true,
		:hard_wrap => true,
		:tables => true,
		:xhtml => true,
		:with_toc_data => true
	)
	toc = Redcarpet::Markdown.new( Redcarpet::Render::HTML_TOC )
	
	render_html = markdown.render( text )
	if $options[:toc]
	  render_toc  = toc.render( text )
		full = render_html.sub( "::generate_toc", render_toc )
		
		return full
	else
	  return render_html
  end
end

optparse.parse!
#UNSTYLED = (ARGV.first == '--unstyled')
UNSTYLED = false

first, second = ARGV

begin
  inputFile   = File.open( first )
  outputFile  = File.open( second, 'w' )
  
  outputFile.write( fromMarkdown( inputFile.read() ) )
rescue IOError => e
  puts "Could not open files"
  puts e.message
ensure
  inputFile.close unless inputFile == nil
  outputFile.close unless outputFile == nil
end

