require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.




describe Api::V1::BooksController do
   
  before(:each) do
    @user = FactoryGirl.create(:user)  
    @tag = FactoryGirl.create(:tag) 
    @book = Book.create!(:title => "bookname", :user_id => @user.id, :location_id => 1, :user_id => @user.id)
  end


  
  # This should return the minimal set of attributes required to create a valid
  # Book. As you add validations to Book, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {:format => 'json', :book => {:title => "bookname", :user_id => @user.id},
      :user_token => @user.authentication_token, :user_email => @user.email, :location => {:latitude => 12.33, :longitude => 13.12}} } 

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BooksController. Be sure to keep this updated too.
  

  describe "GET index" do
    it "shows list of current user books" do
      get :index, {:user_token => @user.authentication_token, :user_email => @user.email}
      expect(json).to have_key('books')
      expect(json['books'].count).to eq(@user.books.count)
    end
  end

  describe "GET show" do
    it "returns the book without sign in" do
      visit_count = @book.visits.to_i
      get :show, {:id => @book.to_param}
      visit_count.should_not eq(@book.visits.to_i+1)
      expect(response.status).to eq(200)
      expect(json).to have_key('book')
    end
    it "returns the book and adds user book visits with sign_in" do
      get :show, {:id => @book.to_param, :user_token => @user.authentication_token, :user_email => @user.email}
      expect(@book.user_book_visits.count).to eq(1)
      expect(response.status).to eq(200)
      expect(json).to have_key('book')
    end
    it "returns error if invalid book id" do
      get :show, {:id => 100}
      expect(response.status).to eq(400)
      expect(json).to have_key('error_code')
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Book" do
        expect {
          post :create, valid_attributes
        }.to change(Book, :count).by(1)
        expect(response.status).to eq(200)
        expect(json).to have_key('book')
      end
    end
    describe "with invalid params" do
      it "returns an error code" do
        # Trigger the behavior that occurs when invalid params are submitted
        Book.any_instance.stub(:save).and_return(false)
        post :create, valid_attributes
        expect(response.status).to eq(400)
        expect(json).to have_key('error_code')
        expect(json).to have_key('error_message')
      end
    end
  end

  describe "Put update" do
    describe "with valid params" do
      it "updates the book" do
        put :update, valid_attributes.merge!(:id => @book.id)
        expect(response.status).to eq(200)
        expect(json).to have_key('book')
      end
    end
    describe "with invalid params" do
      it "returns an error code" do
        # Trigger the behavior that occurs when invalid params are submitted
        Book.any_instance.stub(:save).and_return(false)
        put :update, valid_attributes.merge!(:id => @book.id)
        expect(response.status).to eq(400)
        expect(json).to have_key('error_code')
        expect(json).to have_key('error_message')
      end
    end
  end


  describe "POST change_ownership" do
    it "change the owner of book" do
      @user2 = FactoryGirl.create(:user)
      post :change_owner, {:user_token => @user.authentication_token, 
     :user_email => @user.email, :book_id => @book.id, :user_id => @user2.id}
      expect(response.status).to eq(200)
      expect(@user2.books.last).to eq(@book)
      expect(@user.books.count).to eq(0)
    end
    it "returns an error code if something went wrong" do
      @user2 = FactoryGirl.create(:user)
      post :change_owner, {:user_token => @user.authentication_token,  
      :user_email => @user.email, :book_id => "", :user_id => @user2.id}
      expect(response.status).to eq(400)
      expect(json).to have_key('error_code')
    end
  end


    describe "Get book_info " do
      it "gives a particular book details" do
        get :book_info, {:q => "rails", :format => 'json'}
        response.body.should_not be_empty
      end
    end
  
   describe "Get book_suggestions" do
      it "gives book title suggestions " do
        get :book_suggestions, {:q => "rails", :format => 'json'}
        response.body.should_not be_empty
      end
    end

    describe "Post add_wish_list" do
      it "add wishlists with valid params" do
        post :set_wish_list, {:user_token => @user.authentication_token,  
      :user_email => @user.email, :wish_list => {:title => "rails"}}
        expect(response.status).to eq(200)
        expect(@user.wish_lists.count).to eq(1)
      end
      it "add wishlists with invalid params returns error code" do
        post :set_wish_list, {:user_token => @user.authentication_token,  
       :user_email => @user.email, :wish_list => {}}
        expect(response.status).to eq(400)
        expect(json["wish_list"]).to eq(@user.wish_lists.last)
      end
    end

    describe "get_wish_list" do 
      it "gets the wishlist" do
        get :get_wish_list, {:user_token => @user.authentication_token,  
                              :user_email => @user.email}
      expect(response.status).to eq(200)
      response.body.should_not be_empty
      end
    end
  

  # describe "DELETE destroy" do
  #   it "destroys the requested book" do
  #     book = Book.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => book.to_param}
  #     }.to change(Book, :count).by(-1)
  #   end

  #   it "redirects to the books list" do
  #     book = Book.create! valid_attributes
  #     delete :destroy, {:id => book.to_param}
  #     response.should redirect_to(books_url)
  #   end
  # end

end
