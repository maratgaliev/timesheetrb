# Timesheetrb

Timesheetrb is a dirty clone of timesheet.php in ruby.

### Notes

Timesheetrb based on [Timesheet.php](https://github.com/madvik/timesheet.php).

### How to run

```ruby
# Add configuration options and just call display() method in your html
alpha = %w(Janv Fev Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    data = {
        'Prun' => [
            {
                'start' => '01-15',
                'end' => '02-20'
            },
            {
                'start' => '09-07',
                'end' => '12-07'
            }
        ],
        'Orange' => [
            {
                'start' => '02-01',
                'end' => '06-31'
            }
        ],
        'Kiwi' => [
            {
                'start' => '08-30',
                'end' => '01-20'
            }
        ]
    }

    args = {
        :id => 'season',
        :theme => 'white',
        :alpha_first => 1,
        :omega_base => 31,
        :line => Date.today.strftime('%m-%d'),
        :line_text => 'Today'
    }

    @graph = TimesheetGraph.new(alpha, args, data)
    
    # And in your view
    @graph.display
```
