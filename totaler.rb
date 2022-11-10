#! /usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "dry/cli"
require "pp"
require "time"


module Totaler
    extend Dry::CLI::Registry

    class Account_event_totals_1h < Dry::CLI::Command
        desc "Sum the total events submitted by each account in the given time range into 1 hour windows"

        argument :file, type: :string, required: true,  desc: "CSV file to ingest"
        argument :start_time, type: :string, required: true, desc: "Start timestamp in ISO 8601 format (CCYY-MM-DDThh:mm:ssTZ)"
        argument :end_time, type: :string, required: true, desc: "End timestamp in ISO 8601 format (CCYY-MM-DDThh:mm:ssTZ)"

        def call(file:, start_time:, end_time:, **)
            puts "exec - file: #{file}"
            puts "start time: #{start_time}"
            puts "end time: #{end_time}"
            begin 
                start_time = Time.xmlschema(start_time)
            rescue ArgumentError => e
                puts "Invalid start time specified. Example time is like: '2008-11-09T04:00:00Z' for 9 November 2008, 04:00AM UTC"
            end
            begin 
                end_time = Time.xmlschema(end_time)
            rescue ArgumentError => e
                puts "Invalid end time specified. Example time is like: '2008-11-09T04:00:00Z' for 9 November 2008, 04:00AM UTC"
            end

            hour_buckets = {}
            start_bucket_hour = Time.new(start_time.year, start_time.month, start_time.day, start_time.hour, 0, 0, start_time.strftime('%z'))
            until start_bucket_hour > end_time do
                hour_buckets[start_bucket_hour.to_s] = {}
                start_bucket_hour += 60 * 60
            end
            # pp hour_buckets
            events = CSV.read(file, headers: %w(customer_id event_type transaction_id timestamp), header_converters: :symbol)
            events.each do | line | 
                line_time = Time.parse(line[:timestamp])
                # calculate hour window of timestamp
                line_hour_window = Time.new(line_time.year, 
                                            line_time.month, 
                                            line_time.day, 
                                            line_time.hour, 
                                            0, 
                                            0, 
                                            line_time.strftime('%z'))

                # puts hour_buckets[line_hour_window.to_s]
                # am I in the specified window?
                if line_time > start_time and line_time < end_time
                                    # initalize that customer ID message counter
                    if hour_buckets[line_hour_window.to_s] == nil
                        hour_buckets[line_hour_window.to_s] = {line[:customer_id] => 0}
                        # puts hour_buckets[line_hour_window.to_s][line[:customer_id]]
                    elsif hour_buckets[line_hour_window.to_s][line[:customer_id]] == nil
                        hour_buckets[line_hour_window.to_s][line[:customer_id]] = 0
                    end
                    # puts "I'm in the zone! "
                    # puts "My time: #{line_time}"
                    # puts "My hour_bucket: #{hour_buckets[line_hour_window.to_s]}"
                    # puts "My customer ID: #{line[:customer_id]}"
                    # increment this account's hash at hour_buckets[hour_window][account_id] += 1
                    hour_buckets[line_hour_window.to_s][line[:customer_id]] += 1
                end
            end

            hour_buckets.each do | bucket |
                puts "Time: #{bucket.first}"
                bucket[1].keys.each do | customer_id | 
                    # puts bucket[1][customer_id]
                    puts "Customer ID: #{customer_id} Calls: #{bucket[1][customer_id]}"
                end
            end
        end
    end

    register "account_event_totals_1h", Account_event_totals_1h
  end
  
  Dry::CLI.new(Totaler).call