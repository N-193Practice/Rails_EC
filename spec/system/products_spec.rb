require 'rails_helper'

RSpec.describe 'Products', type: :system do
  let(:taxonomy) { create(:taxonomy) }
  let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }
  let(:test_category_taxon) { create(:taxon, parent: categories_taxon, taxonomy: taxonomy) }
  let(:product) { create(:product, taxons: [test_category_taxon]) }
  let!(:image) { create(:image, viewable: product.master) }
  let(:related_products) { create_list(:product, PotepanecConstants::MAX_NUMBER_OF_RELATED_PRODUCTS, taxons: [test_category_taxon]) }

  before do
    related_products.each_with_index do |product, index|
      product.master.price = (index + 1) * 10.0
      product.master.save
      create(:image, viewable: product.master)
    end
    visit product_path(product.id)
  end

  it '製品名が正しく表示されること' do
    expect(page).to have_content(product.name)
  end

  it 'リンクとなっているパンくずリストが正しく機能すること' do
    expected_breadcrumbs = ['ホーム', test_category_taxon.name]
    within first('.Breadcrumb') do
      expected_breadcrumbs.each_with_index do |expected_breadcrumb, i|
        expect(page).to have_link(expected_breadcrumb)
      end
    end
  end

  it '最後のパンくずリストが商品名であり、リンクでないこと' do
    within('ul.Breadcrumb') do
      list_items = all('li.Breadcrumb__item')
      within(list_items.last) do
        expect(page).to have_no_link(product.name)
        expect(page).to have_content(product.name)
      end
    end
  end

  it '商品ページのパンくずリストが正しく機能すること' do
    within ('.Breadcrumb') do
      click_link test_category_taxon.name
    end
    expect(current_path).to eq(category_path(test_category_taxon.id))
  end

  it '商品詳細が正しく表示されること' do
    within('.ProductDetail__name') do
      expect(page).to have_content(product.name)
    end
  end

  it '商品イメージが正しく表示されること' do
    within('.ProductSlider__carousel') do
      expect(page).to have_css(".ProductSlider__image[alt='#{product.name}']")
    end
  end

  it '商品金額が正しく表示されること' do
    within('.ProductDetail__price') do
      expect(page).to have_content(product.display_price.to_s)
    end
  end

  it 'カートに商品を追加してカートページが表示されること' do
    click_link "カートに入れる"
    expect(current_path).to eq(cart_index_path)
  end

  it '製品ページからホームページに遷移すること' do
    click_link "ホーム"
    expect(current_path).to eq(root_path)
  end

  it 'サイズボタンが正しく機能すること' do
    size = 'M'
    choose(size, allow_label_click: true)
    expect(page).to have_checked_field(size)
  end

  it '関連商品がある場合は項目が正しく表示されること' do
    within('.RelatedProducts__list') do
      related_products.all? do |related_product|
        expect(page).to have_content(related_product.name)
        expect(page).to have_content(related_product.display_price.to_s)
      end
    end
  end

  it 'ユーザーが関連商品に関する項目ボタンを押した際に選択された商品の詳細ページに遷移すること' do
    selected_product = related_products.first
    within('.RelatedProducts__list') do
      click_on selected_product.name
    end
    expect(current_path).to eq(product_path(selected_product.id))
  end
end
