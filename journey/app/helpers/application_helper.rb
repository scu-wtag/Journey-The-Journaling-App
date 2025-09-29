module ApplicationHelper
  def error_for(record, attr)
    errs = record&.errors
    return '' unless errs && errs[attr].present?

    errs[attr].first
  end

  def has_error?(record, attr)
    errs = record&.errors
    errs && errs[attr].present?
  end
end
