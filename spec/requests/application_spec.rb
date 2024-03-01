require 'rails_helper'

RSpec.describe 'Application', type: :request do
  describe "GET #index" do
    it "indexページをレンダリングする前に set_navigation_categories を呼び出すこと" do
      expect_any_instance_of(ApplicationController).to receive(:set_navigation_categories)
      get root_path
    end
  end

  describe '#set_navigation_categories' do
    let(:taxonomy) { create(:taxonomy) }
    let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }
    let!(:direct_category_child_one_taxon) { create(:taxon, parent: categories_taxon, taxonomy: taxonomy) }
    let!(:direct_category_child_two_taxon) { create(:taxon, parent: categories_taxon, taxonomy: taxonomy) }

    before do
      get root_path
    end

    it '@categories_taxons を最上位分類群の子に設定すること' do
      expected_taxons = [direct_category_child_one_taxon, direct_category_child_two_taxon]
      expect(controller.instance_variable_get(:@categories_taxons)).to eq(expected_taxons)
    end
  end
end
