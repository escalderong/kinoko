class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # dependent: :destroy cascades call plain #destroy (not #destroy!) on each
  # associated record, so when a dependent: :restrict_with_error guard blocks
  # the delete somewhere deeper in that cascade, the whole chain returns
  # false SILENTLY — no exception — and the error lands on the blocked CHILD
  # record, never on the record #destroy was actually called on. Without
  # this, a blocked cascade fails with no way for the caller to know why.
  def destroy
    super.tap do |destroyed|
      errors.add(:base, :cannot_destroy_dependent_records) if !destroyed && errors.empty?
    end
  end
end
