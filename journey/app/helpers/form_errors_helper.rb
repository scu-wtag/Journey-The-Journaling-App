module FormErrorsHelper
  def field_errors_for(record, attr)
    return '' unless field_invalid?

    content_tag :p, record.errors[attr].first, class: 'field-error', role: 'alert'
  end

  def field_invalid?(record, attr)
    record&.errors&.include?(attr) || false
  end
end
