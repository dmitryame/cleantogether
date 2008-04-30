class ExpeditionsController < ApplicationController
  before_filter :login_required

  # render new.rhtml
  def new
    @expedition = Expedition.new
    @expedition.captain = current_user
  end
  
  # POST /stories
  # POST /stories.xml
  def create
    @expedition = Expedition.new(params[:expedition])
    @expedition.captain = current_user

    respond_to do |format|
      if @expedition.save
        flash[:notice] = "New expedition was successfully created"
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
