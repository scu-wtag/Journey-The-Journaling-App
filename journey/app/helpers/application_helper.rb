module ApplicationHelper
  def error_for(record, attr)
    error_messages = record&.errors
    return '' unless error_messages && error_messages[attr].present?

    error_messages[attr].first
  end

  def has_error?(record, attr)
    record&.errors&.include?(attr)
  end
end
