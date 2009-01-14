require 'rubygems'
#require 'active_support'
#require 'action_pack/actioncontroller'

require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'

unless defined?(RAILS_ROOT)
 RAILS_ROOT = ENV["RAILS_ROOT"] || File.expand_path(File.join(File.dirname(__FILE__), "mocks"))
end

require File.join(File.dirname(__FILE__), "..", "init")

MOCK_CONTROLLER_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'mocks/controllers')
MOCK_VIEWS_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'mocks/views')
require File.join(MOCK_CONTROLLER_DIR, 'application')

ActionController::Base.view_paths = [MOCK_VIEWS_DIR]
ActionController::Routing::Routes.clear!
ActionController::Routing.controller_paths= [ MOCK_CONTROLLER_DIR ]
ActionController::Routing::Routes.draw {|m| m.connect ':controller/:action/:id' }
