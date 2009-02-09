ActionView::PathSet.class_eval do

  def find_template_with_extra_default_paths(original_template_path, format = nil)
    find_template_without_extra_default_paths(original_template_path, format)
  rescue ActionView::MissingTemplate => e_original        
    parts = original_template_path.split("/")
  
    theme = nil
    if self.respond_to?(:controller)
      if controller.respond_to?(:resourceful_views_theme)
        theme = controller.resourceful_views_theme(controller.action_name)
      end
    end
    if theme
      parts[0] = "themes/#{theme}"
      begin
        return find_template_without_extra_default_paths(parts.join("/"), format)
      rescue ActionView::MissingTemplate => e_theme
        #fall through to next
      end
    end
  
    parts = original_template_path.split("/")
    parts[0] = "default"
    
    begin
      find_template_without_extra_default_paths(parts.join("/"), format)
    rescue ActionView::MissingTemplate => e_default
      raise e_original
    end
  end

  alias_method_chain :find_template, :extra_default_paths

end

ActionController::Base.class_eval do
  
  def template_exists?(template_path)
    format = @template.template_format
    tempalte = @template.view_paths.find_template(template_path, format)
    true
  rescue ActionView::MissingTemplate => e
    false
  end
  
end

ActionView::Base.class_eval do

  def view_paths_with_controller_knowledge
    to_return = view_paths_without_controller_knowledge
    unless to_return.respond_to?(:controller)
      to_return.instance_eval do
        class << self
          attr_accessor :controller
        end
      end
      to_return.controller = self.controller
    end
    to_return
  end

  alias_method_chain :view_paths, :controller_knowledge

end
