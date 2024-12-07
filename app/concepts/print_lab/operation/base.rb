class PrintLab::Operation::Base
  attr_accessor :result

  def initialize(**attrs)
    @attrs = attrs
    @result = PrintLab::Operation::Result.new
  end

  def self.call(**args)
    ops = new(**args).tap(&:call)
    ops.result
  end

  def call
    begin
      perform!(**@attrs)
    rescue ActiveRecord::RecordInvalid => e
      add_errors e.record&.errors
    ensure
    end
  end

  def add_error(key, message)
    @result.errors.add :base, key, message:
  end

  def add_errors(from)
    return if from.nil?

    from.each do |error|
      from[error.attribute].each do |error_msg|
        @result.errors.add(error.attribute, error_msg)
      end
    end
  end

  def model
    @result[:model]
  end

  def add_notice(notice)
    @result[:notice] = notice
  end

  def model=(model)
    @result[:model] = model
  end
end
