class Auth::Admin::UsersController < Auth::Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.includes(:oauth_users).order(created_at: :desc).default_where(search_params).page(params[:page])
  end

  def panel

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.join(params)
      redirect_to admin_users_url, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.js { redirect_to admin_users_url }
        format.html { redirect_to admin_users_url, notice: 'User was successfully updated.' }
      else
        format.js { head :no_content }
        format.html { render :edit }
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_url, alert: 'User was successfully destroyed.'
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def search_params
    params.fetch(:q, {}).permit(:name, :mobile, :email)
  end

  def user_params
    params[:user].permit(
      :name,
      :avatar,
      :avatars,
      :email,
      :mobile,
      :password,
      :disabled
    )
  end

end
