require 'rails_helper'

RSpec.describe 'Products', type: :request do
  describe 'GET /products/:id' do
    let(:taxonomy) { create(:taxonomy) }
    let!(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }

    context '商品が見つかった場合' do
      let(:test_category_taxon) { create(:taxon, name: 'Category', parent: categories_taxon, taxonomy: taxonomy) }
      let(:second_test_category_taxon) { create(:taxon, name: 'Category 2', parent: categories_taxon, taxonomy: taxonomy) }
      let(:product) { create(:product, taxons: [second_test_category_taxon]) }
      let!(:image) { create(:image, viewable: product.master) }
      let(:related_products) { create_list(:product, PotepanecConstants::MAX_NUMBER_OF_RELATED_PRODUCTS, taxons: [second_test_category_taxon]) }
      let(:not_included_product) { create(:product, taxons: [second_test_category_taxon]) }

      before do
        related_products.each_with_index do |product, index|
          product.master.price = (index + 1) * 10.0
          product.master.save
          create(:image, viewable: product.master)
        end

        not_included_product.master.price = (related_products.count + 1) * 10.0
        product.master.save

        get product_path(product.id)
      end

      it '商品ページが正常に表示されること' do
        expect(response).to have_http_status(200)
      end

      it '製品の詳細が含まれていること' do
        expect(response.body).to include(product.name)
        expect(response.body).to include(product.display_price.to_s)
      end

      it 'パンくずリストにホーム,カテゴリ分類群が表示されていること' do
        expect(response.body).to include('ホーム')
        expect(response.body).to include(test_category_taxon.name)
        expect(response.body).to include(second_test_category_taxon.name)
        expect(response.body).to include(product.name)
      end

      it '関連商品がある場合は商品ページに関連商品の項目が正しく表示されること' do
        related_products.all? do |product|
          expect(response.body).to include(product_path(product.id))
          expect(response.body).to include(product.name)
          expect(response.body).to include(product.price.to_s)
        end
      end

      it '4つ以上の製品は存在しないこと' do
        expect(response.body).not_to include(product_path(not_included_product.id))
        expect(response.body).not_to include(not_included_product.name)
        expect(response.body).not_to include(not_included_product.price.to_s)
      end
    end

    context '商品が見つからない場合' do
      let(:non_existing_product_id) { Spree::Product.last ? Spree::Product.last.id + 1 : 1 }

      before do
        # Spree::Product.last が nil の場合は直接 404 エラーを返す
        if Spree::Product.find_by(id: non_existing_product_id).nil?
          get product_path(non_existing_product_id)
        else
          raise ActiveRecord::RecordNotFound
        end
      end

      it '商品が見つからない場合、"Not Found"が表示されること' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
