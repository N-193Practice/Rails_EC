require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    let(:taxonomy) { create(:taxonomy) }
    let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }
    let!(:clothing_taxon) { create(:taxon, name: 'Clothing', parent: categories_taxon, taxonomy: taxonomy) }
    let!(:mugs_taxon) { create(:taxon, name: 'Mugs', parent: categories_taxon, taxonomy: taxonomy) }
    let!(:bags_taxon) { create(:taxon, name: 'Bags', parent: categories_taxon, taxonomy: taxonomy) }
    let!(:caps_taxon) { create(:taxon, name: 'Caps', parent: categories_taxon, taxonomy: taxonomy) }

    before do
      get root_path
    end

    it 'ホームページが正常に表示されること' do
      expect(response).to have_http_status(200)
    end

    it 'カテゴリの子が含まれていること' do
      expect(response.body).to include(I18n.t(clothing_taxon.name))
      expect(response.body).to include(I18n.t(mugs_taxon.name))
      expect(response.body).to include(I18n.t(bags_taxon.name))
      expect(response.body).to include(I18n.t(caps_taxon.name))
    end
  end
end
