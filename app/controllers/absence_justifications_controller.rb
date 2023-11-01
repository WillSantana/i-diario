class AbsenceJustificationsController < ApplicationController
  before_action :require_current_teacher
  before_action :require_current_classroom

  has_scope :page, default: 1
  has_scope :per, default: 10

  before_action :require_allow_to_modify_prev_years, only: [:create, :update, :destroy]

  def index
    set_options_by_user

    author_type = (params[:search] || []).delete(:by_author)

    @absence_justifications = fetch_absence_justifications_by_user

    if author_type.present?
      user_id = UserDiscriminatorService.new(current_user, current_user.current_role_is_admin_or_employee?).user_id

      @absence_justifications = @absence_justifications.by_author(author_type, user_id)
      params[:search][:by_author] = author_type
    end

    authorize @absence_justifications
  end

  def new
    @absence_justification = AbsenceJustification.new.localized
    @absence_justification.absence_date = Time.zone.today
    @absence_justification.teacher = current_teacher
    @absence_justification.unity = current_unity
    @absence_justification.school_calendar = current_school_calendar
    @absence_justification.classroom = current_user_classroom
    is_frequency_by_discipline?
    set_options_by_user
    fetch_unities
    fetch_students

    authorize @absence_justification
  end

  def show
    set_options_by_user
    @absence_justification = AbsenceJustification.includes(
      absence_justifications_students: [{
        daily_frequency_students: { daily_frequency: [:discipline] }
      }, :student]
    ).find(params[:id]).localized

    authorize @absence_justification

    @absences_justified = []

    @absence_justification.absence_justifications_students.each do |absence_justifications_students|
      absence_justifications_students.daily_frequency_students.each do |daily_frequency_students|
        @absences_justified << {
          student_name: absence_justifications_students.student.name,
          frequency_date: daily_frequency_students.daily_frequency.frequency_date.to_date.strftime('%d/%m/%Y'),
          class_number: daily_frequency_students.daily_frequency.class_number || 0,
          discipline_name: daily_frequency_students.daily_frequency.discipline&.description || 'Geral',
        }
      end
    end

    @absences_justified = @absences_justified.sort { |a,b| a[:class_number] <=> b[:class_number] }
    @absences_justified = @absences_justified.sort { |a,b| a[:frequency_date] <=> b[:frequency_date] }
    @absences_justified = @absences_justified.sort { |a,b| a[:student_name] <=> b[:student_name] }

    fetch_students
  end

  def create
    class_numbers = class_numbers(params[:absence_justification][:class_number]&.split(','))
    @frequency_by_discipline, absence_justifications, @absence_justification = CreateAbsenceJustificationsService.call(
      class_numbers, resource_params, current_teacher, current_unity, current_school_calendar, current_user
    )
    absence_justifications.map{ |absence_justification| authorize absence_justification }
    valid = absence_justifications.map(&:persisted?).reject { |is_valid| is_valid }.empty?

    parameters = params[:absence_justification]

    # Se vier da tela de lancamento de frequência em lote, redireciona para ela
    redirect_to_daily_frequencies_in_batchs(valid, parameters)
    # Se vier da tela de lancamento de diário de frequência
    redirect_to_daily_frequencies(valid, parameters)

    if valid
      respond_with @absence_justification, location: absence_justifications_path
    else
      clear_invalid_dates
      set_options_by_user
      fetch_unities
      fetch_students
      render :new
    end
  end

  def edit
    @absence_justification = AbsenceJustification.find(params[:id]).localized
    @absence_justification.unity = current_unity
    fetch_unities
    fetch_students
    is_frequency_by_discipline?

    authorize @absence_justification
  end

  def update
    @absence_justification = AbsenceJustification.find(params[:id])
    @absence_justification.assign_attributes resource_params_edit
    @absence_justification.current_user = current_user
    is_frequency_by_discipline?

    if @absence_justification.persisted? && @absence_justification.school_calendar.blank?
      @absence_justification.school_calendar = current_school_calendar
    end

    fetch_unities

    authorize @absence_justification

    if @absence_justification.save
      respond_with @absence_justification, location: absence_justifications_path
    else
      clear_invalid_dates
      render :edit
      fetch_unities
      is_frequency_by_discipline?
    end
  end

  def destroy
    @absence_justification = AbsenceJustification.find(params[:id])

    @absence_justification.destroy

    respond_with @absence_justification, location: absence_justifications_path
  end

  def history
    @absence_justification = AbsenceJustification.find(params[:id])

    authorize @absence_justification

    respond_with @absence_justification
  end

  def redirect_to_daily_frequencies_in_batchs(valid, parameters)
    return if valid.blank? && parameters.blank?

    redirect_to form_daily_frequencies_in_batchs_path(
      frequency_in_batch_form: {
        start_date: parameters[:start_date],
        end_date: parameters[:end_date]
      }
    ) && return
  end

  def redirect_to_daily_frequencies(valid, parameters)
    return if valid.blank? && parameters[:frequency_date].blank?

    redirect_to form_daily_frequencies_path(
      unity_id: parameters[:unity_id],
      classroom_id: parameters[:classroom_id],
      frequency_date: parameters[:frequency_date],
      discipline_id: parameters[:discipline_id],
      period: parameters[:period],
      class_numbers: parameters[:class_numbers_original]
    ) && return
  end

  protected

  def resource_params
    parameters = params.require(:absence_justification).permit(
      :student_ids,
      :absence_date,
      :justification,
      :absence_date_end,
      :unity_id,
      :classroom_id,
      :period,
      absence_justification_attachments_attributes: [
        :id,
        :attachment,
        :_destroy
      ]
    )

    parameters[:student_ids] = parameters[:student_ids].split(',')

    parameters
  end

  def resource_params_edit
    params.require(:absence_justification).permit(
      :justification,
      absence_justification_attachments_attributes: [
        :id,
        :attachment,
        :_destroy
      ]
    )
  end

  private

  def class_numbers(class_numbers)
    [nil] if class_numbers.empty? || class_numbers.nil?
  end

  def filtering_params(params)
    if params
      params.slice(:by_classroom, :by_student, :by_date, :by_author)
    else
      {}
    end
  end

  protected

  def fetch_students
    student_enrollments = StudentEnrollmentsList.new(
      classroom: @absence_justification.classroom,
      discipline: nil,
      search_type: :by_date,
      date: Date.current
    ).student_enrollments

    student_ids = student_enrollments.collect(&:student_id)
    @students = Student.where(id: student_ids)
  end

  def fetch_unities
    @unities = Unity.by_teacher(current_teacher_id).ordered
  end

  def configuration
    @configuration ||= IeducarApiConfiguration.current
  end

  def is_frequency_by_discipline?
    if @is_frequency_by_discipline.nil?
      frequency_type_definer = FrequencyTypeDefiner.new(
        @absence_justification.classroom,
        current_teacher
      )
      frequency_type_definer.define!

      @is_frequency_by_discipline = frequency_type_definer.frequency_type == FrequencyTypes::BY_DISCIPLINE
    end

    @is_frequency_by_discipline
  end

  def clear_invalid_dates
    begin
      resource_params[:absence_date].to_date
    rescue ArgumentError
      @absence_justification.absence_date = ''
    end

    begin
      resource_params[:absence_date_end].to_date
    rescue ArgumentError
      @absence_justification.absence_date_end = ''
    end
  end

  def fetch_absence_justifications_by_user
    apply_scopes(
      AbsenceJustification.includes(:teacher)
                          .includes(:classroom)
                          .includes(:unity)
                          .joins(:absence_justifications_students)
                          .by_unity(current_unity)
                          .where(classroom_id: @classrooms.map(&:id))
                          .by_school_calendar(current_school_calendar)
                          .filter(filtering_params(params[:search]))
                          .includes(:students).distinct.ordered
    )
  end

  def set_options_by_user
    if current_user.current_role_is_admin_or_employee?
      @classrooms ||= [current_user_classroom]
    else
      fetch_linked_by_teacher
    end
  end

  def fetch_linked_by_teacher
    @fetch_linked_by_teacher ||= TeacherClassroomAndDisciplineFetcher.fetch!(current_teacher.id, current_unity, current_school_year)
    @classrooms ||= @fetch_linked_by_teacher[:classrooms]
    @exam_rules_ids ||= @fetch_linked_by_teacher[:classroom_grades].map(&:exam_rule_id)
  end
end
