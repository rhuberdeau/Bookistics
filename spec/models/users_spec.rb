require 'rails_helper'

describe User do 
  context "#add_book" do
  	let(:asin) { 'something' } 
  	let(:user) { User.create! }
  	let!(:book) do 
  		Book.create!(:asin => asin,
  								 :title => "a title",
  								 :authors => "Fred Smith",
  								 :details_url => "http://www.example.com/a-title")
  	end
  	context "when the user does not have the book" do 
			it "adds the book to the user" do 
				user.add_book(book)
				expect(user.books).to eql [book]
			end
  	end

  	context "when the user already has the book" do 
  		it "does not add the book to the user" do 
  			user.add_book(book)
  			expect{user.add_book(book)}.to_not change{user.books.count}
  		end
  	end
  end
end