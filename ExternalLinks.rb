#
# This Jekyll plugin adds a target blank to all external links that don't already have a target
# 
# Don't forget to config url and localUrl in your _config.yml file
#
# The only known issue is that because converter don't have acces to the site context, using "Jekyll.configuration({})" generate a lot of log output when building the site.
#

module Jekyll
  class ExternalLinks < Converter

    # Let's fetch HTML or MD files
    def matches(ext)
      ext =~ /^\.(html|md)$/i
    end

    # The output result will be HTML files
    def output_ext(ext)
      ".html"
    end

    # preading some magic to the links
    def convert(content)

      # Configurations
      siteConfig = Jekyll.configuration({})
      remoteSite = siteConfig['remoteUrl']
      serveSite = siteConfig['localUrl']

      if (remoteSite.nil? || serveSite.nil?)
        puts "Please configure remoteUrl & localUrl in your _config.yml"
      else
        # Getting all the links from the content
        content.scan(/(\<a href=["'].*?["']\>.*?\<\/a\>)/).flatten.each do |link|
          # Adding a target to external links that don't already have a target
          if !link.match(/\<a href=["'](https{0,1}:\/\/|www\.){0,1}(#{serveSite}|#{remoteSite})(.*?)["']\>(.*?)\<\/a\>/) && !link.match("target=") && link.match(/(\<a href=["'](.*?)["']\>(.*?)\<\/a\>)/)
            content.gsub!(link, "<a href=\"#{$2}\" target=\"_blank\" >#{$3}</a>")
          end
        end
      end

        # Converting the content to HTML
        site = Jekyll::Site.new(@config)
        mkconverter = site.getConverterImpl(Jekyll::Converters::Markdown)
        mkconverter.convert(content)

        return content
    end
  end
end