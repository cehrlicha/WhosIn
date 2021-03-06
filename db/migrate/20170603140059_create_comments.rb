class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.text :comment
      t.references :invitation, foreign_key: true
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
