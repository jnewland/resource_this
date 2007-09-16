module ResourceThis # :nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def resource_this(options = {})
      options.assert_valid_keys(:class_name, :will_paginate, :sort_method)

      singular_name         = controller_name.singularize
      singular_name         = options[:class_name].downcase.singularize unless options[:class_name].nil?
      class_name            = options[:class_name] || singular_name.camelize
      plural_name           = singular_name.pluralize
      will_paginate_index   = options[:class_name] || false

      module_eval <<-"end_eval", __FILE__, __LINE__

        def index
          if will_paginate_index
            instance_variable_set("@#{plural_name}", class_name.paginate(:page => params[:page]))
          else
            instance_variable_set("@#{plural_name}", class_name.find(:all))
          end
          #TODO: add sorting customizable by subclassed controllers
          respond_to do |format|
            format.html
            format.xml  { render :xml => instance_variable_get("@#{plural_name}") }
          end
        end

        def show
          instance_variable_set("@#{singular_name}", class_name.find(params[:id]))
          respond_to do |format|
            format.html
            format.xml  { render :xml => instance_variable_get("@#{singular_name}") }
          end
        end

        def new
          instance_variable_set("@#{singular_name}", class_name.new)
          respond_to do |format|
            format.html { render :action => :edit }
            format.xml  { render :xml => instance_variable_get("@#{singular_name}") }
          end
        end

        def create
          instance_variable_set("@#{singular_name}", class_name.create!(params_hash))
          flash[:notice] = "#{class_name} was successfully created."
          respond_to do |format|
            format.html { redirect_to :action => :index }
            format.xml  { render :xml => instance_variable_get("@#{singular_name}"), :status => :created, :location => instance_variable_get("@#{singular_name}") }
          end
        rescue ActiveRecord::RecordInvalid
          flash[:error] = instance_variable_get("@#{singular_name}").errors
          respond_to do |format|
            format.html { render :action => :new }
            format.xml  { render :xml => instance_variable_get("@#{singular_name}").errors, :status => :unprocessable_entity }
          end
        end 

        def edit
          instance_variable_set("@#{singular_name}", class_name.find(params[:id])) 
        end

        def update
          instance_variable_set("@#{singular_name}", class_name.find(params[:id])) 
          eval("@#{singular_name}").update_attributes!(params_hash)
          flash[:notice] = "#{class_name} was successfully updated."
          respond_to do |format|
            format.html { redirect_to(instance_variable_get("@#{singular_name}")) }
            format.xml  { head :ok }
          end
        rescue ActiveRecord::RecordInvalid
          flash[:error] = instance_variable_get("@#{singular_name}").errors
          respond_to do |format|
            format.html { render :action => :edit }
            format.xml  { render :xml => instance_variable_get("@#{singular_name}").errors, :status => :unprocessable_entity }
          end
        end

        def destroy
          class_name.find(params[:id]).destroy
          respond_to do |format|
            format.html { redirect_to :action => :index }
            format.xml  { head :ok }
          end
        end

      end_eval
    end
  end
end
