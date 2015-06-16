require "rails_helper"

describe BooksController do 
	let(:user) { User.create! }

	context "when there is an ASIN" do 
		let(:asin) { 'something' }
		
		context "when the book is in the database" do 
			let!(:book) do 
				Book.create!(:asin => asin,
										 :title => "a title",
										 :authors => "Fred Smith",
										 :details_url => "http://www.example.com/a-title")
			end
			before { allow(controller).to receive(:current_user) { user } }
			
			it "calls add_book" do 
				expect(user).to receive(:add_book).with book
				post :create, :id => asin
			end
		end
		context "when the book is not in the database" do 
			let!(:book_attributes) do 
				{:asin => asin,
				 :title => "a title",
				 :authors => "Fred Smith",
				 :details_url => "http://www.example.com/a-title"}
			end
			before { allow(controller).to receive(:current_user) { user } }

			context "when the book is in amazon" do 
				it "adds the book to the user" do 
					amazon_book = double
					allow(amazon_book).to receive(:attributes) {book_attributes}
					allow(AmazonBook).to receive(:find_by_asin).with(asin) {amazon_book}
					post :create, :id => asin 
					expect(user.books.count).to eql 1
					expect(user.books.first.title).to eql "a title"
				end
			end

			context "when the book is not in amazon" do 
				it "does not add the book to the user" do 
					allow(Book).to receive(:find_by_asin).with(asin) { nil }
					allow(AmazonBook).to receive(:find_by_asin).with(asin) { nil }
					post :create, :id => asin
					expect(user.books).to be_empty
				end
			end
		end
	end
	context "when there is not an ASIN" do 
		it "does not add the book to the user" do 
			post :create, :id => nil
			expect(user.books).to be_empty
		end
	end
end