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

  def status_badge_class(project)
    case project.status
    when "upcoming"
      "bg-yellow-100 text-yellow-800"
    when "active"
      "bg-green-100 text-green-800"
    when "completed"
      "bg-gray-100 text-gray-800"
    end
  end

  def formatted_unit_price(price)
    number_to_currency(price, unit: "¥", precision: 0, delimiter: ",")
  end
end
