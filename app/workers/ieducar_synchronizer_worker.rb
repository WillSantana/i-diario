class IeducarSynchronizerWorker
  include Sidekiq::Worker

  def perform(entity_id = nil, synchronization_id = nil)
    if entity_id
      entity = Entity.find(entity_id)
      perform_for_entity(entity, synchronization_id)
    else
      all_entities.each do |entity|
        perform_for_entity(entity, synchronization_id)
      end
    end
  end

  private

  def perform_for_entity(entity, synchronization_id)
    entity.using_connection do
      unless synchronization = IeducarApiSynchronization.find_by_id(synchronization_id)
        configuration = IeducarApiConfiguration.current
        break unless configuration.persisted?
        synchronization = configuration.start_synchronization!(User.first)
      end

      begin
        KnowledgeAreasSynchronizer.synchronize!(synchronization)
        DisciplinesSynchronizer.synchronize!(synchronization)
        StudentsSynchronizer.synchronize!(synchronization)
        DeficienciesSynchronizer.synchronize!(synchronization)
        ***REMOVED***sSynchronizer.synchronize!(synchronization)
        RoundingTablesSynchronizer.synchronize!(synchronization)
        RecoveryExamRulesSynchronizer.synchronize!(synchronization)
        TeachersSynchronizer.synchronize!(synchronization, years_to_synchronize)
        CoursesGradesClassroomsSynchronizer.synchronize!(synchronization)
        StudentEnrollmentDependenceSynchronizer.synchronize!(synchronization, years_to_synchronize)

        years_to_synchronize.each do |year|
          ExamRulesSynchronizer.synchronize!(synchronization, year)
          Unity.with_api_code.each do |unity|
            StudentEnrollmentSynchronizer.synchronize!(synchronization, year, unity.api_code)
          end
        end

        StudentEnrollmentExemptedDisciplinesSynchronizer.synchronize!(synchronization)

        synchronization.mark_as_completed!
      rescue IeducarApi::Base::ApiError => e
        synchronization.mark_as_error!(e.message)
      rescue Exception => exception
        synchronization.mark_as_error!('Ocorreu um erro desconhecido.')

        raise exception
      end
    end
  end

  def years_to_synchronize
    Unity.with_api_code.map { |unity| CurrentSchoolYearFetcher.new(unity).fetch }
         .uniq
         .reject(&:blank?)
         .sort
  end

  def all_entities
    Entity.all
  end

end
