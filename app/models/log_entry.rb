class LogEntry < ActiveRecord::Base
  belongs_to :command
  belongs_to :user
  attr_accessible :event_type, :log_text, :result, :command, :user
end
