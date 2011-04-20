Then /^the investigation "([^"]*)" should have a favorite link$/ do |inv_name|
  investigation = Investigation.find_by_name inv_name
  elem = find("#investigation_#{investigation.id}")
  elem.should have_selector("input.favorite_link") do |fav|
    fav.should have_content "FAVORITE"
  end
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

Then /^the investigation "([^"]*)" should be a favorite of the teacher "([^"]*)"$/ do |inv_name, teacher_name|
  investigation = Investigation.find_by_name inv_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorite = Favorite.find_by_favoritable_id investigation
  teacher.favorites.should include favorite
end

Then /^the resource page "([^"]*)" should be a favorite of the teacher "([^"]*)"$/ do |rp_name, teacher_name|
  rpage = ResourcePage.find_by_name rp_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  favorite = Favorite.find_by_favoritable_id rpage
  teacher.favorites.should include favorite
end
