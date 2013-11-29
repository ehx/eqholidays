class CreateEqholidays < ActiveRecord::Migration
  def change
    create_table :holidays_parms do |t|
      t.integer :days_min
      t.integer :days_max
      t.integer :days_holidays
    end

    create_table :holidays_users do |t|
      t.integer :id_user
      t.date :date_from
      t.date :date_to
      t.integer :days
    end
  end
end
