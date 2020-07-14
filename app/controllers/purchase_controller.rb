class PurchaseController < ApplicationController
  before_action :move_to_detail, except: :done
  before_action :set_card, except: :done
  require 'payjp'

  def check
    if @card.blank?
      redirect_to controller: "card", action: "new"
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(@card.customer_id)
      #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
  end

  def pay
    Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    Payjp::Charge.create(
    amount: @item.price, #支払金額を入力
    customer: @card.customer_id, #顧客ID
    currency: 'jpy', #日本円
    )
    @item.sell_or_sold = "Sold"
    @item.buyer_id = current_user.id
    @item.save
    redirect_to action: 'done'
  end

  def done
    @item = Item.find(params[:item_id])
  end

  def move_to_detail
    @item = Item.find(params[:item_id])
    redirect_to '/users/show' if current_user.id == @item.seller_id || @item.buyer_id != nil
  end

  def set_card
    @card = Card.find_by(user_id: current_user.id)
  end

end
