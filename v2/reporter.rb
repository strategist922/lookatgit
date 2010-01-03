require 'time'
require 'open3'

#require 'gitauthor'
require 'gitfile'
require 'utils'

class Reporter

   def initialize(commits)
       @commits = commits
       @authors = {}
       @files   = {}
       calculate()
   end

   def calculate()
       @commits.each do |commit|
           commit.changes.each do |change|
               unless @files.has_key?(change.filename)
                   @files[change.filename] = GitFile.new(change.filename)
               end
               unless @authors.has_key?(change.author.name)
                   @authors[change.author.name] = change.author
               end
               @files[change.filename].record_change(change)
               @authors[change.author.name].record_change(change, @files[change.filename])
           end
       end
   end

   def top_contributors_report()
        criteria = @@options.sort
        criteria='commit_ct' if criteria.nil?
        if @@options.header
            puts "--------------------------------------------------"
            puts "TOP CONTRIBUTORS REPORT                           "
            puts "name,lines_changed,lines_added,lines_removed,commit_ct,awol_time,commit_frequency"
            puts "--------------------------------------------------"
        end
        sorted_authors = @authors.values().sort { |a,b| b.send(criteria) <=> a.send(criteria) }
        counter = @@options.limit
        sorted_authors.each_with_limit(@@options.limit) do |a|
            puts "#{a.name},#{a.lines_changed},#{a.lines_added},#{a.lines_removed},#{a.commit_ct},#{a.awol_time},#{a.commit_frequency}"
        end
   end

   def top_files_report()
        criteria = @@options.sort
        criteria='commit_ct' if criteria.nil?
        if @@options.header
            puts "------------------------------------------"
            puts "TOP FILES REPORT                          "
            puts "filename,lines_changed,change_ct,author_ct,commit_ct"
            puts "------------------------------------------"
        end
        sorted_files = @files.values().sort { |a,b| b.send(criteria) <=> a.send(criteria) }
        counter = @@options.limit
        sorted_files.each_with_limit(@@options.limit) do |file|            
            puts "#{file.filename},#{file.lines_changed},#{file.change_ct},#{file.author_ct},#{file.commit_ct}"
        end
   end

end
