require 'rails_helper'

RSpec.describe "Home", type: :system do
  let(:taxonomy) { create(:taxonomy) }
  let!(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }

  context '子カテゴリーを持つカテゴリを確認する' do
    let!(:test_category_taxon) { create(:taxon, name: 'Clothing', parent: categories_taxon, taxonomy: taxonomy) }

    before do
      visit root_path
    end

    it '予想される名前を持つ1つのカテゴリを持つ1つのナビゲーション項目が含まれていること' do
      expected_taxon_navigation_item = [I18n.t(test_category_taxon.name)]
      within('.NavigationMenuList') do
        expected_taxon_navigation_item.each_with_index do |taxon_name, i|
          expect(page).to have_css(".NavigationMenuList__item a.NavigationMenuList__item:nth-child(#{i + 1})", text: taxon_name)
        end
      end
    end

    it 'カテゴリセクションの子要素は正しい項目名をそれぞれ持っていること' do
      expected_category_taxon = [I18n.t(test_category_taxon.name)]
      within('.CategoryList') do
        expected_category_taxon.each_with_index do |taxon_name, i|
          expect(page).to have_css(".CategoryItem:nth-child(#{i + 1})", text: taxon_name)
        end
      end
    end
  end

  context 'カテゴリに子要素があり、分類群にこの子要素を含む製品が 1 つある' do
    let(:test_category_taxon) { create(:taxon, name: 'Clothing', parent: categories_taxon, taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [test_category_taxon]) }
    let!(:image) { create(:image, viewable: product.master) }

    before do
      visit root_path
    end

    it 'カテゴリをクリックするとカテゴリページに遷移すること' do
      within first('.CategoryItem') do
        click_link 'VIEW'
      end

      expect(page).to have_selector('.CategoriesTitle', text: I18n.t(test_category_taxon.name))

      expected_product_items = [product.name]
      within('.CategoryProducts') do
        expected_product_items.each_with_index do |product_name, i|
          expect(page).to have_css(".CategoryProduct:nth-child(#{i + 1})", text: product_name)
        end
      end
    end
  end

  context 'ホームからカテゴリの詳細を確認する' do
    let(:test_category_taxon) { create(:taxon, name: 'Caps', parent: categories_taxon, taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [test_category_taxon]) }
    let!(:image) { create(:image, viewable: product.master) }

    before do
      visit root_path
    end

    it 'カテゴリをクリックするとカテゴリページに遷移すること' do
      within first('.CategoryItem') do
        click_link 'VIEW'
      end

      expect(page).to have_content(I18n.t(test_category_taxon.name))
    end

    it 'カテゴリページを表示すること' do
      within first('.CategoryItem') do
        click_link 'VIEW'
      end

      expect(page).to have_content(product.name)
    end

    it 'カテゴリページで商品をクリックすると商品詳細ページを表示すること' do
      within first('.CategoryItem') do
        click_link 'VIEW'
      end

      expected_breadcrumb_taxon_items = ['ホーム', I18n.t(test_category_taxon.name)]
      within('.Breadcrumb') do
        expected_breadcrumb_taxon_items.each_with_index do |breadcrumb_text, i|
          expect(page).to have_css("li.Breadcrumb__item:nth-child(#{i + 1})", text: breadcrumb_text)
        end
      end

      within first('.CategoryProduct') do
        click_on product.name
      end

      expect(page).to have_content(product.name)
      expect(page).to have_content(product.display_price.to_s)

      expected_product_breadcrumb_items = ['ホーム', I18n.t(test_category_taxon.name), product.name]
      within('.Breadcrumb') do
        expected_product_breadcrumb_items.each_with_index do |breadcrumb_text, i|
          expect(page).to have_css("li.Breadcrumb__item:nth-child(#{i + 1})", text: breadcrumb_text)
        end
      end
    end
  end
end
