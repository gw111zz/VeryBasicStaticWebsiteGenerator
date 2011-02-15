#########################################################################################
# Copyright (c) 2011 gw111zz all rights reserved.
#########################################################################################

#########################################################################################
# Requires...
#########################################################################################

require 'erb'
require 'fileutils'

#########################################################################################
# Constants 
#########################################################################################

OutputDir = "./output/"        # Where the generated static website will appear
ResourcesDir = "./resources/"  # Files which get copied unmodified to the generated 
                               # website go here. For example, put stylesheets and
                               # images here
ContentDir = "./content/"      # Content directory - stores the different content which
                                # gets inserted into the template
TemplateFile = "./templates/index.rhtml" # Template file goes here
FolderSeparater = "/"           # Should be able to leave this as is. May need to change
                                # to "\\" for Windows

#########################################################################################
# Utility Functions
#########################################################################################

class Utilities
	def Utilities.read_whole_file(filename)
		begin
			template = ""
			file = File.open(filename, "r") 
			template = file.read
			file.close	
			return template
		rescue
			return ""
		end
	end

    def Utilities.mkdir(dirname)
        begin
            Dir.mkdir(dirname)
        rescue
            puts "Unable to make directory #{dirname}"
            return false
        end
        return true
    end
end

#########################################################################################
# Clear old output directory
#########################################################################################

begin
    FileUtils.rm_rf(OutputDir)
rescue
    puts "Unable to delete the old generated site which is in #{OutputDir}. \
    Is that directory read only or is there a lock on it?"
    Process.exit
end

#########################################################################################
# Create the new output directory 
#########################################################################################

if !Utilities.mkdir(OutputDir)
    Process.exit
end

#########################################################################################
# Generate the site 
#########################################################################################

# Read the template file
template = ""
begin
    file = File.open(TemplateFile, "r") 
    template = file.read
    file.close	
rescue
    puts "Could not open the template file: #{TemplateFile}"
end

# Go through each file in the ContentDir and insert the content into the template
# Write the file out to the OutputDir
Dir.foreach(ContentDir) do |filename|
    next if filename == "."
    next if filename == ".."
    content = Utilities.read_whole_file(ContentDir + filename)
    unless content == ""
        erb_template = ERB.new(template)
        File.open(OutputDir + filename, "w") do |file|
            file.write(erb_template.result(binding))
            puts "Generated #{OutputDir}#{filename}"
        end
    end
end

# Copy resource files (images and stylesheets...) to output directory 
begin 
    FileUtils.cp_r ResourcesDir + '.', OutputDir
    puts "Copied resource files"
rescue
    puts "Could not copy resource files to output directory"
end

