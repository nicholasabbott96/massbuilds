require 'test_helper'

class AdministerOrganizationTest < Capybara::Rails::TestCase

  def organization
    @_org ||= organizations :mapc
  end

  def creator
    @_creator ||= organization.creator
    @_creator.password = 'password'
    @_creator
  end

  def not_yet_admin
    @_user ||= users(:tim)
    @_user.password = 'administrator'
    @_user
  end

  def setup
    organization.memberships.create!(user: not_yet_admin)
    sign_in creator, visit: true, submit: true
  end

  def teardown
    organization.memberships.where(user: not_yet_admin).each(&:destroy)
    sign_out creator
  end

  test 'admin can see organization admin link' do
    visit organization_path(organization)
    assert_content page, 'membership requests'
  end

  test 'admin can view organization admin dashboard' do
    visit admin_organization_path(organization)
    refute_content page, 'not authorized'
    assert_content page, not_yet_admin.first_name
  end

  test 'admin can approve membership requests' do
    %w( Approve Decline ).each do |action|
      visit admin_organization_path(organization)
      assert_content page, not_yet_admin.first_name
      first(:link, action).click
      assert_content page, (action.downcase + 'd')
    end
  end

  test 'normal user cannot view organization admin dashboard' do
    sign_out creator
    sign_in not_yet_admin, visit: true, submit: true
    visit admin_organization_path(organization)
    assert_content page, 'not authorized'
  end

  test 'admin can promote members' do
    skip '!'
    visit admin_organization_path(organization)
    assert_content page, not_yet_admin.first_name
    assert_difference 'organization.admins.count', +1 do
      click_link 'promote'
    end
    assert_content page, 'promoted'
    sign_out creator
    sign_in not_yet_admin, visit: true, submit: true
    visit admin_organization_path(organization)
    refute_content page, 'not authorized'
  end

end

