require 'rails_helper'

RSpec.describe Spree::ProductDecorator, type: :model do
  describe '#related_products' do
    let(:another_taxon) { create(:taxon) }
    let(:taxon) { create(:taxon) }
    let(:product) { create(:product, taxons: [taxon, another_taxon]) }
    let!(:related_products) { create_list(:product, 2, taxons: [taxon, another_taxon]) }
    let!(:unrelated_product) { create(:product) }

    it "同じTaxonに属する商品を返すこと" do
      expect(product.related_products).to match_array(related_products)
    end

    it 'レシーバ自身は含まれないこと' do
      expect(product.related_products).not_to include(product)
    end

    it '商品が重複しないこと' do
      expect(product.related_products.count).to eq(related_products.count)
    end

    it '関連のない製品が含まれないこと' do
      expect(product.related_products).not_to include(unrelated_product)
    end
  end
end
