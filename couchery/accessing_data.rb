# setup couch

# google.calendars
#   calendar_id
#   refresh token
#     # https://developers.google.com/accounts/docs/OAuth2
#     # Note: Save refresh tokens in secure long-term storage and continue to use them as long as they remain valid. Limits apply to the number of refresh tokens that are issued per client-user combination, and per user across all clients, and these limits are different. If your application requests enough refresh tokens to go over one of the limits, older refresh tokens stop working.

# google.attendees
#   id
#   email
#   display_name

# google.event
#   id
#   title (summary in the json)
#   calendar_id
#   location
#   html_link
#   google_event_id ('ojair...')
#   start_time (event.start_time # => 2015-02-13T07:00:00Z)
#   end_time

# Day = Struct.new :

save_event = lambda do |event|
  doc = {}
  doc[:id]                 = event.id           # couch id is the google calendar id
  doc[:type]               = 'google.events'
  doc[:start_time]         = event.start_time   # eg "2015-02-13T07:00:00Z"
  doc[:end_time]           = event.end_time     # eg "2015-02-18T07:00:00Z"
  doc[:google_event_id]    = event.id           # eg "abc123"
  doc[:title]              = event.title        # eg "Welcome & Staff Intros"
  doc[:location]           = event.location
  doc[:calendar_html_link] = event.html_link    # eg "https://www.google.com/calendar/event?eid=dTFhYjAzMzJuYjNkYTdna282aTVuZnU4MGMgY2FzaW1pcmNyZWF0aXZlLmNvbV81OWs4bXNycmMyZGRoY3Y3ODd2dWJ2cDBzNEBn"

  # this is probably wrong, b/c its directly saving google calendar json in our db as if its our document
  doc[:attendees]          = event.attendees    # => [{"email"=>"team@turing.io",
                                                       #      "displayName"=>"Turing Team",
                                                       #      "responseStatus"=>"needsAction"
                                                       #    }]
  doc
end


# setup google calendar
require 'google_calendar'

# to get these env vars, source set_env.fish
cal = Google::Calendar.new :client_id     => ENV['GOOGLE_CLIENT_ID'],
                           :client_secret => ENV['GOOGLE_CLIENT_SECRET'],
                           :calendar      => ENV['GOOGLE_CALENDAR_ID'],
                           :redirect_url  => "http://localhost:3000" # this is what Google uses for 'applications'

cal.login_with_refresh_token(ENV['GOOGLE_REFRESH_TOKEN'])
calendar_events = cal.find_events_in_range Date.today.to_time, (Date.today + 7).to_time

events = calendar_events.map do |calendar_event|
  save_event.call calendar_event
end

require "pry"
binding.pry
