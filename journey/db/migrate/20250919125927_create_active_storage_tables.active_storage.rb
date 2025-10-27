class CreateActiveStorageTables < ActiveRecord::Migration[7.0]
  def change
    @pk_type, @fk_type = primary_and_foreign_key_types

    create_active_storage_blobs
    create_active_storage_attachments
    create_active_storage_variant_records
  end

  private

  def primary_and_foreign_key_types
    config = Rails.configuration.generators
    setting = config.options[config.orm][:primary_key_type]
    primary_key_type = setting || :primary_key
    foreign_key_type = setting || :bigint
    [primary_key_type, foreign_key_type]
  end

  def create_active_storage_blobs
    create_table :active_storage_blobs, id: @pk_type do |time|
      add_blob_columns(time)
      add_created_at(time)
      add_blob_indexes(time)
    end
  end

  def add_blob_columns(time)
    time.string :key, null: false
    time.string :filename, null: false
    time.string :content_type
    time.text :metadata
    time.string :service_name, null: false
    time.bigint :byte_size, null: false
    time.string :checksum
  end

  def add_blob_indexes(time)
    time.index [:key], unique: true
  end

  def create_active_storage_attachments
    create_table :active_storage_attachments, id: @pk_type do |_t|
      time.string :name, null: false
      time.references :record, null: false, polymorphic: true, index: false, type: @fk_type
      time.references :blob, null: false, type: @fk_type

      add_created_at(time)

      time.index %i(record_type record_id name blob_id),
                 name: :index_active_storage_attachments_uniqueness,
                 unique: true
      time.foreign_key :active_storage_blobs, column: :blob_id
    end
  end

  def create_active_storage_variant_records
    create_table :active_storage_variant_records, id: @pk_type do |time|
      time.belongs_to :blob, null: false, index: false, type: @fk_type
      time.string :variation_digest, null: false

      time.index %i(blob_id variation_digest),
                 name: :index_active_storage_variant_records_uniqueness,
                 unique: true
      time.foreign_key :active_storage_blobs, column: :blob_id
    end
  end

  def add_created_at(_time)
    if connection.supports_datetime_with_precision?
      time.datetime :created_at, precision: 6, null: false
    else
      time.datetime :created_at, null: false
    end
  end
end
