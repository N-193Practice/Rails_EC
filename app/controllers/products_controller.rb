class ProductsController < ApplicationController
  def show
    @product = Spree::Product.includes(master: [:default_price, images: { attachment_attachment: :blob }]).find(params[:id])
    @top_section_breadcrumbs = product_breadcrumbs(@product)
    @related_products = @product.related_products
      .includes(master: [:default_price, images: { attachment_attachment: :blob }])
      .limit(PotepanecConstants::MAX_NUMBER_OF_RELATED_PRODUCTS)
  end

  private

  def product_breadcrumbs(product)
    main_parent_taxon = Spree::Taxon.find_by(name: PotepanecConstants::TOP_TAXON_PARENT_NAME)
    breadcrumbs_taxon = product.taxons.find_by(taxonomy_id: main_parent_taxon.taxonomy_id)
    breadcrumbs = breadcrumbs_taxon.get_taxon_breadcrumbs.to_a
    breadcrumbs << product
    breadcrumbs
  end
end
