class EventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    true
  end

  def update?
    # if the user is a manager then
    is_manager?
  end

   def destroy?
    is_manager?
  end

  private

  def is_manager?
    record.managers.include? user
  end

end
