class CreateModelFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :model_files do |t|
      t.timestamps
    end
  end
end
