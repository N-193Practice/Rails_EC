class CategoriesController < ApplicationController
  def show
    @category_taxon = Spree::Taxon.find(params[:id])
    @top_section_breadcrumbs = @category_taxon.get_taxon_breadcrumbs.to_a
    @products = @category_taxon.all_products
      .includes(master: [:default_price, images: { attachment_attachment: :blob }])
  end
end
