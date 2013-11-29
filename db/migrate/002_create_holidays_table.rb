class CreateEqholidays < ActiveRecord::Migration
    create_table :holidays_free_days do |t|
      t.date :date_free_day
      t.boolean :enable
    end
end
