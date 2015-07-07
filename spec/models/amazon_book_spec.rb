require 'rails_helper'

describe AmazonBook do 
  describe "#create_book" do 
      let!(:book) do 
        AmazonBook.new(:asin => '12345',
                     :title => "a title",
                     :authors => "Fred Smith",
                     :details_url => "http://www.example.com/a-title",
                     :pages => 500)
      end   
    it "creates a new book" do 
      expect { book.create_book }.to change {Book.count }.from(0).to(1)
    end
  end
end