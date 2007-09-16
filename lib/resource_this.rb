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
        before_filter :load_#{singular_name}, :only => [ :show, :edit, :update, :destroy ]
        before_filter :load_#{plural_name}, :only => [ :index ]
        before_filter :new_#{singular_name}, :only => [ :new ]
        before_filter :create_#{singular_name}, :only => [ :create ]
        before_filter :update_#{singular_name}, :only => [ :update ]
        before_filter :destroy_#{singular_name}, :only => [ :destroy ]
      
      protected
        def load_#{singular_name}
          @#{singular_name} = #{class_name}.find(params[:id])
        end
        
        def new_#{singular_name}
          @#{singular_name} = #{class_name}.new
        end
        
        def create_#{singular_name}
          @#{singular_name} = #{class_name}.new(params[:#{singular_name}])
          @created = @#{singular_name}.save
        end
        
        def update_#{singular_name}
          @updated = @#{singular_name}.update_attributes(params[:#{singular_name}])
        end
        
        def destroy_#{singular_name}
          @#{singular_name} = @#{singular_name}.destroy
        end
      end_eval
      
      
      if will_paginate_index
        module_eval <<-"end_eval", __FILE__, __LINE__
          def load_#{plural_name}
            @#{plural_name} = #{class_name}.paginate(:page => params[:page])
            #TODO: add sorting customizable by subclassed controllers
          end
        end_eval
      else
        module_eval <<-"end_eval", __FILE__, __LINE__
          def load_#{plural_name}
            @#{plural_name} = #{class_name}.find(:all)
            #TODO: add sorting customizable by subclassed controllers
          end
        end_eval
      end

      module_eval <<-"end_eval", __FILE__, __LINE__
      public
        def index
          respond_to do |format|
            format.html
            format.xml  { render :xml => @#{plural_name} }
          end
        end

        def show          
          respond_to do |format|
            format.html
            format.xml  { render :xml => @#{singular_name} }
          end
        end

        def new          
          respond_to do |format|
            format.html { render :action => :edit }
            format.xml  { render :xml => @#{singular_name} }
          end
        end

        def create
          respond_to do |format|
            if @created
              flash[:notice] = '#{class_name} was successfully created.'
              format.html { redirect_to @#{singular_name} }
              format.xml  { render :xml => @#{singular_name}, :status => :created, :location => @#{singular_name} }
            else
              format.html { render :action => :new }
              format.xml  { render :xml => @#{singular_name}.errors, :status => :unprocessable_entity }
            end
          end
        end 

        def edit
        end

        def update
          respond_to do |format|
            if @updated
              flash[:notice] = '#{class_name} was successfully updated.'
              format.html { redirect_to @#{singular_name} }
              format.xml  { head :ok }
            else
              format.html { render :action => :edit }
              format.xml  { render :xml => @#{singular_name}.errors, :status => :unprocessable_entity }
            end
          end
        end

        def destroy          
          respond_to do |format|
            format.html { redirect_to :action => #{plural_name}_url }
            format.xml  { head :ok }
          end
        end
      end_eval
    end
  end
end
