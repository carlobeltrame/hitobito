# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
# == Schema Information
#
# Table name: invoices
#
#  id                :integer          not null, primary key
#  title             :string(255)      not null
#  sequence_number   :string(255)      not null
#  state             :string(255)      default("draft"), not null
#  esr_number        :string(255)      not null
#  description       :text(65535)
#  recipient_email   :string(255)
#  recipient_address :text(65535)
#  sent_at           :date
#  due_at            :date
#  group_id          :integer          not null
#  recipient_id      :integer          not null
#  total             :decimal(12, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Invoice < ActiveRecord::Base
  include I18nEnums

  STATES = %w(draft sent payed overdue cancelled).freeze

  belongs_to :group
  belongs_to :recipient, class_name: 'Person'
  has_many :invoice_items, dependent: :destroy

  before_validation :set_sequence_number, on: :create, if: :group
  before_validation :set_esr_number, on: :create, if: :group
  before_validation :set_dates, on: :update, if: :sent?
  before_validation :set_recipient_fields, on: :create, if: :recipient
  before_validation :set_self_in_nested
  before_validation :recalculate

  validates :state, inclusion: { in: STATES }
  validates :due_at, timeliness: { after: :sent_at }, if: :sent?
  validates :due_at, presence: true, if: :sent?

  after_create :increment_sequence_number
  after_create :set_recipient_fields

  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  i18n_enum :state, STATES

  validates_by_schema

  scope :list,       -> { where.not(state: :cancelled).order(:title, :state) }
  scope :draft,      -> { where(state: :draft) }
  scope :sent,       -> { where(state: :sent) }

  def multi_create(people)
    people.collect do |person|
      Invoice.transaction do
        invoice = self.class.new(build_attributes(person))
        invoice_items.each do |invoice_item|
          invoice.invoice_items.build(invoice_item.attributes)
        end
        invoice.save
      end
    end
  end

  def calculated
    %i(total cost vat).collect do |field|
      [field, invoice_items.to_a.sum(&field)]
    end.to_h
  end

  def recalculate
    self.total = invoice_items.to_a.sum(&:total) || 0
  end

  def to_s
    "#{title}(#{sequence_number}): #{total}"
  end

  def sent?
    state == 'sent'
  end

  def invoice_config
    group.invoice_config
  end

  private

  def set_self_in_nested
    invoice_items.each { |item| item.invoice = self }
  end

  def set_sequence_number
    self.sequence_number = [group_id, invoice_config.sequence_number].join('-')
  end

  def set_esr_number
    self.esr_number = sequence_number
  end

  def set_dates
    self.sent_at = Time.zone.today
    self.due_at = sent_at + invoice_config.due_days.days
  end

  def set_recipient_fields
    self.recipient_email = recipient.email
    self.recipient_address = build_recipient_address
  end

  def item_invalid?(attributes)
    !InvoiceItem.new(attributes.merge(invoice: self)).valid?
  end

  def increment_sequence_number
    invoice_config.increment!(:sequence_number)
  end

  def build_recipient_address
    [recipient.full_name,
     recipient.address,
     [recipient.zip_code, recipient.town].compact.join(' / '),
     recipient.country].compact.join("\n")
  end

  def build_attributes(person)
    attributes.merge(recipient: person,
                     address: invoice_config.address,
                     iban: invoice_config.iban,
                     account_number: invoice_config.account_number)
  end

end
