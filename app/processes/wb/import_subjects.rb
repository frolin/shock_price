module Wb
  class ImportSubjects < ActiveInteraction::Base
    SUBJECT_URL = 'https://static-basket-01.wb.ru/vol0/data/subject-base.json'
    MAIN_MENU_URL = 'https://static-basket-01.wb.ru/vol0/data/main-menu-ru-ru-v2.json'

    def execute
      response = Faraday.get(MAIN_MENU_URL)
      parsed_body = JSON.parse(response.body)

      parsed_body.each do |category|
        parent = Subject.find_or_create_by!(name: category['name'], url: category['url'], cat_id: category['id'])

        if category['childs'].present?

          category['childs'].each do |child|
            subcategory = parent.subcategories.find_or_create_by!(name: child['name'], url: child['url'], cat_id: child['parent'])

            if child['childs'].present?
              child['childs'].each do |subchild|
                next if Category.find_by(name: subchild['name'])

                subcategory.subcategories.create!(name: subchild['name'], url: subchild['url'], cat_id: subchild['parent'])
              end
            end
          end
        end

      end
    end
  end
end