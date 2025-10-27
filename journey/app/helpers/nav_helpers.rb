module NavHelpers
  def nav_btn(icon:, title:)
    content_tag(:button, type: 'button', class: 'nav-btn', title: title, aria: { label: title }) do
      icon_svg(icon)
    end
  end

  private

  def icon_svg(icon)
    case icon.to_sym
    when :dashboard
      raw %(
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="8" height="8"/>
          <rect x="13" y="3" width="8" height="5"/>
          <rect x="13" y="10" width="8" height="11"/>
          <rect x="3" y="13" width="8" height="8"/>
        </svg>
      )
    when :profile
      raw %(
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="12" cy="8" r="4"/>
          <path d="M4 20c0-4 4-6 8-6s8 2 8 6"/>
        </svg>
      )
    when :new
      raw %(
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M12 5v14M5 12h14"/>
        </svg>
      )
    when :tasks
      raw %(
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="6" y="4" width="12" height="16" rx="2"/>
          <path d="M9 4h6v3H9zM9 10h6M9 14h6"/>
        </svg>
      )
    else
      ''
    end
  end
end
