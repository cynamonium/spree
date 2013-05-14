Spree::OrdersController.class_eval do

  def update
    @order = current_order
    if @order.update_attributes(params[:order])
      render :edit and return unless apply_coupon_code
      
      @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
      fire_event('spree.order.contents_changed')
      respond_with(@order) do |format|
        format.html do
          if params.has_key?(:checkout)
            if @order.total==0
                session[:order_id] = nil 
                @order.update_attributes({:state => "complete", :payment_state => 'paid', :completed_at => Time.now}, :without_protection => true)
                render 'show'
            else
              redirect_to checkout_state_path(@order.checkout_steps.first)
            end
          else
            redirect_to cart_path
          end
        end
        format.mobile do
          if params.has_key?(:checkout)
            redirect_to checkout_state_path(@order.checkout_steps.first)
          else
            redirect_to cart_path
          end
        end
      end
    else
      respond_with(@order)
    end
  end

end
