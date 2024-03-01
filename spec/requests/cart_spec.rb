require 'rails_helper'

RSpec.describe 'Cart', type: :request do
  describe 'GET /cart' do
    let(:taxonomy) { create(:taxonomy) }
    let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }
    let!(:test_category_taxon) { create(:taxon, name: 'Category', parent: categories_taxon, taxonomy: taxonomy) }

    before do
      get cart_index_path
    end

    it 'ホームページが正常に表示されること' do
      expect(response).to have_http_status(200)
    end
  end
end
