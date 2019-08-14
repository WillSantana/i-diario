class UserUpdater
  def self.update!(*attributes)
    new(*attributes).update!
  end

  def initialize(user, entity)
    self.user = user
    self.entity = entity
  end

  def update!
    if user.active? && !user.activation_sent?
      user.transaction do
        UserMailer.notify_activation(user, entity).deliver_now
        user.activation_sent!
      end
    end
  end

  protected

  attr_accessor :user, :entity
end
