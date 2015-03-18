class TaskDraft < ActiveRecord::Base
  has_many :children, class_name: "TaskDraft", foreign_key: "parent_id", :dependent => :destroy
  belongs_to :parent, class_name: "TaskDraft"
	belongs_to :user
	belongs_to :firm
	belongs_to :task_list
  has_many :tasks

  accepts_nested_attributes_for :children, :reject_if => :all_blank, :allow_destroy => true
  validates :due_term, :numericality => { :greater_than_or_equal_to => 0 }

  ANCHOR_DATE = ['close date', 'case open', 'incident date', 'statute of limitations', 'trial date']
  BEFORE_ANCHOR_DATE = ['close date', 'statute of limitations', 'trial date']

  def return_due_date(affair, parent=nil)
    due_date = nil
    if self.conjunction.downcase == 'after'
      case self.anchor_date
        when 'case open'
          due_date = affair.created_at + self.due_term.days
        when 'incident date'
          due_date = affair.incident.incident_date + self.due_term.days if affair.incident.incident_date.present?
        when 'statute of limitations'
          due_date = affair.incident.statute_of_limitations + self.due_term.days if affair.incident.incident_date.present?
        when 'trial date'
          due_date = affair.trial_date + self.due_term.days if affair.trial_date.present?
        when 'parent'
          due_date = parent.due_date + self.due_term.days if parent.due_date.present?
        when 'close date'
          due_date = affair.closing_date + self.due_term.days if affair.closing_date.present?
      end
    elsif self.conjunction.downcase == 'before'
      case self.anchor_date
        when 'trial date'
          due_date = affair.trial_date - self.due_term.days if affair.trial_date.present?
        when 'statute of limitations'
          due_date = incident.statute_of_limitations - self.due_term.days if incident.incident_date.present?
        when 'close date'
          due_date = affair.closing_date - self.due_term.days if affair.closing_date.present?
        when 'previous task'
          due_date = parent.due_date - self.due_term.days if parent.due_date.present?
      end
    end
    return due_date
  end
end
