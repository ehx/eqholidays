class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|

      t.integer :period
      t.integer :user_id
      t.integer :days
      t.integer :days_consumed

    end
  end
end
