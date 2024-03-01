class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent

  before_action :set_navigation_categories, only: [:show, :index]
  protect_from_forgery with: :exception

  rescue_from Exception do |e|
    logger.error "Rendering 500 with exception: #{e.message}"
    render template: "errors/500", layout: false, status: :internal_server_error, formats: [:html]
  end

  rescue_from ActionController::RoutingError do |e|
    logger.info "Rendering 404 with exception: #{e.message}"
    render template: "errors/404", layout: false, status: :not_found, formats: [:html]
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    logger.info "Rendering 404 with exception: #{e.message}"
    render template: "errors/404", layout: false, status: :not_found, formats: [:html]
  end

  private

  # メインタクソンの子孫に基づいてナビゲーションメニューを設定(Categoriesに該当するデータが存在する前提で作られているので条件分岐なし)
  def set_navigation_categories
    @categories_taxons = Spree::Taxon.find_by(name: PotepanecConstants::TOP_TAXON_PARENT_NAME).children
  end
end
