# frozen_string_literal: true

require 'thor'
require 'fileutils'

module XanoExporter
  class CLI < Thor
    desc "export", "Export data from Xano, generate schema and models"
    option :auth_token, type: :string, required: true, desc: "Xano API authentication token"
    option :workspace_id, type: :string, required: true, desc: "Xano workspace ID"
    option :base_url, type: :string, desc: "Base URL for Xano API"
    option :csv_dir, type: :string, default: "csv_exports", desc: "Directory for CSV exports"
    option :schema_path, type: :string, default: "outputs/schema.rb", desc: "Path for generated schema.rb"
    option :models_dir, type: :string, default: "outputs/models", desc: "Directory for generated models"
    option :generate_models, type: :boolean, default: false, desc: "Generate ActiveRecord models"
    def export
      client = Client.new(
        options[:auth_token],
        options[:workspace_id],
        options[:base_url],
        options[:csv_dir]
      )

      client.export_all_tables_to_csv
      puts "Export completed successfully to #{options[:csv_dir]}"

      schema_generator = SchemaGenerator.new
      schema_generator.generate_schema(tables_data, options[:schema_path])


      if options[:generate_models]
        model_generator = ModelGenerator.new
        model_generator.generate_models(tables_data, options[:models_dir])
      end
    end

    desc "generate_schema", "Generate Rails schema.rb from CSV exports"
    option :csv_dir, default: "csv_exports", desc: "Directory containing CSV exports"
    option :output_file, default: "schema.rb", desc: "Output schema file path"
    def generate_schema
      generator = SchemaGenerator.new(options[:csv_dir], options[:output_file])
      generator.generate_schema
    end

    desc "generate_models", "Generate ActiveRecord model files from CSV exports"
    option :csv_dir, default: "csv_exports", desc: "Directory containing CSV exports"
    option :models_dir, default: "app/models", desc: "Directory to store model files"
    def generate_models
      generator = ModelGenerator.new(options[:csv_dir], options[:models_dir])
      generator.generate_models
    end

    desc "full_export", "Export data, generate schema and optionally models"
    option :auth_token, required: true, desc: "Xano API authentication token"
    option :workspace_id, default: "1", desc: "Xano workspace ID"
    option :base_url, desc: "Xano API base URL (optional)"
    option :csv_dir, default: "csv_exports", desc: "Directory to store CSV exports"
    option :output_file, default: "schema.rb", desc: "Output schema file path"
    option :models_dir, default: "app/models", desc: "Directory to store model files"
    option :generate_models, type: :boolean, default: false, desc: "Generate ActiveRecord models"
    def full_export
      # Step 1: Export data
      invoke :export

      # Step 2: Generate schema
      invoke :generate_schema

      # Step 3: Generate models (optional)
      if options[:generate_models]
        invoke :generate_models
      end

      puts "Full export process completed successfully!"
    end

    def self.exit_on_failure?
      true
    end
  end
end