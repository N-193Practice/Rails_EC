require 'rails_helper'

RSpec.describe Spree::Taxon, type: :model do
  let(:taxonomy) { create(:taxonomy) }
  let(:top_taxon) { create(:taxon, taxonomy: taxonomy) }
  let(:parent_taxon) { create(:taxon, parent: top_taxon, taxonomy: taxonomy) }
  let(:leaf_taxon) { create(:taxon, parent: parent_taxon, taxonomy: taxonomy) }
  let!(:productA) { create(:product, taxons: [parent_taxon, leaf_taxon]) }
  let!(:productB) { create(:product, taxons: [parent_taxon, leaf_taxon]) }
  let(:productC) { create(:product, taxons: [parent_taxon]) } # 追加

  describe '#get_taxon_breadcrumbs' do
    it '指定されたTAXONの正確な祖先を返すこと' do
      expect(leaf_taxon.get_taxon_breadcrumbs.to_a).to eq([parent_taxon, leaf_taxon])
    end

    it 'TOP_TAXON_PARENT_DEPTH 以下の深さを持つ祖先を除外すること' do
      expect(leaf_taxon.get_taxon_breadcrumbs).not_to include(top_taxon)
    end

    it 'TAXON に TOP_TAXON_PARENT_DEPTH より深い先祖がない場合は、空の配列を返すこと' do
      expect(top_taxon.get_taxon_breadcrumbs).to eq([])
    end

    it 'TAXON に複数の祖先がある場合は、TOP_TAXON_PARENT_DEPTH よりも深い深さを持つすべての祖先を返すこと' do
      grandparent_taxon = create(:taxon, parent: parent_taxon, taxonomy: taxonomy)
      expect(grandparent_taxon.get_taxon_breadcrumbs).to match_array([parent_taxon, grandparent_taxon])
    end
  end

  describe '#all_products' do
    it '指定したTAXONの商品のみを入手すること' do
      expect(leaf_taxon.all_products).to match_array([productA, productB])
    end

    it '親TAXONに関連する製品を入手すること' do
      expect(parent_taxon.all_products).to match_array([productA, productB, productC])
    end
  end
end
