module.exports = (robot) ->

    robot.hear /who here/i, (res) ->
        
        output = "The following are currently on shift: \n\n"
        
        # get all user data from sling
        robot.http("https://api.sling.is/v1/users")
            .headers('Accept': 'application/json', 'Authorization': authToken)
            .get() (err, response, body) ->
                if err 
                    console.log(err)
                    return
                
                user_list = JSON.parse body   # returns a list of dictionaries

                now = new Date
                now_formatted = now.toISOString().replace(/:/g, '%3A')
                # now_formatted = now_formatted
                
                robot.http("https://api.sling.is/v1/reports/timesheets?dates=#{now_formatted}")
                    .headers('Accept': 'application/json', 'Authorization': authToken)
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

                            summary = shift_owner.name.toString()  + " " + shift_owner.lastname.toString() + " – " + shift.summary.toString() + "\n"
                            output += summary
                            # console.log("is working from " + shift.dtstart.getHours() + ":" + shift.dtstart.getMinutes() + " to " + shift.dtend)

                        res.send output
                            
