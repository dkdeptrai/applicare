class AddRepairerNoteToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :repairer_note, :text
  end
end
