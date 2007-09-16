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
      will_paginate_index   = options[:will_paginate] || false
      
      if will_paginate_index
        module_eval <<-"end_eval", __FILE__, __LINE__
          def index
            @#{plural_name} = #{class_name}.paginate(:page => params[:page])
            #TODO: add sorting customizable by subclassed controllers
            respond_to do |format|
              format.html
              format.xml  { render :xml => @#{plural_name} }
            end
          end
        end_eval
      else
        module_eval <<-"end_eval", __FILE__, __LINE__
          def index
            @#{plural_name} = #{class_name}.find(:all)
            #TODO: add sorting customizable by subclassed controllers
            respond_to do |format|
              format.html
              format.xml  { render :xml => @#{plural_name} }
            end
          end
        end
      end

      module_eval <<-"end_eval", __FILE__, __LINE__

        def show
          @#{singular_name} = #{class_name}.find(params[:id])
          respond_to do |format|
            format.html
            format.xml  { render :xml => @#{singular_name} }
          end
        end

        def new
          @#{singular_name} = #{class_name}.new
          respond_to do |format|
            format.html { render :action => :edit }
            format.xml  { render :xml => @#{singular_name} }
          end
        end

        def create
          @#{singular_name} = #{class_name}.create!(params[:#{singular_name}])
          flash[:notice] = "#{class_name} was successfully created."
          respond_to do |format|
            format.html { redirect_to :action => :index }
            format.xml  { render :xml => @#{singular_name}, :status => :created, :location => @#{singular_name} }
          end
        rescue ActiveRecord::RecordInvalid
          flash[:error] = @#{singular_name}.errors
          respond_to do |format|
            format.html { render :action => :new }
            format.xml  { render :xml => @#{singular_name}.errors, :status => :unprocessable_entity }
          end
        end 

        def edit
          @#{singular_name} = #{class_name}.find(params[:id])
        end

        def update
          @#{singular_name} = #{class_name}.find(params[:id])
          @#{singular_name}.update_attributes!(params[:#{singular_name}])
          flash[:notice] = "#{class_name} was successfully updated."
          respond_to do |format|
            format.html { redirect_to @#{singular_name} }
            format.xml  { head :ok }
          end
        rescue ActiveRecord::RecordInvalid
          flash[:error] = @#{singular_name}.errors
          respond_to do |format|
            format.html { render :action => :edit }
            format.xml  { render :xml => @#{singular_name}.errors, :status => :unprocessable_entity }
          end
        end

        def destroy
          @#{singular_name} = #{class_name}.find(params[:id])
          @#{singular_name} = @#{singular_name}.destroy
          respond_to do |format|
            format.html { redirect_to :action => :index }
            format.xml  { head :ok }
          end
        end

      end_eval
    end
  end
end
