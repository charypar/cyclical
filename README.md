# Cyclical

Recurring events library for ruby calendar applications.

## About

Cyclical lets you list recurring events with complex recurrence rules like "every 4 years, the first Tuesday after a Monday in November" in a simple way. The API is inspired by [ice_cube](https://github.com/seejohnrun/ice_cube) and uses method chaining for natural rule specification.

You can find out if a given time matches the schedule, list event occurrences or add event duration and list suboccurrences in a given interval, which is handy when you need to trim event occurences to the interval (like rendering a day in a week view of a calendar with events crossing midnight).

Cyclical was originally extracted from a browser based calendar application and is written in ruby. There is a [JavaScript implementation of Cyclical](https://github.com/charypar/cyclical-js) supporting the same features, intended as a front-end counterpart. You can pass data between the implementations using the built-in JSON serialization.

### Missing features and TODO

*  Rule exception dates
*  Hourly and secondly rules

## Install

Add this line to your application's Gemfile:

    gem 'cyclical'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cyclical

## Usage

The central thing in Cyclical is the ```Schedule```. Let's take the example of U.S. Presidential Election day from RFC 5545:

```ruby
  include Cyclical

  date = Time.local(1997, 8, 2, 9, 0, 0)
  schedule = Schedule.new date, Rule.yearly(4).month(11).weekday(:tue).monthdays(2, 3, 4, 5, 6, 7, 8)

  election_dates = schedule.first(3);
```

### Creating schedules

Each schedule has a base ```date``` and a recurrence rule. The four supported rules are:

*  daily
*  weekly
*  monthly
*  yearly

with corresponding factory methods on ```Rule```. The factory methods take a single argument - the repetition interval.

The basic recurrence rule matches the original date, i.e. for a yearly rule, the occurences will always happen on the same date. To specify a more complex pattern, you can use filters.

Filters replace the single value (day, month) with a set of values that match. For example, instead of only matching the day of month in of the base date, with the ```monthdays``` filter, you can match multiple month days.

Available filters are:

*  weekday(s)
*  monthday(s)
*  yearday(s)
*  month(s)

Each filter methord takes variable arguments containing integers or string (incl. shortcuts) for a given date component.

You can limit the schedule either by a number of events (using the ```count``` method) or an end date (using the ```stop``` method).

### Querying occurrences and suboccurrences

TODO. See ```lib/cyclical/schedule.rb```

### Serialization and deserialization

TODO. See ```lib/cyclical/schedule.rb```

### More examples

TODO. See RFC 5545 examples in ```spec/schedule_spec.rb```

## License

Cyclical is released under the [MIT License](http://www.opensource.org/licenses/MIT).
