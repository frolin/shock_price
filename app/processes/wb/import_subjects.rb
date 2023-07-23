module Wb
  class ImportSubjects < ActiveInteraction::Base
    SUBJECT_URL = 'https://static-basket-01.wb.ru/vol0/data/subject-base.json'

    def execute
      response = Faraday.get(SUBJECT_URL)
      parsed_body = JSON.parse(response.body)

      parsed_body.each do |category|
        parent = Category.create!(name: category['name'], url: category['url'], cat_id: category['id'])

        category['childs'].each do |child|
          parent.subcategories.create!(name: child['name'], url: child['url'], cat_id: child['id'])
        end
      end

    end

  end
end