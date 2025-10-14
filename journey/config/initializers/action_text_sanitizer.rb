ActiveSupport.on_load(:action_text) do
  if defined?(ActionText::ContentHelper)
    attrs = ActionText::ContentHelper.allowed_attributes
    attrs = [] unless attrs.is_a?(Array)
    ActionText::ContentHelper.allowed_attributes = (attrs + ['class']).uniq
  end
end
