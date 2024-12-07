class ModelFilesController < ApplicationController
  def new
  end

  def create
    endpoint ModelFile::Operation::Create do |result|
      respond_to do |format|
        format.js do
          render "create", layout: false, locals: { result: result }
        end
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
