class ProjectTimeline
  attr_reader :projects, :timeline_start, :timeline_end, :total_days

  def initialize(projects)
    @projects = projects.order(:start_date).to_a
    build_range if @projects.any?
  end

  def empty?
    @projects.empty?
  end

  def months
    return [] if empty?

    result = []
    month = timeline_start
    while month <= timeline_end
      result << month
      month = month.next_month
    end
    result
  end

  def bar_left_pct(project)
    ((project.start_date - timeline_start).to_f / total_days * 100).round(4)
  end

  def bar_width_pct(project)
    effective_end = project.end_date || Date.today
    ((effective_end - project.start_date).to_f / total_days * 100).round(4)
  end

  def month_left_pct(month)
    ((month - timeline_start).to_f / total_days * 100).round(4)
  end

  private

  def build_range
    @timeline_start = @projects.map(&:start_date).min.beginning_of_month
    @timeline_end   = [ @projects.map(&:end_date).compact.max, Date.today ].compact.max.end_of_month
    @total_days     = (@timeline_end - @timeline_start).to_i
  end
end
