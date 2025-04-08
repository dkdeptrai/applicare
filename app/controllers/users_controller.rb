class UsersController < ApplicationController
  allow_unauthenticated_access except: [ :show, :edit, :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to new_session_path, notice: "Account created successfully! You can now log in."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def verify_email
    redirect_to new_session_path, notice: "Email verification is disabled. You can log in directly."
  end

  def show
    @user = find_user
  end

  def edit
    @user = find_user
  end

  def update
    @user = find_user

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  def find_user
    Current.user || User.find(params[:id])
  end
end
