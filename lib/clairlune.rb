require 'json'
require 'logger'
require 'aws-sdk'

require 'clairlune/version'

module Clairlune
  class Builder
    def initialize(key:, bucket:, package_json_file_path:, build_function_name:, destination:, loglevel: 'info')
      @key = key
      @bucket = bucket
      @build_function_name = build_function_name
      @destination = destination
      @package_json = File.read(package_json_file_path)
      @logger = Logger.new(STDOUT)
      @logger.level = loglevel
    end

    def performe(loglevel: 'info')
      lambda_client = Aws::Lambda::Client.new

      @logger.info("Invoke build function: #{@build_function_name}")

      lambda_response = lambda_client.invoke(
        function_name: @build_function_name,
        payload: @package_json,
        invocation_type: 'RequestResponse',
      )

      if lambda_response.data.status_code != 200
        @logger.fatal('Returned status code is not 200 (Lambda).')

        return {
          success: false,
          description: 'Returned status code is not 200 (Lambda).',
        }
      end

      if JSON.load(lambda_response.data.payload)['status'] != 'success'
        @logger.fatal('Build is failed.')
        @logger.fatal(lambda_response.payload.read)

        return {
          success: false,
          description: lambda_response.payload.read,
        }
      end

      @logger.info("Download zipped npm module from: s3://#{@bucket}/#{@key}")

      s3_client = Aws::S3::Client.new
      File.open(@destination, 'w') do |file|
        s3_client.get_object(bucket: @bucket, key: @key) do |chunk|
          file.write(chunk)
        end
      end

      {
        success: true,
        file_path: @destination,
        description: 'success',
      }
    end
  end
end
