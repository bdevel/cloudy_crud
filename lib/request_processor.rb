
class CloudyCrud::RequestProcessor
  def initialize(request)
    @request = request
  end
  
  def domain
    @request.params[:domain]
  end

  def type
    @request.params[:type]
  end

  def attributes
    @request.params[:attributes]
  end
  
  def user
    @request.current_user
  end
  
end

