require 'optparse'

require 'clairlune/version'
require 'clairlune/builder'

module Clairlune
  def self.run(args)
    params = {
      loglevel: 'info',
    }

    OptionParser.new do |opt|
      opt.on('--bucket BUCKET') { |b| params[:bucket] = b }
      opt.on('--key KEY') { |k| params[:key] = k }
      opt.on('--package-json /path/to/package.json') { |p| params[:package_json] = p }
      opt.on('--function-name NAME') { |f| params[:function_name] = f }
      opt.on('--dest /path/to/node_modules.zip') { |d| params[:dest] = d }
      opt.on('--loglevel (fatal|error|warn|info|debug)') { |l| params[:loglevel] = l }
      opt.on('--version') { |v| params[:version] = v }

      opt.parse!(args)
    end

    verify(params)

    if params[:version]
      puts Clairlune::VERSION
    else
      build(params)
    end
  end

  def self.build(params)
    builder = Clairlune::Builder.new(
      bucket: params[:bucket],
      key: params[:key],
      package_json: params[:package_json],
      function_name: params[:function_name],
      dest: params[:dest],
      loglevel: params[:loglevel],
    )

    builder.performe
  end

  private

  def self.verify(params)
    case
    when blank?(params[:bucket])
      warn '[ERROR] --bucket is required.'
      exit 1
    when blank?(params[:key])
      warn '[ERROR] --key is required.'
      exit 1
    when blank?(params[:package_json])
      warn '[ERROR] --package-json is required.'
      exit 1
    when blank?(params[:function_name])
      warn '[ERROR] --function-name is required.'
      exit 1
    when blank?(params[:dest])
      warn '[ERROR] --dest is required.'
      exit 1
    end
  end

  def self.blank?(obj)
    obj.nil? || obj == ''
  end
end
