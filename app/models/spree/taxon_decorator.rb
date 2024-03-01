module Spree
  module TaxonDecorator
    def get_taxon_breadcrumbs
      self_and_ancestors
        .where('depth > ?', PotepanecConstants::TOP_TAXON_PARENT_DEPTH).order(:depth)
    end

    Spree::Taxon.prepend self
  end
end
