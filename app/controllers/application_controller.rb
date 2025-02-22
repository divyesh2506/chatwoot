class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit

  protect_from_forgery with: :null_session

  before_action :set_current_user, unless: :devise_controller?
  around_action :handle_with_exception, unless: :devise_controller?

  # after_action :verify_authorized
  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid

  private

  def handle_with_exception
    yield
  rescue ActiveRecord::RecordNotFound => e
    Raven.capture_exception(e)
    render_not_found_error('Resource could not be found')
  rescue Pundit::NotAuthorizedError
    render_unauthorized('You are not authorized to do this action')
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    Current.user = nil
  end

  def set_current_user
    @user ||= current_user
    Current.user = @user
  end

  def current_subscription
    @subscription ||= Current.account.subscription
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end

  def render_not_found_error(message)
    render json: { error: message }, status: :not_found
  end

  def render_could_not_create_error(message)
    render json: { error: message }, status: :unprocessable_entity
  end

  def render_internal_server_error(message)
    render json: { error: message }, status: :internal_server_error
  end

  def render_record_invalid(exception)
    render json: {
      message: exception.record.errors.full_messages.join(', ')
    }, status: :unprocessable_entity
  end

  def render_error_response(exception)
    render json: exception.to_hash, status: exception.http_status
  end

  def locale_from_params
    I18n.available_locales.map(&:to_s).include?(params[:locale]) ? params[:locale] : nil
  end

  def locale_from_account(account)
    I18n.available_locales.map(&:to_s).include?(account.locale) ? account.locale : nil
  end

  def switch_locale(account)
    # priority is for locale set in query string (mostly for widget/from js sdk)
    locale ||= locale_from_params
    # if local is not set in param, lets try account
    locale ||= locale_from_account(account)
    I18n.locale = locale || I18n.default_locale
  end

  def pundit_user
    {
      user: Current.user,
      account: Current.account,
      account_user: Current.account_user
    }
  end
end
