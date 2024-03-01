module ApplicationHelper
  def full_title(page_title)
    base_title = "BIGBAG Store"
    if page_title.blank?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  def category_to_image_name(category_name)
    mapping = {
      "clothing" => "cloth",
      "caps" => "cap",
      "bags" => "bag",
      "mugs" => "tableware",
    }
    begin
      mapping.fetch(category_name.downcase)
    rescue KeyError
      nil
    end
  end
end
