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

$options     = {}
$stylesheets = ''
$javascript  = ''

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: githubMarkdown.rb [options] input.md output.html"
  
  $options[:toc] = false
  opts.on( '-t', '--toc', 'Add a table of contents - Replace ::generate_toc') do
    $options[:toc] = true
  end
  
  $options[:presentation] = false
  opts.on( '-p', '--presentation', 'Creating beautiful presentations using HTML with reveal.js') do
    $options[:presentation] = true
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
		if $options[:presentation]
		  $stylesheets = '<link rel="stylesheet" href="css/reveal.min.css">
  		<link rel="stylesheet" href="css/theme/default.css" id="theme">
  		<!-- For syntax highlighting -->
  		<link rel="stylesheet" href="lib/css/zenburn.css">'
		  
  	elsif !UNSTYLED
  	  $stylesheets = '<style>' + File.read( ghf_css_path ) + '</style>'
	  end
	  
		header = '<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">' + $stylesheets + '
        <meta name="apple-mobile-web-app-capable" content="yes" />
    		<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />

    		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    </head>
<body>
'		
    #if UNSTYLED 
    style = ''
    if $options[:presentation]
      style = '<div class="reveal"><div class="slides">'
    else
      style = '<div class="md"><article>'
    end
    #else
    #  style = '<style>' + File.read( ghf_css_path ) + '</style><div class="md"><article>'
    #end
    
    header + style
	end
	
	def header( text, header_level )
	  if $options[:toc]
	    @@number += 1
	    "<h#{header_level} id=\"toc_#{@@number}\">#{text}</h#{header_level}>"
	  else
	    "<h#{header_level}>#{text}</h#{header_level}>"
	  end
  end
  
  def doc_footer
    style = ''
    if $options[:presentation]
        $javascript = '<script src="lib/js/head.min.js"></script>
  		  <script src="js/reveal.js"></script>'
  		  
        style = "</div></div> " + $javascript + "
        <script>

    			// Full list of configuration options available here:
    			// https://github.com/hakimel/reveal.js#configuration
    			Reveal.initialize({
    				controls: true,
    				progress: true,
    				history: true,
    				center: true,

    				//theme: Reveal.getQueryHash().theme, // available themes are in /css/theme
    				//transition: Reveal.getQueryHash().transition || 'default', // default/cube/page/concave/zoom/linear/fade/none

    				// Optional libraries used to extend on reveal.js
    				dependencies: [
    					{ src: 'lib/js/classList.js', condition: function() { return !document.body.classList; } },
    					{ src: 'plugin/markdown/marked.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
    					{ src: 'plugin/markdown/markdown.js', condition: function() { return !!document.querySelector( '[data-markdown]' ); } },
    					{ src: 'plugin/highlight/highlight.js', async: true, callback: function() { hljs.initHighlightingOnLoad(); } },
    					{ src: 'plugin/zoom-js/zoom.js', async: true, condition: function() { return !!document.body.classList; } },
    					{ src: 'plugin/notes/notes.js', async: true, condition: function() { return !!document.body.classList; } }
    					// { src: 'plugin/search/search.js', async: true, condition: function() { return !!document.body.classList; } }
    					// { src: 'plugin/remotes/remotes.js', async: true, condition: function() { return !!document.body.classList; } }
    				]
    			});

    		</script>
    		"
    else
        style = '</article></div>'
    end
    return style + '</body></html>'
  end
  
  #def paragraph(text)
  #  if $options[:presentation]
  #    "#{text}"
  #  end
  #end
  
	def block_code(code, language)
	  if $options[:presentation]
	    code = code.sub( '<?php', '' )
	    code = code.sub( '<?', '' )
	    code = code.sub( '?>', '' )
	    return "<pre><code data-trim>" + code +"</code></pre>"
	  else
	  		Pygments.highlight(code, :lexer => language, :options => {:encoding => 'utf-8'})
  	end	
	end

end


def markdownToHtml(text)
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

def markdownToPres(text)
  markdown = Redcarpet::Markdown.new( HTMLwithPygments,
	  :fenced_code_blocks => true,
	  :no_intra_emphasis => true,
	  :autolink => true,
	  :strikethrough => false,
	  :lax_html_blocks => true,
	  :superscript => true,
	  :hard_wrap => true,
	  :tables => true,
	  :xhtml => true
  )
  render_html = markdown.render( text )
  
    
  return render_html
end

#############################
# Main program start here ! #
#############################
optparse.parse!
#UNSTYLED = (ARGV.first == '--unstyled')
UNSTYLED = false

if $options[:presentation]
  file = ARGV.first
  inputFile = File.open( file )
  
  input = inputFile.read()

  input = input.gsub( '::slide', '<section>' )
  input = input.gsub( '::', '</section>' )
  
  outputFileName = File.basename( file, '.md' )
  outputFile = outputFileName + '.html'
  outputDir = File.dirname( file )
  
  output = File.open( outputDir + '/' + outputFile, 'w' )
  html = markdownToPres( input )

#  html = html.gsub( '<p>::slide</p>', '<section>' )
#  html = html.gsub( '<p>::slide', '<section>' )
#  html = html.gsub( '<p>::</p>', '</section>' )
#  html = html.gsub( '::</p>', '</section>' )
  output.write( html )
  
else
  # This is to convert markdown to html
  # using Redcarpet
  first, second = ARGV
  begin
    inputFile   = File.open( first )
    outputFile  = File.open( second, 'w' )
  
    outputFile.write( markdownToHtml( inputFile.read() ) )
  rescue IOError => e
    puts "Could not open files"
    puts e.message
  ensure
    inputFile.close unless inputFile == nil
    outputFile.close unless outputFile == nil
  end
end

