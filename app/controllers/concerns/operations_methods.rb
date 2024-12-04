# frozen_string_literal: true

module OperationsMethods
  protected

  def endpoint(operation_class, view_class = nil)
    result = operation_class.call(params: params, current_user: current_user)

    if block_given?
      yield(result)
      return
    end

    respond_to do |format|
      format.html do
        if result.success?
          flash[:notice] = result.notice if result.notice.present?
        else
          flash[:alert] = result.errors.full_messages.join(", ") if result.errors.any?
        end

        model_name = result.model.class.name.downcase
        view_options = {}
        view_options[model_name.to_sym] = result.model

        render(view_class.new(current_user: current_user, **view_options))
      end
    end
  end
end
