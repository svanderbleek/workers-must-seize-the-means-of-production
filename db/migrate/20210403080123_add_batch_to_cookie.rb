class AddBatchToCookie < ActiveRecord::Migration[5.1]
  def change
    add_column :cookies, :batch, :integer, default: 1
  end
end
