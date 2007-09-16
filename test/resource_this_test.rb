require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'action_controller/test_process'
require 'active_record/fixtures'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :posts do |t|
    t.column :title,      :string
    t.column :body,       :text
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end
end

class Post < ActiveRecord::Base
end

class PostsController < ActionController::Base
  resource_this
end

class ResourceThisTest < Test::Unit::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first = Post.create :title => "Welcome to the weblog", :body => "Such a lovely day"
  end

  def test_should_get_index
    accept :xml
    get :index
    assert_response :success
    assert assigns(:posts)
  end

  def test_should_get_new
    accept :xml
    get :new
    assert_response :success
    assert assigns(:post)
  end

  def test_should_create_post
    accept :xml
    assert_difference('Post.count') do
      post :create, :post => { :title => "test", :body => "test" }
    end
    assert_response :success
    assert assigns(:post)
  end

  def test_should_show_post
    accept :xml
    get :show, :id => 1
    assert_response :success
    assert assigns(:post)
  end

  def test_should_get_edit
    accept :xml
    get :edit, :id => 1
    assert_response :success
    assert assigns(:post)  
  end

  def test_should_update_post
    accept :xml
    put :update, :id => 1, :post => { :title => "test", :body => "test" }
    assert_response :success
    assert assigns(:post)
  end

  def test_should_destroy_post
    accept :xml
    assert_difference('Post.count', -1) do
      delete :destroy, :id => 1
    end
    assert_response :success
  end
end
