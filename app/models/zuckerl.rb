class Zuckerl < ApplicationRecord
  extend FriendlyId
  include AASM

  attachment :image, type: :image
  friendly_id :title
  attr_accessor :active_admin_requested_event

  belongs_to :location
  has_one :graetzl, through: :location
  belongs_to :initiative

  after_commit :send_booking_confirmation, on: :create, if: proc {|zuckerl| zuckerl.pending?}

  validates :title, length: { in: 4..80 }

  aasm do
    state :pending, initial: true
    state :draft
    state :paid
    state :live
    state :cancelled
    state :expired

    event :mark_as_paid, guard: lambda { paid_at.blank? }, after: :send_invoice do
      transitions from: :pending, to: :paid
      transitions from: :live, to: :live
    end

    event :put_live, after: :send_live_information do
      transitions from: [:pending, :draft, :paid], to: :live
    end

    event :expire do
      transitions from: :live, to: :expired
    end

    event :cancel do
      transitions to: :cancelled
    end
  end

  def self.include_for_box
    includes(location: [:graetzl, :category, :address])
  end

  def payment_reference
    "#{model_name.singular}_#{id}_#{created_at.strftime('%y%m')}"
  end

  private

  def send_booking_confirmation
    AdminMailer.new_zuckerl(self).deliver_later
    Zuckerl::BookingConfirmationJob.perform_later self
  end

  def send_invoice
    update paid_at: Time.now
    Zuckerl::InvoiceJob.perform_later self
  end

  def send_live_information
    Zuckerl::LiveInformationJob.perform_later self
  end
end
