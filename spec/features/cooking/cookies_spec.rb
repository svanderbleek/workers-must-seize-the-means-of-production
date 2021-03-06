feature 'Cooking cookies' do
  include ActiveJob::TestHelper

  def perform_jobs!
    enqueued_jobs.map do |payload|
      args = payload[:args].map {|arg| GlobalID::Locator.locate(arg["_aj_globalid"]) }
      payload[:job].new(*args)
    end.each(&:perform_now)

    enqueued_jobs.clear
  end
  
  scenario 'Cooking a single cookie' do
    user = create_and_signin
    oven = user.ovens.first

    visit oven_path(oven)

    expect(page).to_not have_content 'Chocolate Chip'
    expect(page).to_not have_content 'Your Cookie is Ready'

    click_link_or_button 'Prepare Cookie'
    fill_in 'Fillings', with: 'Chocolate Chip'
    click_button 'Mix and bake'

    expect(current_path).to eq(oven_path(oven))
    expect(page).to have_content 'Chocolate Chip'
    expect(page).to_not have_content 'Your Cookie is Ready'
    expect(enqueued_jobs.count).to eq(1)

    perform_jobs!
    refresh
    expect(page).to have_content 'Your Cookie is Ready'

    click_button 'Retrieve Cookie'
    expect(page).to_not have_content 'Chocolate Chip'
    expect(page).to_not have_content 'Your Cookie is Ready'

    visit root_path
    within '.store-inventory' do
      expect(page).to have_content '1 Cookie'
    end
  end

  scenario 'Cooking a cookie with no fillings' do
    user = create_and_signin
    oven = user.ovens.first

    visit oven_path(oven)
    click_link_or_button 'Prepare Cookie'
    click_button 'Mix and bake'
    expect(page).to have_content 'no fillings'

    perform_jobs!
    refresh
    click_button 'Retrieve Cookie'
    visit root_path
    expect(page).to have_content 'no filling'
  end

  scenario 'Trying to bake a cookie while oven is full' do
    user = create_and_signin
    oven = user.ovens.first

    oven = FactoryGirl.create(:oven, user: user)
    visit oven_path(oven)

    click_link_or_button 'Prepare Cookie'
    fill_in 'Fillings', with: 'Chocolate Chip'
    click_button 'Mix and bake'

    click_link_or_button  'Prepare Cookie'
    expect(page).to have_content 'A cookie is already in the oven!'
    expect(current_path).to eq(oven_path(oven))
    expect(page).to_not have_button 'Mix and bake'
  end

  scenario 'Automatic update of oven baking cookie', js: true do
    user = create_and_signin
    oven = user.ovens.first

    visit oven_path(oven)
    click_link_or_button 'Prepare Cookie'
    click_button 'Mix and bake'

    perform_jobs!
    click_button 'Retrieve Cookie'
  end

  scenario 'Baking multiple cookies' do
    user = create_and_signin
    oven = user.ovens.first

    oven = FactoryGirl.create(:oven, user: user)
    visit oven_path(oven)

    3.times do
      click_link_or_button 'Prepare Cookie'
      fill_in 'Fillings', with: 'Chocolate Chip'
      click_button 'Mix and bake'

      perform_jobs!
      refresh
      click_button 'Retrieve Cookie'
    end

    visit root_path
    within '.store-inventory' do
      expect(page).to have_content '3 Cookies'
    end
  end

  scenario 'Baking a batch of cookies' do
    batch = 10
    user = create_and_signin
    oven = user.ovens.first

    visit oven_path(oven)
    click_link_or_button 'Prepare Cookie'
    fill_in 'Batch Size', with: batch
    click_button 'Mix and bake'
    expect(page).to have_content(batch)

    perform_jobs!
    refresh
    expect(page).to have_content(batch)

    click_button 'Retrieve Cookie'
    click_link_or_button 'Prepare Cookie'
    click_button 'Mix and bake'
    perform_jobs!
    refresh
    click_button 'Retrieve Cookie'

    visit root_path
    expect(page).to have_content(batch + 1)
  end
end
