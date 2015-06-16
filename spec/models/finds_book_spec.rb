'rails_helper'

describe FindsBook do 
	context "#find_book" do 
		let(:asin) { 'something' }

		context "when the book is in the database" do 
			let!(:book) do 
				Book.create!(:asin => asin,
										 :title => "a title",
										 :authors => "Fred Smith",
										 :details_url => "http://www.example.com/a-title")
			end			
			it "returns the book" do 
				expect(FindsBook.find_book(asin)).to eql book
			end
		end
		context "when the book is not in the database" do 
			let!(:book_attributes) do 
				{:asin => asin,
				 :title => "a title",
				 :authors => "Fred Smith",
				 :details_url => "http://www.example.com/a-title"}
			end

			context "when the book is in amazon" do 
				it "it returns the book from amazon" do 
					allow(Book).to receive(:find_by_asin).with(asin) {nil}
					amazon_book = double
					book 				= double
					allow(amazon_book).to receive(:attributes) {book_attributes}
					allow(AmazonBook).to receive(:find_by_asin).with(asin) {amazon_book}
					allow(Book).to receive(:new).with(amazon_book.attributes) {book}
					expect(FindsBook.find_book(asin)).to eql book
				end
			end

			context "when the book is not in amazon" do 
				it "returns nil" do 
					allow(AmazonBook).to receive(:find_by_asin).with(asin) {nil}
					expect(FindsBook.find_book(asin)).to eql nil
				end
			end
		end
	end
end