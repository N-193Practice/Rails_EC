RSpec.describe "Categories", type: :request do
  describe 'GET /categories/:id' do
    let(:taxonomy) { create(:taxonomy) }
    let(:categories_taxon) { create(:taxon, name: PotepanecConstants::TOP_TAXON_PARENT_NAME, taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [test_category_taxon]) }
    let!(:image) { create(:image, viewable: product.master) }
    let(:category_id) { test_category_taxon.id }
    let!(:non_category_product) { create(:product) }

    # test_category_taxon を ローカル変数で定義
    let(:test_category_taxon) { create(:taxon, name: 'Category', parent: categories_taxon, taxonomy: taxonomy) }
    
    context 'カテゴリが見つかった場合'  do
      before do
        # Get all products in the category here
        @category_products = test_category_taxon.all_products.includes(master: [:default_price])
        get category_path(category_id)
      end

      it 'カテゴリページが正常に表示されること'  do
        expect(response).to have_http_status(200)
      end

      it "カテゴリページに'Category'が表示されること"  do
        expect(response.body).to include(test_category_taxon.name)
      end

      it '製品がカテゴリの製品ページに含まれており、正しいリンクが設定されていること'  do
        expect(response.body).to include(product.name)
        expect(response.body).to include(product.display_price.to_s)  
      end

      it 'パンくずリストにはホーム、カテゴリ分類群が表示されること'  do
        expect(response.body).to include('ホーム')
        expect(response.body).to include(test_category_taxon.name)
        expect(response.body).to include(product.name)
      end

      it '特定のカテゴリーIDでリクエストを送ったとき、そのカテゴリーに属していない商品はレスポンスに含まれてはならないこと'  do
        expect(response.body).not_to include(non_category_product.name)
      end
    end

    context 'カテゴリ商品が見つからない場合'  do
      let(:non_existing_category_id) { Spree::Taxon.last.id + 1 }

      before do
        get category_path(non_existing_category_id)
      end

      it 'カテゴリ商品が見つからない場合は「Not Found」と表示されること'  do
        expect(response).to have_http_status(404)
      end
    end
  end
end
