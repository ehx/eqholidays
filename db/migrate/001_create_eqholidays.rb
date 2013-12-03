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
        
        execute "ALTER TABLE `holidays_acums` ADD UNIQUE (`period` ,`id_user`);"
        execute "INSERT INTO `holidays_parms` (`id`, `days_min`, `days_max`, `days_holidays`) VALUES (1, 0, 183, 5), (2, 183, 730, 10), (3, 730, 1460, 15), (4, 1460, 3650, 20),(5, 3650, 99999, 25);"
    end
    
end