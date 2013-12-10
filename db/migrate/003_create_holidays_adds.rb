class CreateHolidaysAdds < ActiveRecord::Migration
  def change
    create_table :holidays_adds do |t|

      t.date :date

      t.integer :user_id

      t.integer :days

      t.text :comment


    end

  end
end
