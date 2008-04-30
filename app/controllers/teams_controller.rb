class TeamsController < ApplicationController
  before_filter :login_required


  # render new.rhtml
  def new
    @team = Team.new
    @team.captain = current_user
  end
  
  # POST /stories
  # POST /stories.xml
  def create
    @team = Team.new(params[:team])
    @team.captain = current_user

    respond_to do |format|
      if @team.save
        flash[:notice] = "New team was successfully created"
        format.html {redirect_to user_url(current_user) }
        # format.xml do
        #   headers["Location"] = client_url(@client)
        #   render :nothing => true, :status => "201 Created"
        # end
      else
        format.html {render :action => "new"}
        # format.xml {render :xml => @client.errors.to_xml}
      end
    end
  end
  
  

end
