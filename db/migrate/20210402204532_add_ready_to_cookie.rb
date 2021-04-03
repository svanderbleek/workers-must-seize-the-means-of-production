class AddReadyToCookie < ActiveRecord::Migration[5.1]
  def change
    add_column :cookies, :ready, :boolean
  end
end
