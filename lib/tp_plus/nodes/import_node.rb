module TPPlus
  module Nodes
    class ImportNode < BaseNode
      def initialize(filenames, options={})
        @filenames = filenames
        @compile = options[:compile]
      end

      def compile?
        @compile
      end

      def find_file(name)
        fileext = name + ".tpp"
        $global_options[:include].each do |i|
          filepath =  i + "/" + fileext
          if File.exist?(filepath)
            return filepath
          end
        end

        raise "File #{fileext} was not found in includes."
      end

      def clear_files
        @filenames = []
      end

      def eval(context)
        nodes = []
        @filenames.each do |f|
          nodes << context.load_import(find_file(f), compile?)
        end

        nodes
      end
    end
  end
end
