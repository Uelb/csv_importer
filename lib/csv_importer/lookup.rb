require_relative "file_loader/base.rb"
Dir.glob("lib/csv_importer/file_loaders/*.rb").each { |f| require "./#{f}" }

require "active_support/hash_with_indifferent_access"

module CSVImporter
  class Lookup
    attr_reader :config, :file_loader, :history_backup_system

    def initialize(config = {})
      @config = config

      @file_loaders = ActiveSupport::HashWithIndifferentAccess.new
      setup_file_loaders
    end

    def file_loader
      lookup_for_file_loader
    end

    def history_loader
      lookup_for_history_loader
    end

    private
    def lookup_for_file_loader
      klass = @file_loaders[@config[:file_loader][:loader]]
      p @file_loaders

      raise CSVImporter::FileLoader::UnknownFileLoaderError,
            "undefined class #{@config[:file_loader][:loader].to_s.camelize}" if klass.nil?

      klass.new(@config[:file_loader])
    end

    def lookup_for_history_loader
    end

    def setup_file_loaders
      Dir.glob("lib/csv_importer/file_loaders/*.rb") do |file|
        /(?<klass>\w+)\.rb/ =~ file

        @file_loaders[klass] = "::CSVImporter::FileLoader::#{klass.classify}".constantize
      end
    end
  end
end