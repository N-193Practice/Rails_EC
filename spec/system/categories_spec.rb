require 'rails_helper'

RSpec.describe 'Categories', type: :system do
  let(:taxonomy) { create(:taxonomy) }
  let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }

  context 'ホームからカテゴリの詳細を確認する' do
    let(:test_category_taxon) { create(:taxon, name: 'Caps', parent: categories_taxon, taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [test_category_taxon]) }
    let!(:image) { create(:image, viewable: product.master) }

    before do
      visit root_path
    end

    it 'メニュー項目が正しく機能すること' do

      within first('.NavigationMenuList__item') do
        click_on I18n.t(test_category_taxon.name)
      end

      expect(current_path).to eq(category_path(test_category_taxon.id))

      within first('.CategoriesTitle') do
        expect(page).to have_content(I18n.t(test_category_taxon.name))
      end
    end

    it 'ホームへのパンくずリストが表示され、クリックでページ遷移すること' do

      within first('.CategoryItem') do
        click_link 'VIEW'
      end

      expect(current_path).to eq(category_path(test_category_taxon.id))

      within first('.Breadcrumb') do
        click_link 'ホーム'
      end

      expect(current_path).to eq(root_path)
    end
  end

  context 'カテゴリ詳細から直接確認する' do
    let(:test_category_taxon) { create(:taxon, name: 'Clothing', parent: categories_taxon, taxonomy: taxonomy) }
    let(:sub_test_category_taxon) { create(:taxon, name: 'Shirts', parent: test_category_taxon, taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [sub_test_category_taxon]) }
    let!(:image) { create(:image, viewable: product.master) }

    before do
      visit category_path(sub_test_category_taxon.id)
    end

    it 'リンクとなっているパンくずリストが正しく機能すること' do
      expected_breadcrumbs = ['ホーム', I18n.t(test_category_taxon.name)]
      within first('.Breadcrumb') do
        expected_breadcrumbs.each_with_index do |expected_breadcrumb, i|
          expect(page).to have_link(expected_breadcrumb)
        end
      end
    end

    it '最後のパンくずリストは選択されたカテゴリ名であり、リンクでないことが証明できること' do
      within('ul.Breadcrumb') do
        list_items = all('li.Breadcrumb__item')
        within(list_items.last) do
          expect(page).to have_no_link(I18n.t(sub_test_category_taxon.name))
          expect(page).to have_content(I18n.t(sub_test_category_taxon.name))
        end
      end
    end

    it 'ブレッドクラムをクリックすると、別のカテゴリに遷移すること' do
      expected_breadcrumbs = ['ホーム', I18n.t(test_category_taxon.name)]

      # ブレッドクラムアイテムをクリックしたときの動作を確認する
      within('.Breadcrumb') do
        click_link I18n.t(test_category_taxon.name)
      end

      expect(current_path).to eq(category_path(test_category_taxon.id))

      within first('.Breadcrumb') do
        expected_breadcrumbs.each_with_index do |category_name, i|
          expect(page).to have_css("li.Breadcrumb__item:nth-child(#{i + 1})", text: category_name)
        end
      end
    end

    it '製品をクリックすると製品の詳細に遷移すること' do
      within('.CategoryProducts__list li.CategoryProduct:first') do
        click_on product.name
      end

      expect(current_path).to eq(product_path(product.id))
    end

    it '製品画像、金額、名前が表示されていること' do
      within first('.CategoryProduct') do
        expect(find('.CategoryProduct__image')[:alt]).to eq(product.name)
        expect(find('.CategoryProduct__name')).to have_content(product.name)
        expect(find('.CategoryProduct__price')).to have_content(product.display_price)
      end
    end
  end

  context 'カテゴリに関連付けられた画像がない場合' do
    let!(:test_category_taxon) { create(:taxon, name: 'Non Existing Category in images', parent: categories_taxon, taxonomy: taxonomy) }

    before do
      visit root_path
    end

    it 'カテゴリのエラー画像が表示されること' do
      within ('.CategoryItem') do
        expect(page).to have_selector("img[src*='noimage/small'][alt='#{test_category_taxon.name}']")
      end
    end
  end
end
