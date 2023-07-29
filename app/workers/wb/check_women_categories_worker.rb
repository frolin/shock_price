module Wb
  class CheckWomenCategoriesWorker
    include Sidekiq::Worker

    def perform
      Subject.women.each do |subject_name|
        ::Wb::CheckDiscountsWorker.perform_async(subject_name, pages: [1,2,3])
      end
    end
  end
end
