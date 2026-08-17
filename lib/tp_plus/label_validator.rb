module TPPlus
  class LabelValidationError < StandardError
    attr_reader :program_name, :undefined_labels, :duplicate_labels, :label_names

    def initialize(program_name:, undefined_labels:, duplicate_labels:, label_names: {})
      @program_name = program_name
      @undefined_labels = undefined_labels
      @duplicate_labels = duplicate_labels
      @label_names = label_names

      super(build_message)
    end

    private

    def build_message
      lines = ["TP+ label validation failed for program #{@program_name}."]

      unless @undefined_labels.empty?
        lines << "Undefined direct label targets:"
        @undefined_labels.each do |label, reference_lines|
          lines << "  #{label_display(label)} referenced at generated LS #{line_list(reference_lines)}; no definition was emitted."
        end
      end

      unless @duplicate_labels.empty?
        lines << "Duplicate label definitions:"
        @duplicate_labels.each do |label, definition_lines|
          lines << "  #{label_display(label)} defined #{definition_lines.length} times at generated LS #{line_list(definition_lines)}."
        end
      end

      lines << "Every directly referenced LBL[n] must be defined exactly once, and a label number may not be defined more than once in the same program."
      unless @undefined_labels.empty?
        lines << "Hint: keep jump_to @name and @name in the same TP+ scope; an inline function cannot target a caller-owned label."
      end
      lines.join("\n")
    end

    def line_list(line_numbers)
      noun = line_numbers.length == 1 ? "line" : "lines"
      "#{noun} #{line_numbers.join(', ')}"
    end

    def label_display(label)
      names = Array(@label_names[label])
      return "LBL[#{label}]" if names.empty?

      source_names = names.map { |name| "@#{name.to_s.sub(/\A@/, '')}" }
      "LBL[#{label}] (#{source_names.join(', ')})"
    end
  end

  class LabelValidator
    MOTION_SECTION = "/MN".freeze
    SECTION_END_PATTERN = %r{\A/(?:POS|END)\z}.freeze
    LABEL_DEFINITION_PATTERN = /\ALBL\[(\d+)(?::[^\]]*)?\]\s*;?/i.freeze
    DIRECT_LABEL_REFERENCE_PATTERN = /\b(?:JMP\s+|SKIP\s*,\s*|TIMEOUT\s*,\s*)LBL\[(\d+)\]/i.freeze
    TP_LINE_PREFIX_PATTERN = /\A\s*:\s*/.freeze

    def self.validate!(output, program_name: "<unknown>", label_names: {})
      new(output, program_name, label_names).validate!
    end

    def initialize(output, program_name, label_names)
      @output = output.to_s
      @program_name = program_name.to_s
      @label_names = normalize_label_names(label_names)
    end

    def validate!
      definitions, references = collect_labels

      undefined_labels = references.each_with_object({}) do |(label, lines), missing|
        missing[label] = lines unless definitions.key?(label)
      end
      duplicate_labels = definitions.each_with_object({}) do |(label, lines), duplicates|
        duplicates[label] = lines if lines.length > 1
      end

      return true if undefined_labels.empty? && duplicate_labels.empty?

      raise LabelValidationError.new(
        program_name: @program_name,
        undefined_labels: sorted_hash(undefined_labels),
        duplicate_labels: sorted_hash(duplicate_labels),
        label_names: @label_names
      )
    end

    private

    def collect_labels
      definitions = Hash.new { |hash, label| hash[label] = [] }
      references = Hash.new { |hash, label| hash[label] = [] }
      has_motion_section = @output.each_line.any? { |line| line.strip == MOTION_SECTION }
      in_motion_section = !has_motion_section

      @output.each_line.with_index(1) do |line, line_number|
        stripped_line = line.strip

        if stripped_line == MOTION_SECTION
          in_motion_section = true
          next
        elsif has_motion_section && SECTION_END_PATTERN.match?(stripped_line)
          in_motion_section = false
          next
        end

        next unless in_motion_section

        instruction = line.sub(TP_LINE_PREFIX_PATTERN, "").strip
        next if instruction.empty? || instruction.start_with?("!")

        definition = LABEL_DEFINITION_PATTERN.match(instruction)
        if definition
          definitions[definition[1].to_i] << line_number
          next
        end

        instruction.scan(DIRECT_LABEL_REFERENCE_PATTERN) do |match|
          label = match[0].to_i
          references[label] << line_number unless references[label].last == line_number
        end
      end

      [definitions, references]
    end

    def sorted_hash(hash)
      hash.keys.sort.each_with_object({}) do |label, sorted|
        sorted[label] = hash[label]
      end
    end

    def normalize_label_names(label_names)
      (label_names || {}).each_with_object({}) do |(number, names), normalized|
        normalized[number.to_i] = Array(names).compact.map(&:to_s).uniq.sort
      end
    end
  end
end
