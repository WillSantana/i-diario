class DropFunctionCheckUniqueConceptualExams < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP FUNCTION check_conceptual_exam_is_unique(INT, INT, INT, INT, TIMESTAMP);
    SQL
  end
end
