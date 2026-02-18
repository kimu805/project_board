module ProjectsHelper
  def work_style_options
    Project.work_styles.keys.map { |key| [I18n.t("enums.project.work_style.#{key}"), key] }
  end

  def status_options
    Project.statuses.keys.map { |key| [I18n.t("enums.project.status.#{key}"), key] }
  end

  def work_style_label(project)
    I18n.t("enums.project.work_style.#{project.work_style}")
  end

  def status_label(project)
    I18n.t("enums.project.status.#{project.status}")
  end

  def status_indicator_class(project)
    case project.status
    when "upcoming"  then "bg-amber-400"
    when "active"    then "bg-emerald-400"
    when "completed" then "bg-gray-500"
    end
  end

  def status_text_class(project)
    case project.status
    when "upcoming"  then "text-amber-400"
    when "active"    then "text-emerald-400"
    when "completed" then "text-gray-500"
    end
  end

  def work_style_icon(project)
    if project.full_onsite?
      '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>'.html_safe
    else
      '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0a1 1 0 01-1-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 01-1 1h-2z"/></svg>'.html_safe
    end
  end

  def formatted_unit_price(price)
    number_to_currency(price, unit: "¥", precision: 0, delimiter: ",")
  end
end
