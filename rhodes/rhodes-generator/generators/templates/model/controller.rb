require 'rho/rhocontroller'

class <%= class_name %>Controller < Rho::RhoController

  #GET /<%= class_name %>
  def index
    @<%= name.downcase.pluralize %> = <%= class_name %>.find(:all)
    render
  end

  # GET /<%= class_name %>/{1}
  def show
    @<%= name.downcase %> = <%= class_name %>.find(@params['id'])
    render :action => :show
  end

  # GET /<%= class_name %>/new
  def new
    @<%= name.downcase %> = <%= class_name %>.new
    render :action => :new
  end

  # GET /<%= class_name %>/{1}/edit
  def edit
    @<%= name.downcase %> = <%= class_name %>.find(@params['id'])
    
    if @<%= name.downcase %> && !@<%= name.downcase %>.can_modify
        render :action => :cannot_edit
    else    
        render :action => :edit
    end    
  end

  # POST /<%= class_name %>/create
  def create
    @<%= name.downcase %> = <%= class_name %>.new(@params['<%= name.downcase %>'])
    if !@<%= name.downcase %>.save
        render :action => :cannot_edit
    else
        redirect :action => :index
    end    
  end

  # POST /<%= class_name %>/{1}/update
  def update
    @<%= name.downcase %> = <%= class_name %>.find(@params['id'])
    if !@<%= name.downcase %>.update_attributes(@params['<%= name.downcase %>'])
        render :action => :cannot_edit
    else
        redirect :action => :index
    end    
  end

  # POST /<%= class_name %>/{1}/delete
  def delete
    @<%= name.downcase %> = <%= class_name %>.find(@params['id'])
    if !@<%= name.downcase %>.destroy
        render :action => :cannot_edit
    else
        redirect :action => :index
    end    
  end
end
