class CreateUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :urls do |t|
      t.text :original_url
      t.string :short_url
      t.string :sanitized_url
      t.string :title
      t.integer :access_count, default: 1

      t.timestamps
    end
  end
end
