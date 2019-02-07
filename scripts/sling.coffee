SLING_AUTH_TOKEN = process.env.SLING_AUTH_TOKEN

module.exports = (robot) ->

    robot.hear /who here/i, (res) ->        
        output = "The following are currently on shift: \n\n"
        
        # get all user data from sling
        robot.http("https://api.sling.is/v1/users")
            .headers('Accept': 'application/json', 'Authorization': SLING_AUTH_TOKEN)
            .get() (err, response, body) ->
                if err 
                    console.log(err)
                    return
                
                user_list = JSON.parse body   # returns a list of dictionaries

                now = new Date
                now_formatted = now.toISOString().replace(/:/g, '%3A')
                # now_formatted = now_formatted
                
                robot.http("https://api.sling.is/v1/reports/timesheets?dates=#{now_formatted}")
                    .headers('Accept': 'application/json', 'Authorization': SLING_AUTH_TOKEN)
                    .get() (err, response, body) ->
                        if err 
                            console.log('something went wrong!!')
                            console.log(err)
                            return
                        
                        todays_shifts = JSON.parse body

                        current_shifts = []
                        for shift in todays_shifts
                            # formatting strings to objects for easier comparisons
                            shift.dtstart = new Date(shift.dtstart)
                            shift.dtend = new Date(shift.dtend)

                            # if the shift is happening right now
                            if now >= shift.dtstart && now < shift.dtend
                                current_shifts.push(shift)

                        for shift in current_shifts
                            # filters through all users json and finds the shift owner details via user_id
                            shift_owner = user_list.filter( (user) -> 
                                return user.id == shift.user.id  
                            )
                            # the filtering above returns a list, this is for formatting sake :-)
                            shift_owner = shift_owner[0]

                            summary = shift_owner.name.toString()  + " " + shift_owner.lastname.toString() + ": " + shift.summary.toString() + "\n"

                            # make the time stamp easier to read with AM/PM formatting
                            options = {
                                hour: 'numeric',
                                minute: 'numeric',
                                hour12: true 
                            }
                            start_formatted = shift.dtstart.toLocaleString('en-US', options)
                            end_formatted = shift.dtend.toLocaleString('en-US', options)
                            
                            summary += start_formatted.toString() + " – " + end_formatted.toString() + "\n\n"
                            output += summary

                        res.send output
                            
