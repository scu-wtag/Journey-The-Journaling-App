module ApplicationHelper
  def field_errors_for(record, attr)
    return '' unless record&.errors&.[](attr)&.any?

    content_tag :p, record.errors[attr].first, class: 'field-error', role: 'alert'
  end

  def field_invalid?(record, attr)
    record&.errors&.[](attr)&.any?
  end
end
