# XanoExporter

A Ruby gem that exports data from Xano API to CSV files, generates a Rails-compatible schema.rb, and optionally creates ActiveRecord model files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xano_exporter'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install xano_exporter
```

## Usage

### Command Line Interface

XanoExporter provides a command-line interface for easy usage:

#### Export data from Xano API to CSV files

```bash
$ xano_exporter export --auth-token YOUR_AUTH_TOKEN --workspace-id YOUR_WORKSPACE_ID
```

#### Generate Rails schema.rb from CSV exports

```bash
$ xano_exporter generate_schema
```

#### Generate ActiveRecord model files from CSV exports

```bash
$ xano_exporter generate_models
```

#### Full export process (export data, generate schema, and optionally models)

```bash
$ xano_exporter full_export --auth-token YOUR_AUTH_TOKEN --workspace-id YOUR_WORKSPACE_ID --generate-models
```

### Ruby API

You can also use XanoExporter in your Ruby code:

```ruby
require 'xano_exporter'

# Export data from Xano API to CSV files
client = XanoExporter::Client.new('YOUR_AUTH_TOKEN', 'YOUR_WORKSPACE_ID')
client.export_all_tables_to_csv

# Generate Rails schema.rb from CSV exports
schema_generator = XanoExporter::SchemaGenerator.new
schema_generator.generate_schema

# Generate ActiveRecord model files from CSV exports
model_generator = XanoExporter::ModelGenerator.new
model_generator.generate_models
```

## Configuration Options

### Export Options

- `--auth-token`: Xano API authentication token (required)
- `--workspace-id`: Xano workspace ID (default: "1")
- `--base-url`: Xano API base URL (optional)
- `--csv-dir`: Directory to store CSV exports (default: "csv_exports")

### Schema Generation Options

- `--csv-dir`: Directory containing CSV exports (default: "csv_exports")
- `--output-file`: Output schema file path (default: "schema.rb")

### Model Generation Options

- `--csv-dir`: Directory containing CSV exports (default: "csv_exports")
- `--models-dir`: Directory to store model files (default: "app/models")

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ravzski/xano_exporter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).