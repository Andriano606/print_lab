class PrintLab::Operation::Result
  include ActiveModel::Validations

  def initialize
    @attrs = {}
  end

  def model
    @attrs[:model]
  end

  def notice
    @attrs[:notice]
  end

  def [](val)
    @attrs[val]
  end

  def []=(key, value)
    @attrs[key] = value
  end

  def success?
    return false unless errors.empty?
    return false unless model.nil? || !model.respond_to?(:errors) ? true : model.errors.empty?

    true
  end
end
