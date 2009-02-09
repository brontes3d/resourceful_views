class ApplicationController < ActionController::Base
  
  def index
    render_resource :index
  end
  
  def render_action_test
    render :action => 'render_action_test'
  end
  
  def render_partial_test
    render :partial => 'render_partial_test'
  end
  
  def render_resource_partial_test
    render_resource_partial :render_resource_partial_test        
  end
  
  def render_resource_test
    render_resource :render_resource_test    
  end

  def content_for_object_test
    render_resource :content_for_object_test 
  end
  
  def default_content_for_test
    render_resource :default_content_for_test     
  end
  
  def themes_test
    render_resource :themes_test
  end

  def themes_arg_pass_test
    render_resource :themes_arg_pass_test, :theme => 'blue'
  end
  
  def themes_content_for_test
    render_resource :themes_content_for_test
  end
  
  def rescue_action(e) raise e end
  
end

class LightController < ApplicationController
end
class MediumController < ApplicationController
  resourceful_views_theme :red
  
end
class HeavyController < ApplicationController
  resourceful_views_theme :red
  
end

module Admin
  
  class SecretsController < ApplicationController
        
    def basic_test
      render :action => 'basic_test'
    end
    
    def admin_index
    end
  
  end
  
end


