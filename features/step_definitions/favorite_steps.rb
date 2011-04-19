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

Then /^the investigation "([^"]*)" should be a favorite of the teacher "([^"]*)"$/ do |inv_name, teacher_name|
  investigation = Investigation.find_by_name inv_name
  user = User.find_by_login teacher_name
  teacher = user.portal_teacher
  teacher.favorites.should include investigation
end
