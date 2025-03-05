# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'fileutils'

module XanoExporter
  class Client
    attr_reader :auth_token, :workspace_id, :base_url, :csv_dir

    def initialize(auth_token, workspace_id, base_url = nil, csv_dir = 'csv_exports')
      @auth_token = auth_token
      @workspace_id = workspace_id
      @base_url = base_url || 'https://api.gogym.ph/api:meta'
      @csv_dir = csv_dir
      @headers = {
        'accept' => 'application/json',
        'x-data-source' => 'live',
        'Authorization' => "Bearer #{@auth_token}"
      }
      FileUtils.mkdir_p(@csv_dir) unless Dir.exist?(@csv_dir)
    end

    # Fetch all tables from workspace
    def fetch_tables(per_page = 100)
      all_tables = []
      current_page = 1

      loop do
        url = URI("#{@base_url}/workspace/#{@workspace_id}/table?per_page=#{per_page}&page=#{current_page}")
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
        url = URI("#{@base_url}/workspace/#{@workspace_id}/table/#{table_id}/content?per_page=#{per_page}&page=#{current_page}")
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
      tables
    end


    def export_table_to_csv(table)
      table_id = table['id']
      table_name = table['name']

      puts "Exporting table: #{table_name} (ID: #{table_id})"

      content = fetch_table_content(table_id)

      if content.empty?
        puts "No data found for table: #{table_name}"
        return
      end

      headers = content.first.keys
      filename = "#{@csv_dir}/#{table_name}.csv"
      CSV.open(filename, 'w') do |csv|
        # Add headers
        csv << headers

        content.each do |item|
          row = headers.map { |header| format_value(item[header]) }
          csv << row
        end
      end

      puts "Exported #{content.length} records to #{filename}"

      {
        name: table_name,
        headers: headers,
        sample_data: content.first
      }
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
end