class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :uid
      t.string :cn
      t.integer :uidNumber
      t.string :picture
      t.integer :gidNumber
      t.string :mail
      t.string :firstName
      t.string :lastName

      t.timestamps
    end
  end
end
