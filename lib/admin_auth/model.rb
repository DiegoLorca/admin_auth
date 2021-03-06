module AdminAuth
  module Model
    EMAIL_REGEX = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
    PASSWORD_MINIMUM = 8

    def self.included(model)
      model.validates :email, format: { with: EMAIL_REGEX }
      model.validates :password, :password_confirmation, length: { minimum: PASSWORD_MINIMUM }
      model.validate :passwords_must_match
    end

    def password
      @password
    end

    def password=(password)
      @password = password
      self.encrypted_password = password_encryptor.encrypt_password(password)
    end

    def password_confirmation
      @password_confirmation
    end

    def password_confirmation=(password)
      @password_confirmation = password
    end

    def correct_password?(password)
      password_encryptor.compare_passwords?(password, encrypted_password)
    end

    private

    def passwords_must_match
      unless @password == @password_confirmation
        error = 'must match'
        errors[:password] << error
        errors[:password_confirmation] << error
      end

      clear_passwords
    end

    def clear_passwords
      @password = @password_confirmation = nil
    end

    def password_encryptor
      @password_encryptor ||= Encryptor.new
    end
  end
end
