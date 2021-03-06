class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
        :omniauthable, omniauth_providers: [:facebook]
  # Associations
  has_many :invitations, dependent: :destroy


  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Avatar upload
  mount_uploader :photo, PhotoUploader

  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving



  #facebook connect
  def self.find_for_facebook_oauth(auth)
    user_params = auth.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    user_params [:oauth_token] = auth.credentials.token
    user_params [:oauth_secret] = auth.credentials.secret
    user_params = user_params.to_h

    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.find_by(email: auth.info.email) # User did a regular sign up in the past.
    if user
      user.update(user_params)
    else
      user = User.new(user_params)
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.save
    end

    return user
  end


  # returns all the events where the user is a host
  def host
   host = self.invitations.select do |invitation|
      invitation.role == "manager"
    end

    host.map! do |invitation|
      invitation.event
    end

  end

  def is_host?(event)
    event.managers.include? self
  end

  # returns all the events where the user is a guest
  def guest
    guest = self.invitations.select do |invitation|
      invitation.role == "guest"
    end

    guest.map do |invitation|
      invitation.event
    end
  end

  # returns all the events where the user is a guest and attend
  def attending
    guest = self.invitations.select do |invitation|
      invitation.role == "guest" && invitation.accepted
    end

    guest.map do |invitation|
      invitation.event
    end


  end

    # returns all the events where the user is a guest and has not responded
  def open_invitation
    guest = invitations.where(role: "guest", accepted: nil).or(invitations.where(role: "guest", accepted: false))

    a = guest.map do |invitation|
      invitation.event
    end


  end

  def facebook
    @facebook = Koala::Facebook::API.new(oauth_token)
  end

  def bring(event)
    u_event = invitation(event)
    event.menu_items.where(invitation: u_event)
  end

  def invitation(event)
    # returns inviation of the event looking at
    self.invitations.where(event: event).first
  end

  def others_bring(event)
    invitation_to_current_event = invitation(event)
    all_brought_elements = event.menu_items.where.not(invitation: nil)
    all_brought_elements.where.not(invitation: invitation_to_current_event)
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

end
