# frozen_string_literal: true

module Decidim
  # A command with the business logic to invite a user to
  # a private participatory space.
  class InviteUserToPrivateParticipatorySpace < Rectify::Command
    # Public: Initializes the command.
    #
    # user         - The user that receives the invitation instructions.
    # instructions - The invitation instructions that is sent to the user.
    def initialize(user, instructions)
      @user = user
      @instructions = instructions
    end

    def call
      return broadcast(:invalid) if user&.invitation_accepted_at

      user.invite!(user.invited_by, invitation_instructions: instructions)

      broadcast(:ok)
    end

    private

    attr_reader :user, :instructions
  end
end