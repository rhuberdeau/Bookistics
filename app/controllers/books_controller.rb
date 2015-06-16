class BooksController < ApplicationController
  before_filter :require_user, :only => [ :new, :create, :edit, :show, :update, :lookup_books ]
  before_filter :current_user_has_book? => [ :edit, :update ]

  def index
    @books = Book
               .includes(:users)
               .paginate(:page => params[:page])
               .order('books.created_at DESC')
  end

  def new
  end

  def lookup_books
    @books = AmazonBook.find(params[:keywords])
  end

  def create
    @asin = params[:id]

    if @asin.present?
      @book = FindsBook.find_book(@asin)

      if @book.present?
        current_user.add_book(@book) 
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def show
    @book = Book.find_by_asin(params[:id]) || AmazonBook.find_by_asin(params[:id])

    unless @book.nil?
      if current_user.has_book?(@book.asin)
        @log = current_user.find_log(@book.asin)
        render :edit
      end
    else
      redirect_to_root_with_error("Book not found!")
    end
  end

  def edit
    asin = params[:id]

    @book = Book.find_by_asin(asin)
    @log = current_user.find_log(asin)

    if @book.nil? or @log.nil?
      redirect_to_root_with_error('Book was not found!')
    end
  end

  def update
    start_date = Chronic.parse(params[:start_date])
    finish_date = Chronic.parse(params[:finish_date])
    use_for_statistics = params[:use_for_statistics] || false

    unless (start_date.nil? and !params[:start_date].blank?) or
        (finish_date.nil? and !params[:finish_date].blank?)
      log = current_user.find_log(params[:id])

      log.start_date = (params[:start_date].blank?) ? nil : start_date.to_date
      log.finish_date = (params[:finish_date].blank?) ? nil : finish_date.to_date
      log.use_for_statistics = use_for_statistics

      if log.valid?
        log.save!
        flash[:notice] = 'Updated successfully!'
      else
        flash[:error] = log.errors.full_messages.first
      end
    else
      flash[:error] = 'Date was not recognized!'
    end

    redirect_to edit_book_path(params[:id])
  end

  def destroy
    @asin = params[:id]
    log = current_user.find_log(@asin)
    log.destroy
    current_user.books(true).empty? # This is here to refresh the associations since we deleted one.
  end

  private

  def current_user_has_book?
    if current_user.nil? or !current_user.has_book?(params[:id])
      redirect_to_root_with_error("Sorry but you don't seem to have that book!")
    end
  end
end
