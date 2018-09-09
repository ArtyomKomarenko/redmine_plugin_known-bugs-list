class KnownBugsListController < ApplicationController

  def index
    bugs_list = KnownBugsList.new
    @issues_list = bugs_list.get_issues_by_all_projects
  end

end
