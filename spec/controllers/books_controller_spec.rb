require "rails_helper"

describe BooksController do 
	let(:user) { User.create! }

	context "when there is an ASIN" do 
		let(:asin) { 'something' }
		before { allow(controller).to receive(:current_user) { user } }
		
		context "when there is a book" do 
			let!(:book) do 
				Book.create!(:asin => asin,
										 :title => "a title",
										 :authors => "Fred Smith",
										 :details_url => "http://www.example.com/a-title")
			end
			
			it "calls add_book" do 
				expect(user).to receive(:add_book).with book
				post :create, :id => asin
			end
		end
		context "when there isn't a book" do 
			it "does not add the book to the user" do 
				allow(FindsBook).to receive(:find_book).with(asin) {nil}
				expect(user.books).to be_empty
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