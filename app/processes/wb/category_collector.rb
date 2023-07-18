module Wb
  class CategoryCollector < ActiveInteraction::Base

    def execute
      menu_name = @page.find_element(css: '.menu-catalog__list-1 .name').text
      submenu = @page.find_elements(css: ".maincatalog-list-2 li a").map { |sm| [sm.text, sm.attribute('href')] }.to_h

      category = Category.find_or_create_by(name: menu_name, url: url)
      new_subcategories = submenu.reject { |name, _href| category.subcategories.find_by(name: name) }
      new_subcategories.each { |name, href| category.subcategories.create(name: name, url: href) }
    end
  end
end
