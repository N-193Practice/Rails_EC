require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#full_title' do
    it 'ページタイトルがnilの場合はベースタイトルを返すこと' do
      expect(helper.full_title(nil)).to eq 'BIGBAG Store'
      expect(helper.full_title("")).to eq 'BIGBAG Store'
    end

    it 'ページタイトルを含む完全なタイトルを返すこと' do
      expect(helper.full_title('Home')).to eq 'Home - BIGBAG Store'
    end
  end

  describe '#category_to_image_name' do
    it 'カテゴリに対応する画像名を返すこと' do
      expect(helper.category_to_image_name('Clothing')).to eq 'cloth'
      expect(helper.category_to_image_name('caps')).to eq 'cap'
      expect(helper.category_to_image_name('Bags')).to eq 'bag'
      expect(helper.category_to_image_name('Mugs')).to eq 'tableware'
    end

    it '無効なカテゴリの場合は nil を返すこと' do
      expect(helper.category_to_image_name('Shoes')).to be_nil
    end
  end
end
