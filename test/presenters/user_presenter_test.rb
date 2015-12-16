require 'test_helper'

class UserPresenterTest < ActiveSupport::TestCase
  def presenter
    @_presenter ||= UserPresenter.new(users(:lower_case))
  end
  def item
    presenter.item
  end
  alias_method :pres, :presenter

  test "first name and last name" do
    assert_equal 'Matt',  pres.first_name
    assert_equal 'Gardner', pres.last_name
  end

  test "short name" do
    assert_equal 'Matt G.', pres.short_name
  end

  test "full_name" do
    assert_equal 'Matt Gardner', pres.full_name
  end

end