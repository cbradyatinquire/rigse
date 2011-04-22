Given /^the investigation "([^"]*)" is a favorite for the teacher "([^"]*)"$/ do |inv_name, teacher_name|
  investigation = Investigation.find_by_name inv_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  teacher.favorites.create :favoritable => investigation
end

Given /^the resource page "([^"]*)" is a favorite for the teacher "([^"]*)"$/ do |rp_name, teacher_name|
  rpage = ResourcePage.find_by_name rp_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  teacher.favorites.create :favoritable => rpage
end

When /^I click the remove favorite link for the investigation "([^"]*)"$/ do |inv_name|
  investigation = Investigation.find_by_name inv_name
  steps %Q{
    When I press "REMOVE FAVORITE" within "#favorite_investigation_#{investigation.id}"
  }
end

When /^I click the favorite link for the investigation "(.*)"$/ do |inv_name|
  investigation = Investigation.find_by_name inv_name
  steps %Q{
    When I press "FAVORITE" within "#investigation_#{investigation.id}"
  }
end

When /^I click the favorite link for the resource page "([^"]*)"$/ do |rp_name|
  rpage = ResourcePage.find_by_name rp_name
  steps %Q{
    When I press "FAVORITE" within "#resource_page_#{rpage.id}"
  }
end

When /^I click the favorite link for the external activity "([^"]*)"$/ do |ea_name|
  eact = ExternalActivity.find_by_name ea_name
  steps %Q{
    When I press "FAVORITE" within "#external_activity_#{eact.id}"
  }
end

Then /^the investigation "([^"]*)" should not be a favorite of the teacher "([^"]*)"$/ do |inv_name, teacher_name|
  investigation = Investigation.find_by_name inv_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorite = Favorite.find_by_favoritable_id_and_favoritable_type investigation, investigation.class.to_s
  teacher.favorites.should_not include favorite
end

Then /^the external activity "([^"]*)" should be a favorite of the teacher "([^"]*)"$/ do |ea_name, teacher_name|
  eact = ExternalActivity.find_by_name ea_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorite = Favorite.find_by_favoritable_id_and_favoritable_type eact, eact.class.to_s
  teacher.favorites.should include favorite
  favorite.favoritable.should == eact
end

Then /^the investigation "([^"]*)" should be a favorite of the teacher "([^"]*)"$/ do |inv_name, teacher_name|
  investigation = Investigation.find_by_name inv_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorite = Favorite.find_by_favoritable_id_and_favoritable_type investigation, investigation.class.to_s
  teacher.favorites.should include favorite
  favorite.favoritable.should == investigation
end

Then /^the resource page "([^"]*)" should be a favorite of the teacher "([^"]*)"$/ do |rp_name, teacher_name|
  rpage = ResourcePage.find_by_name rp_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorite = Favorite.find_by_favoritable_id_and_favoritable_type rpage, rpage.class.to_s
  teacher.favorites.should include favorite
  favorite.favoritable.should == rpage
end

Then /^I should see the investigation "([^"]*)" in the favorite assignments listing$/ do |inv_name|
  steps %Q{
    Then I should see "#{inv_name}" within "#favorites_listing"
  }
end

Then /^I should see the resource page "([^"]*)" in the favorite assignments listing$/ do |rp_name|
  steps %Q{
    Then I should see "#{rp_name}" within "#favorites_listing"
  }
end

Then /^I should see the external activity "([^"]*)" in the favorite assignments listing$/ do |ea_name|
  steps %Q{
    Then I should see "#{ea_name}" within "#favorites_listing"
  }
end

Then /^the investigation "([^"]*)" should have a favorite link$/ do |inv_name|
  investigation = Investigation.find_by_name inv_name
  elem = find("#investigation_#{investigation.id}")
  elem.should have_selector("input.favorite_link") do |fav|
    fav.should have_content "FAVORITE"
  end
end

Then /^there should only be one instance of the investigation "([^"]*)" in the favorites of the teacher "([^"]*)"$/ do |inv_name, teacher_name|
  investigation = Investigation.find_by_name inv_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorites = Favorite.find_all_by_favoritable_id_and_favoritable_type investigation, investigation.class.to_s
  favorites.count.should == 1
end

When /^I drag the favorite investigation "([^"]*)" to "([^"]*)"$/ do |investigation_name, to|
  investigation = Investigation.find_by_name investigation_name
  selector = find("#favorite_investigation_#{investigation.id}")
  drop = find(to)
  selector.drag_to(drop)
end

Then /^I should not see the resource page "([^"]*)" in the favorite assignments listing$/ do |rp_name|
  steps %Q{
    Then I should not see "#{rp_name}" within "#favorites_listing"
  }
end
