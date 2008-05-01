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


  def show 
    @expedition = current_user.captains_expeditions.find(params[:id])
    respond_to do |format| 
      format.html # show.rhtml 
      # format.xml { render :xml => @article.to_xml } 
    end 
  end 


  def edit
    @expedition = current_user.captains_expeditions.find(params[:id])
  end  
  
  def update 
    @expedition = current_user.captains_expeditions.find(params[:id])
    respond_to do |format| 
      if @expedition.update_attributes(params[:expedition]) 
        format.html { redirect_to user_expedition_url(current_user, @expedition) } 
        # format.xml { render :nothing => true } 
      else 
        format.html { render :action => "edit" } 
        # format.xml { render :xml => @article.errors.to_xml } 
      end 
    end 
  end 


end
