class Notification < ActiveRecord::Base
    
  include Rails.application.routes.url_helpers  
  
  EVENTS = {
    0 => :user_created,
    1 => :received_message,
    2 => :sent_message,
    3 => :saved_rental,
    4 => :unsaved_rental,
    5 => :created_open_house,
    6 => :deleted_open_house,
    7 => :attend_open_house,
    8 => :attendee_added,
    9 => :unattend_open_house,
    10 => :attendee_dropped
  }
  
  EVENT_IDS = EVENTS.invert
  
  belongs_to :notifiable, polymorphic: true
  
  belongs_to :user, inverse_of: :notifications, counter_cache: true
  
  validates :notifiable_id, :notifiable_type, :user_id, :event_id, presence: true
  
  after_validation :send_email, on: :create
  
  scope :read, -> { where(is_read: true) }
  scope :unread, -> { where(is_read: false) }
  scope :event, ->(event_name) { where(event_id: EVENT_IDS[event_name]) }
  
  def url
    event = EVENTS[self.event_id]
    case event
    when :user_created
      rentals_path
    when :received_message
      message_path(self.notifiable)
    when :sent_message
      message_path(self.notifiable)
    when :saved_rental
      rental_path(self.notifiable)
    when :unsaved_rental
      rental_path(self.notifiable)
    when :attend_open_house
      rental_path(self.notifiable.rental.id)
    when :attendee_added
      rental_path(self.notifiable.rental.id)
    when :unattend_open_house
      rental_path(self.notifiable.rental.id)
    when :attendee_dropped
      rental_path(self.notifiable.open_house.rental.id)
    end
  end
  
  def text
    event = EVENTS[self.event_id]
    case event
    when :user_created
      return "Welcome to StreetEZ #{self.notifiable.name}. We are glad you chose StreetEZ to help you with your apartment search."
    when :received_message
      return "You received a message from #{self.notifiable.sender.name}."
    when :sent_message
      return "You sent a message to #{self.notifiable.recipient.name}."
    when :saved_rental
      return "You saved #{self.notifiable.address.street} to your profile."
    when :unsaved_rental
      return "You removed #{self.notifiable.address.street} from your profile."
    when :attend_open_house
      street = self.notifiable.rental.address.street
      datetime = self.notifiable.event_datetime
      return "You signed up to attend the open house for #{street} on #{datetime.to_formatted_s(:long)}."
    when :attendee_added
      
    when :unattend_open_house
      street = self.notifiable.rental.address.street
      datetime = self.notifiable.event_datetime
      if self.notifiable.active
        return "You are no longer scheduled to attend the open house for #{street} on #{datetime.to_formatted_s(:long)}."
      else
        return "The open house at #{street} on #{datetime.to_formatted_s(:long)} that you were scheduled to attend has been cancelled."
      end
    when :attendee_dropped
      
    end
  end
  
  def default_url_options
    options = {}
    options[:host] = Rails.env.production? ? "streetez.herokuapp.com" : "localhost:3000"
    options
  end
  
  def send_email
    if self.event_id == 0
      msg = UserMailer.welcome_email(self)
      msg.deliver!
    end
  end
  
end
