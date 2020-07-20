class ItemsController < ApplicationController
  before_action :move_to_login, except: :index

  def index
    @sell_items = Item.where(sell_or_sold: '出品中').order(created_at: :desc).limit(4)
    @random_items = Item.where(sell_or_sold: '出品中').order("RAND()").limit(4)
  end
  
  def new
    @item = Item.new
    @item.images.new
    @category_parent_array = Category.where(ancestry: nil)
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to "/users/show"
    else
      render :new
    end
  end

  def edit
    if current_user.id == Item.find(params[:id]).seller_id
      set_item
      set_categories
      @images = @item.images
    else
      redirect_to root_path
    end
  end
  
  def update
  set_item
    if @item.update(item_params)
      redirect_to users_show_path
    else
      set_categories
      @images = @item.images
      redirect_to  edit_item_path(@item), flash: { error: @item.errors.full_messages }
    end

  end
  
  def move_to_login
    redirect_to "/users/sign_in", notice: 'ログインするとご利用いただけます。' unless user_signed_in?
  end

  # 親カテゴリーが選択された後に動くアクション
  def get_category_children
    @category_children = Category.find(params[:parent_id]).children
  end

  # 子カテゴリーが選択された後に動くアクション
  def get_category_grandchildren
    @category_grandchildren = Category.find(params[:child_id]).children
  end
  
  private
  
  def item_params
    params.require(:item).permit(:name, :brand, :explanation, :status, :sell_or_sold, :delivery_burden,
       :prefecture_id, :delivery_day, :price, :seller_id, :buyer_id, :category_id, images_attributes: [:image, :_destroy, :id])
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def set_categories
    @item_category_grandchild = Category.find(@item.category_id)
    @item_category_child = @item_category_grandchild.parent
    @item_category_parent = @item_category_child.parent
  end
end
