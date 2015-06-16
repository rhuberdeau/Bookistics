class FindsBook 
	def self.find_book asin
		book = Book.find_by_asin(asin)
		unless book.present?      
		  amazon_book = AmazonBook.find_by_asin(asin)
		  if amazon_book.present?
		    book = Book.new(amazon_book.attributes)
		  end
		end
		book
	end
end