# Including This plugin causes this helper to be added as a helper to ActionController::Base
# That means all of your views and view helpers will have access to these methods
module ResourcefulViewsHelper

  # Calling content_for_object stores a block of markup in an identifier for later use.
  # You can make subsequent calls to the stored content in other templates or the layout
  # by passing the identifier as an argument to <tt>get_content_for_object</tt>.
  # 
  # ==== Example
  # 
  #   <% content_for_object(:listing_each) do | user | %>
  #     <li>User <%=user.name%> is a <%=user.role%></li>
  #   <% end %>
  # 
  # You can then use <tt>get_content_for_object :listing_each</tt> anywhere in your templates.
  #
  #   <ul>
  #   <% current_objects.each do |object| %>
  #     <%=get_content_for_object(:listing_each, object)%>
  #   <% end %>
  #   </ul>
  #
  # The rails way of accessing a content_for_block (either via <tt>yield :listing_each</tt> or via <tt>@listing_each</tt>)
  # will not work with content_for_object. (because of course, we need a way pass it an argument. 
  # That's the +object+ in +content_for_object+)
  def content_for_object(view, &block)
    @content_for_object_blocks ||= {}
    @content_for_object_blocks[view.to_sym] ||= []
    @content_for_object_blocks[view.to_sym] << block
  end
  
  # see also: +content_for_object+
  #
  # In addition for being the only way to retrieve content blocks declared with +content_for_object+,
  # this method can also retrieve content defined partials in either the folder for the current controller, 
  # or in the 'default' folder.
  # 
  # If asked to <tt>get_content_for_object(:listing_each, object)</tt> and we come from UsersController
  # * 1st we look for partials named _listing_each_defaults.* and execute them (not render)
  # * 2nd we look for previously defined calls to <tt>content_for_object(:listing_each)</tt>
  # If none are found:
  # * 3rd we look for file: /users/_listing_each.*
  # If not found: (and a theme is defined, for example 'admin')
  # * 4th we look for file: /themes/admin/_listing_each.*
  # If not found:
  # * 5th we look for file: /default/_listing_each.*
  #
  # In some cases, there may be multiple declarations of <tt>content_for_object(:listing_each)</tt> in contenxt
  # In which case, all of them will be called by <tt>get_content_for_object(:listing_each, object)</tt>
  def get_content_for_object(view, *objects)
    @content_for_object_blocks ||= {}
    @content_for_object_blocks[view.to_sym] ||= []

    run_defaults
    run_defaults(view)    
    if(@content_for_object_blocks[view.to_sym].empty?)      
      view_path = ResourcefulViews.determine_view_path(controller, view.to_s) do |path_base, path_last|
        resource_check_template_exists?("#{path_base}/_#{path_last}")
      end
      if view_path
        content_for_object(view.to_sym) do |obj|
          render :partial => view_path, :locals => {:current_object => obj}
        end
      end
    end  
    to_return = ""
    @content_for_object_blocks[view.to_sym].each do |proc|
      if(objects.size == 1 && proc.arity == 1)
        to_return += capture(objects[0], &proc)
      else
        to_return += capture(objects, &proc)
      end
    end
    to_return
  end
  
  # Retrieves any previous declaration of <tt>content_for(view)</tt> and and calls it with the prefered rails mechanism:
  # <tt>yield view.to_sym</tt>.
  #
  # If there was *NO* previous definition of <tt>content_for</tt> matching the +view+ param, 
  # then we set the content provided in the block as the content, and then yield (render it)
  #
  # I debated making a version of this method that would only store default content and not retrieve it, 
  # but I think this is the more common case.
  # 
  # This implementation of default_content_for is closely tied to the implementation details of how content_for is implemented in rails
  #
  # ==== Example
  # 
  # In /default/index.html.erb I might write
  #
  #   <% default_content_for(:title) do %>
  #     <h1><%= current_model.to_s.underscore.pluralize.humanize %></h1>
  #   <% end %>
  # 
  # And then I have a nice default implementation of a title on all my pages
  # 
  # But then just for the Users views I want a _different_ title, so:
  #
  # In /users/_index_defaults.html.erb I might write
  #   
  #   <% content_for(:title) do %>
  #     <h1>This is the index page for the users</h1>
  #   <% end %>
  #
  # So when the action +index+ is called on +UsersController+ I will end up rendering /defautl/index.html.erb as the view
  # But first, /users/_index_defaults.html.erb will be executed, which won't output anything, but will set a content_for(:title)
  # meaning that the call to <tt>default_content_for(:title)</tt> will spit out this Users specific title, while all my other calls
  # will still use the content defined in the block given to +default_content_for+
  #  
  def default_content_for(view, &block)
    if get_content_for(view).blank?
      # puts "content blank"
      eval "@content_for_#{view.to_s} = capture(&block)"
    end
    # puts "yielding #{view}, content should be " + eval("@content_for_#{view.to_s}").inspect
    concat(eval("yield :#{view.to_s}", block.binding))
  end
    
  # Basically the equivalent of 
  #    <%=yield :thing%>
  # assuming you have previously defined
  #     content_for(:thing) do
  #       ...
  #     end
  # Except, get_content_for goes the extra distance of searching more places in order to fulfill your content request
  # 
  # First, we execure 'defaults' for the requested content.  This means if you were asking for the content_for 'fields'
  # Then we're going to look for and run the first '_fields_defaults' partial we can find, and execute it, 
  # because it might define <tt>content_for(:fields)</tt> or at least something that has an affect on it.
  #
  # Next, we check if <tt>content_for(:fields)</tt> has been defined, and if so, we return that content.
  #
  # If not, then we'll look for a partial '_fields' in the appropriate order 
  # (current controller, current theme, default folder).
  # If we find such a partial, we render it and return it's contents.
  #
  # Example:
  #
  # If asked to <tt>get_content_for(:listing)</tt> and we come from UsersController
  # * 1st we look for partials named _listing_defaults.* and execute them (not render)
  # * 2nd we look for previously defined calls to <tt>content_for(:listing)</tt>
  # If none are found:
  # * 3rd we look for file: /users/_listing.*
  # If not found: (and a theme is defined, for example 'admin')
  # * 4th we look for file: /themes/admin/_listing.*
  # If not found:
  # * 5th we look for file: /default/_listing.*
  #
  def get_content_for(view)
    run_defaults
    run_defaults(view)
    view = view.to_s
    
    view_path = ResourcefulViews.determine_view_path(controller, view) do |path_base, path_last|
      resource_check_template_exists?("#{path_base}/_#{path_last}")
    end
    if view_path
      content_for(view) do
        render :partial => view_path
      end
    end
    
    to_return = eval "@content_for_#{view}"
    # logger.debug("get content is " + to_return.inspect)
    
    # puts "content for #{view} is #{to_return}"
    return to_return
  end
  
  # helper for retrivieng the name (as a symbol) of the currently executing action on the controller
  def current_action
    self.controller.action_name.to_sym
  end
    
  private
  
  # look for the definition of a 'defaults' file, this file should not be rendered, it should be executed
  # Most render_something methods will call run_defaults first to render any relevant _defaults partials 
  # based on the current action or requested content_for
  def run_defaults(view = current_action)
    @defaults_ran_for_resourceful_views ||= []
    unless @defaults_ran_for_resourceful_views.include?(view.to_sym)
      if resource_check_template_exists?(controller.class.controller_path + '/' + '_'+view.to_s+"_defaults")
      # if @template.file_exists?(controller.class.controller_path + '/' + '_'+view.to_s+"_defaults")
        render :partial => view.to_s+"_defaults"
      end
      @defaults_ran_for_resourceful_views << view.to_sym      
    end
  end
  
  #provides access to the controller method 'template_exists?'
  def resource_check_template_exists?(path) #:nodoc:
    controller.resource_check_template_exists?(path)
  end
  
end