require 'rails_helper'

RSpec.describe 'Cart', type: :system do
  let(:taxonomy) { create(:taxonomy) }
  let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }
  let!(:test_category_taxon) { create(:taxon, name: 'Caps', parent: categories_taxon, taxonomy: taxonomy) }

  before do
    visit cart_index_path
  end

  it 'メニュー項目が正しく機能すること' do
    within first('.NavigationMenuList__item') do
      click_on I18n.t(test_category_taxon.name)
    end

    within first('.CategoriesTitle') do
      expect(page).to have_content(I18n.t(test_category_taxon.name))
    end
  end
end
