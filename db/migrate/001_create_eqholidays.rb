class CreateEqholidays < ActiveRecord::Migration

    def up 
        create_table :holidays_parms , :force => true do |t|
          t.integer :days_min
          t.integer :days_max
          t.integer :days_holidays
        end
    
        create_table :holidays_users , :force => true do |t|
          t.integer :id_user
          t.date :date_from
          t.date :date_to
          t.integer :days
        end
        
        create_table :holidays_free_days , :force => true do |t|
          t.date :date_free_day
          t.boolean :enable
        end
    
        create_table :holidays_acums , :force => true do |t|
          t.integer :period
          t.integer :id_user
          t.integer :days
        end
    end
    
end