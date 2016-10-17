class KnowledgeAreaTeachingPlansController < ApplicationController
  has_scope :page, default: 1
  has_scope :per, default: 10

  before_action :require_current_school_calendar
  before_action :require_current_teacher

  def index
    @knowledge_area_teaching_plans = apply_scopes(KnowledgeAreaTeachingPlan)
      .includes(:knowledge_areas, teaching_plan: [:unity, :grade])
      .by_unity(current_user_unity)
      .by_grade(current_user_classroom.try(:grade_id))

    authorize @knowledge_area_teaching_plans

    fetch_grades
    fetch_knowledge_areas
  end

  def show
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.find(params[:id])
      .localized

    authorize @knowledge_area_teaching_plan

    fetch_collections
  end

  def new
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.new.localized
    @knowledge_area_teaching_plan.build_teaching_plan(
      year: current_school_calendar.year,
      unity: current_user_unity
    )

    authorize @knowledge_area_teaching_plan

    fetch_collections
  end

  def create
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.new(resource_params)
      .localized

    authorize @knowledge_area_teaching_plan

    @knowledge_area_teaching_plan.teaching_plan.teacher_id = current_teacher.id
    @knowledge_area_teaching_plan.knowledge_area_ids = resource_params[:knowledge_area_ids].split(',')

    if @knowledge_area_teaching_plan.save
      respond_with @knowledge_area_teaching_plan, location: knowledge_area_teaching_plans_path
    else
      fetch_collections

      render :new
    end
  end

  def edit
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.find(params[:id])
      .localized

    authorize @knowledge_area_teaching_plan

    fetch_collections
  end

  def update
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.find(params[:id])
      .localized
    @knowledge_area_teaching_plan.assign_attributes(resource_params)
    @knowledge_area_teaching_plan.knowledge_area_ids = resource_params[:knowledge_area_ids].split(',')

    authorize @knowledge_area_teaching_plan

    if @knowledge_area_teaching_plan.save
      respond_with @knowledge_area_teaching_plan, location: knowledge_area_teaching_plans_path
    else
      fetch_collections

      render :edit
    end
  end

  def destroy
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.find(params[:id])
      .localized

    authorize @knowledge_area_teaching_plan

    @knowledge_area_teaching_plan.destroy

    respond_with @knowledge_area_teaching_plan, location: knowledge_area_teaching_plans_path
  end

  def history
    @knowledge_area_teaching_plan = KnowledgeAreaTeachingPlan.find(params[:id])

    authorize @knowledge_area_teaching_plan

    respond_with @knowledge_area_teaching_plan
  end

  private

  def resource_params
    params.require(:knowledge_area_teaching_plan).permit(
      :knowledge_area_ids,
      teaching_plan_attributes: [
        :id,
        :year,
        :unity_id,
        :grade_id,
        :school_term_type,
        :school_term,
        :objectives,
        :content,
        :methodology,
        :evaluation,
        :references,
        :teacher_id,
        contents_attributes: [
          :id,
          :description,
          :_destroy
        ]
      ]
    )
  end

  def fetch_collections
    fetch_knowledge_areas
  end

  def contents
    Content.ordered
  end
  helper_method :contents

  def fetch_unities
    @unities = Unity.by_teacher(current_teacher).ordered
  end

  def fetch_grades
    @grades = Grade.where(id: current_user_classroom.grade_id)
      .ordered
  end

  def fetch_knowledge_areas
    @knowledge_areas = KnowledgeArea.ordered
  end
end
