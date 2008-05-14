class SponsorsController < ApplicationController
  before_filter :check_authorization

  def index
    @sponsors = Sponsor.find(:all)
    respond_to do |format|
      format.html # index.html
      format.xml { render :xml => @sponsors.to_xml}
    end
  end
  
  # GET /clients/1
  # GET /clients/1.xml
  
  def show
    @sponsor = Sponsor.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml {render :xml => @sponsor.to_xml }
    end
  end
  
  # GET /clients/new
  def new
    @sponsor = Sponsor.new
  end
  
  
  # GET /clients/1/edit
  def edit
    @sponsor = Sponsor.find(params[:id])
  end    
  
  # POST /clients
  # POST /clients.xml
  def create
    @sponsor = Sponsor.new(params[:sponsor])
    respond_to do |format|
      if @sponsor.save
        flash[:notice] = "Sponsor was successfully created"
        format.html {redirect_to sponsor_url(@sponsor)}
        format.xml do
          headers["Location"] = sponsor_url(@sponsor)
          render :nothing => true, :status => "201 Created"
        end
      else
        format.html {render :action => "new"}
        format.xml {render :xml => @sponsor.errors.to_xml}
      end
    end
  end
  
  # PUT /clients/1
  # PUT /clients/1.xml
  def update
    @sponsor = Sponsor.find(params[:id])
    respond_to do |format|
      if @sponsor.update_attributes(params[:sponsor])
        format.html {redirect_to sponsor_url(@sponsor)}
        format.xml {render :nothing => true}
      else
        format.html {render :action => "edit"}
        format.xml {render :xml => @sponsor.errors.to_xml}
      end
    end
  end
  
  # DELETE /clients/1
  # DELETE /clients/1.xml
  def destroy
    @sponsor = Sponsor.find(params[:id])
    @sponsor.destroy

    respond_to do |format|
      format.html do
        redirect_to sponsors_url
      end
      format.js # run the destroy.rjs template
      format.xml  do
        render :nothing => true
      end
    end
  end


  def upload_logo
    @logo = Logo.create! params[:logo]

    @sponsor = Sponsor.find(params[:sponsor_id])
    
    if(@sponsor.logo)
      @sponsor.logo.destroy
    end
    
    @sponsor.logo = @logo
    @logo.save

    if @sponsor.save
      responds_to_parent do
        render :update do |page|
          page.replace_html "logo", :partial => 'logo', :object => @sponsor
          page["logo"].visual_effect :grow
        end
      end
    else
      responds_to_parent do
        render :update do |page|
          # update the page with an error message
        end
      end
    end
    # redirect_to :controller => "cleaning", :action => "index"

  end


  def logo
    @logo = Logo.find(params[:id])
    send_data(@logo.db_file.data,
    :filename => @logo.filename,
    :type => @logo.content_type,
    :disposition => "inline")    
  end

end
