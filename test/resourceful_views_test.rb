require 'test/unit'
require File.join(File.dirname(__FILE__), "test_helper")

class ResourcefulViewsTest < ActionController::TestCase
  tests(ApplicationController)
  
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_compile_paths_to_check
    assert_equal(
      [
        ["admin", "controller_folder", "themes/theme_name", "view_name"], 
        ["admin", "themes/theme_name", "another_folder", "view_name"], 
        ["themes/theme_name", "controller_folder", "another_folder", "view_name"], 
        ["admin", "controller_folder", "default", "view_name"], 
        ["admin", "default", "another_folder", "view_name"], 
        ["default", "controller_folder", "another_folder", "view_name"]],
      ResourcefulViews.compile_paths_to_check("admin/controller_folder/another_folder/view_name".split("/"), "theme_name")
    )
  end
  
  def test_admin_controller
    @controller = Admin::SecretsController.new
    get "basic_test"
    assert_equal("basic test ok", @response.body)

    get "admin_index"
    assert_equal("this is admin index default page", @response.body)
  end
  
  def test_render_resource
    #light is not overriden, so should return result of default
    @controller = LightController.new
    get "render_resource_test"
    assert_equal("this is default render_resource_test", @response.body)
    
    #medium is overriden, so should return result of medium
    @controller = MediumController.new
    get "render_resource_test"
    assert_equal("this is medium render_resource_test", @response.body)
    
    #heavy uses _defaults, so should return result of default and assert that heavy _defaults executed
    @controller = HeavyController.new
    get "render_resource_test"
    assert_equal("this is default render_resource_test and assertion from heavy _defaults", @response.body)
  end

  def test_render_action
    #light is not overriden, so should return result of default
    @controller = LightController.new
    get "render_action_test"
    assert_equal("this is default render_action_test", @response.body)
    
    #medium is overriden, so should return result of medium
    @controller = MediumController.new
    get "render_action_test"
    assert_equal("this is medium render_action_test", @response.body)
    
    #heavy uses _defaults, so should return result of default and assert that heavy _defaults executed
    @controller = HeavyController.new
    get "render_action_test"
    assert_equal("this is default render_action_test and assertion from heavy _defaults", @response.body)
  end
  
  def test_render_resource_partial
    #light is not overriden, so should return result of default
    @controller = LightController.new
    get "render_resource_partial_test"
    assert_equal("this is default render_resource_partial_test", @response.body)

    #medium is overriden, so should return result of medium
    @controller = MediumController.new
    get "render_resource_partial_test"
    assert_equal("this is medium render_resource_partial_test", @response.body)
    
    #heavy uses _defaults, so should return result of default and assert that heavy _defaults executed
    @controller = HeavyController.new
    get "render_resource_partial_test"
    assert_equal("this is default render_resource_partial_test and assertion from heavy _defaults", @response.body)    
  end

  def test_render_partial
    #light is not overriden, so should return result of default
    @controller = LightController.new
    get "render_partial_test"
    assert_equal("this is default render_partial_test", @response.body)

    #medium is overriden, so should return result of medium
    @controller = MediumController.new
    get "render_partial_test"
    assert_equal("this is medium render_partial_test", @response.body)
    
    #heavy uses _defaults, so should return result of default and assert that heavy _defaults executed
    @controller = HeavyController.new
    get "render_partial_test"
    assert_equal("this is default render_partial_test and assertion from heavy _defaults", @response.body)    
  end
  
  def test_content_for_object
    #file in light both defines and call content_for_object
    @controller = LightController.new
    get "content_for_object_test"
    assert_equal("object in light", @response.body)
    
    #defined in a file in default, called in view specific
    @controller = MediumController.new
    get "content_for_object_test"
    assert_equal("default content for object", @response.body)
    
    #defined in _defaults, called in default
    @controller = HeavyController.new
    get "content_for_object_test"
    assert_equal("heavy content for object", @response.body)
  end
  
  def test_default_content_for
    #default_content_for is called and not overriden
    @controller = LightController.new
    get "default_content_for_test"
    assert_equal("content in default_content_for block", @response.body)
    
    #default_content_for is overriden and then called
    @controller = MediumController.new
    get "default_content_for_test"
    assert_equal("content in content_for block", @response.body)
        
    #default_content_for is called in defaults, overriden by view specific partial
    @controller = HeavyController.new
    get "default_content_for_test"
    assert_equal("content in heavy for default_content_test", @response.body)        
  end

  def test_themes
    @controller = LightController.new
    get "themes_test"
    assert_equal("default theme contents", @response.body)

    @controller = MediumController.new
    get "themes_test"
    assert_equal("red theme contents", @response.body)
        
    @controller = HeavyController.new
    get "themes_test"
    assert_equal("heavy theme contents", @response.body)
  end

  def test_themes_arg_to_render_resource
    @controller = LightController.new
    get "themes_arg_pass_test"
    assert_equal("blue themes_arg_pass_test", @response.body)

    @controller = MediumController.new
    get "themes_arg_pass_test"
    assert_equal("blue themes_arg_pass_test", @response.body)
        
    @controller = HeavyController.new
    get "themes_arg_pass_test"
    assert_equal("heavy themes_arg_pass_test", @response.body)
  end

  def test_themes_in_content_for
    @controller = LightController.new
    get "themes_content_for_test"
    assert_equal("default _themes_content_for_partial", @response.body)

    @controller = MediumController.new
    get "themes_content_for_test"
    assert_equal("red _themes_content_for_partial", @response.body)
        
    @controller = HeavyController.new
    get "themes_content_for_test"
    assert_equal("heavy _themes_content_for_partial", @response.body)
  end

  
  #TODO: write some tests that are NOT calling render_resource? but just calling render directly? (there should be valid behavior there)
  
  def test_get_content_for
  end
  
  def test_current_action
  end
  
  
  
end
