require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'fileutils'

class XanoClient
  BASE_URL = 'https://api.gogym.ph/api:meta'

  def initialize(auth_token, workspace_id)
    @auth_token = auth_token
    @workspace_id = workspace_id
    @headers = {
      'accept' => 'application/json',
      'x-data-source' => 'live',
      'Authorization' => "Bearer #{@auth_token}"
    }
    FileUtils.mkdir_p('csv_exports') unless Dir.exist?('csv_exports')
  end

  # Fetch all tables from workspace
  def fetch_tables(per_page = 100)
    all_tables = []
    current_page = 1

    loop do
      url = URI("#{BASE_URL}/workspace/#{@workspace_id}/table?per_page=#{per_page}&page=#{current_page}")
      response = make_request(url)

      if response['items']
        all_tables += response['items']

        # Check if there's a next page
        if response['nextPage']
          current_page = response['nextPage']
        else
          break
        end
      else
        puts "No tables found or error in response"
        break
      end
    end

    all_tables
  end

  # Fetch table content
  def fetch_table_content(table_id, per_page = 100)
    all_content = []
    current_page = 1

    loop do
      url = URI("#{BASE_URL}/workspace/#{@workspace_id}/table/#{table_id}/content?per_page=#{per_page}&page=#{current_page}")
      response = make_request(url)

      if response['items'] && !response['items'].empty?
        all_content += response['items']

        # Check if there's a next page
        if response['nextPage']
          current_page = response['nextPage']
        else
          break
        end
      else
        break
      end
    end

    all_content
  end

  # Export all tables data to CSV
  def export_all_tables_to_csv
    tables = fetch_tables
    tables.each do |table|
      export_table_to_csv(table)
    end
  end

  # Export single table to CSV
  def export_table_to_csv(table)
    table_id = table['id']
    table_name = table['name']

    puts "Exporting table: #{table_name} (ID: #{table_id})"

    content = fetch_table_content(table_id)

    if content.empty?
      puts "No data found for table: #{table_name}"
      return
    end

    # Get column headers from the first item
    headers = content.first.keys

    # Create CSV file
    filename = "csv_exports/#{table_name}.csv"
    CSV.open(filename, 'w') do |csv|
      # Add headers
      csv << headers

      # Add rows
      content.each do |item|
        # Extract values in the same order as headers
        row = headers.map { |header| format_value(item[header]) }
        csv << row
      end
    end

    puts "Exported #{content.length} records to #{filename}"
  end

  private

  def make_request(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    request = Net::HTTP::Get.new(url)
    @headers.each { |key, value| request[key] = value }

    response = http.request(request)

    if response.code == '200'
      JSON.parse(response.body)
    else
      puts "Error making request to #{url}: #{response.code} - #{response.body}"
      {}
    end
  end

  def format_value(value)
    case value
    when Hash, Array
      JSON.generate(value)
    else
      value
    end
  end
end

# Command-line interface
if __FILE__ == $PROGRAM_NAME
  if ARGV.length < 1
    puts "Usage: ruby xano.rb AUTH_TOKEN [WORKSPACE_ID=1]"
    exit 1
  end

  auth_token = ARGV[0]
  workspace_id = ARGV[1] || 1

  client = XanoClient.new(auth_token, workspace_id)

  if ARGV.include?('--list-tables')
    # List all tables
    tables = client.fetch_tables
    puts "Found #{tables.length} tables:"
    tables.each do |table|
      puts "#{table['id']}: #{table['name']}"
    end
  elsif ARGV.include?('--export-table')
    # Export specific table
    table_id_idx = ARGV.index('--export-table') + 1
    if table_id_idx < ARGV.length
      table_id = ARGV[table_id_idx]
      tables = client.fetch_tables
      table = tables.find { |t| t['id'].to_s == table_id }

      if table
        client.export_table_to_csv(table)
      else
        puts "Table with ID #{table_id} not found"
      end
    else
      puts "Please specify a table ID after --export-table"
    end
  else
    # Export all tables
    client.export_all_tables_to_csv
  end
end

